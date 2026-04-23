//===-- SPIRVMergeRegionExitTargets.cpp ----------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Merge the multiple exit targets of a convergence region into a single block.
// Each exit target will be assigned a constant value, and a phi node + switch
// will allow the new exit target to re-route to the correct basic block.
//
//===----------------------------------------------------------------------===//

#include "Analysis/SPIRVConvergenceRegionAnalysis.h"
#include "SPIRV.h"
#include "SPIRVSubtarget.h"
#include "SPIRVUtils.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/InitializePasses.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/LoopSimplify.h"
#include "llvm/Transforms/Utils/LowerMemIntrinsics.h"

using namespace llvm;

namespace {

class SPIRVMergeRegionExitTargets : public FunctionPass {
public:
  static char ID;

  SPIRVMergeRegionExitTargets() : FunctionPass(ID) {}

  /// Create a value in BB set to the value associated with the branch the block
  /// terminator will take.
  llvm::Value *createExitVariable(
      BasicBlock *BB,
      const DenseMap<BasicBlock *, ConstantInt *> &TargetToValue) {
    auto *T = BB->getTerminator();
    if (isa<ReturnInst>(T))
      return nullptr;
    if (auto *BI = dyn_cast<UncondBrInst>(T))
      return TargetToValue.lookup(BI->getSuccessor());

    IRBuilder<> Builder(BB);
    Builder.SetInsertPoint(T);

    if (auto *BI = dyn_cast<CondBrInst>(T)) {
      Value *LHS = TargetToValue.lookup(BI->getSuccessor(0));
      Value *RHS = TargetToValue.lookup(BI->getSuccessor(1));

      if (LHS == nullptr || RHS == nullptr)
        return LHS == nullptr ? RHS : LHS;
      return Builder.CreateSelect(BI->getCondition(), LHS, RHS);
    }

    if (auto *SI = dyn_cast<SwitchInst>(T)) {
      // Start with the value for the default destination (may be nullptr if it
      // is not an exit target of this region).
      Value *Result = TargetToValue.lookup(SI->getDefaultDest());

      // For each numbered case, if its successor is an exit target, emit a
      // select that overrides Result when the switch condition matches that
      // case value.
      for (auto &Case : SI->cases()) {
        Value *CaseVal = TargetToValue.lookup(Case.getCaseSuccessor());
        if (CaseVal == nullptr)
          continue;
        Value *Cmp = Builder.CreateICmpEQ(SI->getCondition(),
                                          Case.getCaseValue());
        Result = Builder.CreateSelect(Cmp, CaseVal,
                                      Result ? Result : CaseVal);
      }

      return Result;
    }

    llvm_unreachable("Unhandled terminator type.");
  }

  AllocaInst *CreateVariable(Function &F, Type *Type,
                             BasicBlock::iterator Position) {
    const DataLayout &DL = F.getDataLayout();
    return new AllocaInst(Type, DL.getAllocaAddrSpace(), nullptr, "reg",
                          Position);
  }

  // Run the pass on the given convergence region, ignoring the sub-regions.
  // Returns true if the CFG changed, false otherwise.
  bool runOnConvergenceRegionNoRecurse(LoopInfo &LI,
                                       SPIRV::ConvergenceRegion *CR) {
    // Gather all the exit targets for this region.
    SmallPtrSet<BasicBlock *, 4> ExitTargets;
    for (BasicBlock *Exit : CR->Exits) {
      for (BasicBlock *Target : successors(Exit)) {
        if (CR->Blocks.count(Target) == 0)
          ExitTargets.insert(Target);
      }
    }

    // If we have zero or one exit target, nothing do to.
    if (ExitTargets.size() <= 1)
      return false;

    // Create the new single exit target.
    auto F = CR->Entry->getParent();
    auto NewExitTarget = BasicBlock::Create(F->getContext(), "new.exit", F);
    IRBuilder<> Builder(NewExitTarget);

    AllocaInst *Variable = CreateVariable(*F, Builder.getInt32Ty(),
                                          F->begin()->getFirstInsertionPt());

    // CodeGen output needs to be stable. Using the set as-is would order
    // the targets differently depending on the allocation pattern.
    // Sorting per basic-block ordering in the function.
    std::vector<BasicBlock *> SortedExitTargets;
    std::vector<BasicBlock *> SortedExits;
    for (BasicBlock &BB : *F) {
      if (ExitTargets.count(&BB) != 0)
        SortedExitTargets.push_back(&BB);
      if (CR->Exits.count(&BB) != 0)
        SortedExits.push_back(&BB);
    }

    // Creating one constant per distinct exit target. This will be route to the
    // correct target.
    DenseMap<BasicBlock *, ConstantInt *> TargetToValue;
    for (BasicBlock *Target : SortedExitTargets)
      TargetToValue.insert(
          std::make_pair(Target, Builder.getInt32(TargetToValue.size())));

    // Creating one variable per exit node, set to the constant matching the
    // targeted external block.
    std::vector<std::pair<BasicBlock *, Value *>> ExitToVariable;
    for (auto Exit : SortedExits) {
      llvm::Value *Value = createExitVariable(Exit, TargetToValue);
      IRBuilder<> B2(Exit);
      B2.SetInsertPoint(Exit->getFirstInsertionPt());
      B2.CreateStore(Value, Variable);
      ExitToVariable.emplace_back(std::make_pair(Exit, Value));
    }

    llvm::Value *Load = Builder.CreateLoad(Builder.getInt32Ty(), Variable);

    // Creating the switch to jump to the correct exit target.
    llvm::SwitchInst *Sw = Builder.CreateSwitch(Load, SortedExitTargets[0],
                                                SortedExitTargets.size() - 1);
    for (size_t i = 1; i < SortedExitTargets.size(); i++) {
      BasicBlock *BB = SortedExitTargets[i];
      Sw->addCase(TargetToValue[BB], BB);
    }

    // Fix exit branches to redirect to the new exit.
    // Before redirecting, collect phi incoming values from each Exit block so we
    // can repair phi nodes in the old ExitTarget blocks afterward.
    // Map: ExitTarget -> (PHINode -> list of (Exit, incoming_value) pairs)
    DenseMap<BasicBlock *,
             DenseMap<PHINode *, SmallVector<std::pair<BasicBlock *, Value *>, 2>>>
        PhiFixup;
    for (auto Exit : CR->Exits) {
      Instruction *T = Exit->getTerminator();
      for (auto I = succ_begin(T), E = succ_end(T); I != E; ++I) {
        BasicBlock *OldTarget = *I;
        if (!ExitTargets.contains(OldTarget))
          continue;
        // Record phi contributions from Exit before redirecting the edge.
        auto &PhiMap = PhiFixup[OldTarget];
        for (PHINode &PN : OldTarget->phis()) {
          int Idx = PN.getBasicBlockIndex(Exit);
          if (Idx >= 0)
            PhiMap[&PN].emplace_back(Exit, PN.getIncomingValue(Idx));
        }
        I.getUse()->set(NewExitTarget);
      }
    }

    // Repair phi nodes in each old ExitTarget: remove the now-invalid incoming
    // edges from redirected Exit blocks and add a single incoming edge from
    // NewExitTarget.  When multiple Exit blocks contributed different values to
    // the same phi, insert a collecting phi in NewExitTarget.
    for (auto &[OldTarget, PhiMap] : PhiFixup) {
      for (auto &[PN, Contributions] : PhiMap) {
        // Remove all incoming edges from the redirected Exit blocks.
        for (auto &[Exit, Val] : Contributions)
          PN->removeIncomingValue(Exit, /*DeletePHIIfEmpty=*/false);

        // Determine the single value to add for NewExitTarget.
        Value *NewVal = Contributions[0].second;
        if (Contributions.size() > 1) {
          // Check whether all contributions carry the same value.
          bool AllSame = true;
          for (size_t i = 1; i < Contributions.size(); i++) {
            if (Contributions[i].second != NewVal) {
              AllSame = false;
              break;
            }
          }
          if (!AllSame) {
            // Create a phi in NewExitTarget to merge values from each Exit.
            IRBuilder<> PhiBuilder(NewExitTarget,
                                   NewExitTarget->getFirstInsertionPt());
            PHINode *CollectingPhi =
                PhiBuilder.CreatePHI(PN->getType(), Contributions.size());
            for (auto &[Exit, Val] : Contributions)
              CollectingPhi->addIncoming(Val, Exit);
            NewVal = CollectingPhi;
          }
        }
        PN->addIncoming(NewVal, NewExitTarget);
      }
    }

    CR = CR->Parent;
    while (CR) {
      CR->Blocks.insert(NewExitTarget);
      CR = CR->Parent;
    }

    return true;
  }

  /// Run the pass on the given convergence region and sub-regions (DFS).
  /// Returns true if a region/sub-region was modified, false otherwise.
  /// This returns as soon as one region/sub-region has been modified.
  bool runOnConvergenceRegion(LoopInfo &LI, SPIRV::ConvergenceRegion *CR) {
    for (auto *Child : CR->Children)
      if (runOnConvergenceRegion(LI, Child))
        return true;

    return runOnConvergenceRegionNoRecurse(LI, CR);
  }

#if !NDEBUG
  /// Validates each edge exiting the region has the same destination basic
  /// block.
  void validateRegionExits(const SPIRV::ConvergenceRegion *CR) {
    for (auto *Child : CR->Children)
      validateRegionExits(Child);

    std::unordered_set<BasicBlock *> ExitTargets;
    for (auto *Exit : CR->Exits) {
      for (auto *BB : successors(Exit)) {
        if (CR->Blocks.count(BB) == 0)
          ExitTargets.insert(BB);
      }
    }

    assert(ExitTargets.size() <= 1);
  }
#endif

  bool runOnFunction(Function &F) override {
    LoopInfo &LI = getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
    auto *TopLevelRegion =
        getAnalysis<SPIRVConvergenceRegionAnalysisWrapperPass>()
            .getRegionInfo()
            .getWritableTopLevelRegion();

    // FIXME: very inefficient method: each time a region is modified, we bubble
    // back up, and recompute the whole convergence region tree. Once the
    // algorithm is completed and test coverage good enough, rewrite this pass
    // to be efficient instead of simple.
    bool modified = false;
    while (runOnConvergenceRegion(LI, TopLevelRegion)) {
      modified = true;
    }

#if !defined(NDEBUG) || defined(EXPENSIVE_CHECKS)
    validateRegionExits(TopLevelRegion);
#endif
    return modified;
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<DominatorTreeWrapperPass>();
    AU.addRequired<LoopInfoWrapperPass>();
    AU.addRequired<SPIRVConvergenceRegionAnalysisWrapperPass>();

    AU.addPreserved<SPIRVConvergenceRegionAnalysisWrapperPass>();
    FunctionPass::getAnalysisUsage(AU);
  }
};
} // namespace

char SPIRVMergeRegionExitTargets::ID = 0;

INITIALIZE_PASS_BEGIN(SPIRVMergeRegionExitTargets, "split-region-exit-blocks",
                      "SPIRV split region exit blocks", false, false)
INITIALIZE_PASS_DEPENDENCY(LoopSimplify)
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(LoopInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(SPIRVConvergenceRegionAnalysisWrapperPass)

INITIALIZE_PASS_END(SPIRVMergeRegionExitTargets, "split-region-exit-blocks",
                    "SPIRV split region exit blocks", false, false)

FunctionPass *llvm::createSPIRVMergeRegionExitTargetsPass() {
  return new SPIRVMergeRegionExitTargets();
}
