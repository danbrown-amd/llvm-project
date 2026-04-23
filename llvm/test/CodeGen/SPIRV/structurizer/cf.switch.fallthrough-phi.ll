; RUN: llc -mtriple=spirv-unknown-vulkan-compute -O0 %s -o - | FileCheck %s
; RUN: %if spirv-tools %{ llc -O0 -mtriple=spirv-unknown-vulkan-compute %s -o - -filetype=obj | spirv-val %}

; Regression test for https://github.com/llvm/llvm-project/issues/182145
;
; A switch with C-style fallthrough (case 0 falls through to case 2) produced
; OpUndef in OpPhi nodes because the structurizer's createSingleExitNode
; created a merge block with multiple predecessors but did not insert stores
; for allocas that were only defined on some of those predecessor paths.
; mem2reg then promoted those incompletely-defined allocas into phi nodes with
; undef incoming values that could reach wave operations.
;
; The HLSL pattern that triggered this was:
;   bool B1 = false;
;   switch (val) {
;     case 0: WaveActiveCountBits(true); // falls through
;     case 2: B1 = true; break;
;     default: WaveActiveCountBits(false); break;
;   }
;   WaveActiveCountBits(B1); // must not receive undef
;
; The switch has two structural exit targets:
;   - %exit        reached directly from case 2 (%exit.crit.edge)
;   - %sink.split  reached from case 0 and default (which also store to %B1.ph)
; createSingleExitNode creates a new merge block routing to both targets.
; Without the fix, %exit.crit.edge does not store to %B1.ph, so mem2reg inserts
; undef for that predecessor, propagating OpUndef to WaveActiveCountBits.

; CHECK-NOT: OpUndef

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64-G10"
target triple = "spirv1.6-unknown-vulkan1.3-compute"

declare i32 @llvm.spv.wave.active.countbits(i1) #0
declare i32 @llvm.spv.thread.id.i32(i32) #2
declare token @llvm.experimental.convergence.entry() #0

define void @main() #1 {
entry:
  %tok = call token @llvm.experimental.convergence.entry()
  ; Allocas representing the bool B1 on different paths (as produced by
  ; clang's reg2mem transformation before the SPIRV structurizer runs).
  %B1 = alloca i1, align 1       ; final B1 value read at the exit
  %B1.ph = alloca i1, align 1    ; B1 staging alloca for case-0/default paths
  %val = call i32 @llvm.spv.thread.id.i32(i32 0)
  store i1 false, ptr %B1
  switch i32 %val, label %sw.default [
    i32 0, label %sw.bb
    i32 2, label %exit.crit.edge
  ]

; Case 2: sets B1=true and jumps directly to %exit (no WaveActiveCountBits here).
exit.crit.edge:
  store i1 true, ptr %B1
  ; NOTE: %B1.ph is intentionally NOT stored here, matching the original bug
  ; pattern where the direct-exit case bypasses the staging alloca.
  br label %exit

; Case 0: WaveActiveCountBits(true) then falls through to %sink.split.
sw.bb:
  %wave.true = call spir_func i32 @llvm.spv.wave.active.countbits(i1 true) #0 [ "convergencectrl"(token %tok) ]
  store i1 true, ptr %B1.ph
  br label %sink.split

; Default: WaveActiveCountBits(false) then falls through to %sink.split.
sw.default:
  %wave.false = call spir_func i32 @llvm.spv.wave.active.countbits(i1 false) #0 [ "convergencectrl"(token %tok) ]
  store i1 false, ptr %B1.ph
  br label %sink.split

; Shared block for cases 0 and default: copies %B1.ph into %B1 then exits.
sink.split:
  %B1.ph.val = load i1, ptr %B1.ph
  store i1 %B1.ph.val, ptr %B1
  br label %exit

; Final exit: WaveActiveCountBits(B1) must not receive OpUndef.
exit:
  %B1.val = load i1, ptr %B1
  %wave.B1 = call spir_func i32 @llvm.spv.wave.active.countbits(i1 %B1.val) #0 [ "convergencectrl"(token %tok) ]
  ret void
}

attributes #0 = { convergent mustprogress nocallback nofree nosync nounwind willreturn memory(none) }
attributes #1 = { convergent noinline norecurse nounwind "hlsl.numthreads"="4,1,1" "hlsl.shader"="compute" }
attributes #2 = { mustprogress nofree nosync nounwind willreturn memory(none) }
