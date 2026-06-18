// RUN: %clang_cc1 -finclude-default-header -x hlsl -triple \
// RUN:   dxil-pc-shadermodel6.3-library %s -fnative-half-type -fnative-int16-type \
// RUN:   -emit-llvm -disable-llvm-passes -o - | FileCheck %s \
// RUN:   --check-prefixes=CHECK,NATIVE_HALF \
// RUN:   -DTARGET=dx
// RUN: %clang_cc1 -finclude-default-header -x hlsl -triple \
// RUN:   dxil-pc-shadermodel6.3-library %s -emit-llvm -disable-llvm-passes \
// RUN:   -o - | FileCheck %s --check-prefixes=CHECK,NO_HALF \
// RUN:   -DTARGET=dx
// RUN: %clang_cc1 -finclude-default-header -x hlsl -triple \
// RUN:   spirv-unknown-vulkan-compute %s -fnative-half-type -fnative-int16-type \
// RUN:   -emit-llvm -disable-llvm-passes -o - | FileCheck %s \
// RUN:   --check-prefixes=CHECK,NATIVE_HALF \
// RUN:   -DTARGET=spv
// RUN: %clang_cc1 -finclude-default-header -x hlsl -triple \
// RUN:   spirv-unknown-vulkan-compute %s -emit-llvm -disable-llvm-passes \
// RUN:   -o - | FileCheck %s --check-prefixes=CHECK,NO_HALF \
// RUN:   -DTARGET=spv

#ifdef __HLSL_ENABLE_16_BIT
// NATIVE_HALF-LABEL: test_any_int16_t1x3
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3i16
// NATIVE_HALF: ret i1 %hlsl.any
bool test_any_int16_t1x3(int16_t1x3 p0) { return any(p0); }

// NATIVE_HALF-LABEL: test_any_int16_t2x3
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6i16
// NATIVE_HALF: ret i1 %hlsl.any
bool test_any_int16_t2x3(int16_t2x3 p0) { return any(p0); }

// NATIVE_HALF-LABEL: test_any_int16_t3x1
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3i16
// NATIVE_HALF: ret i1 %hlsl.any
bool test_any_int16_t3x1(int16_t3x1 p0) { return any(p0); }

// NATIVE_HALF-LABEL: test_any_int16_t3x2
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6i16
// NATIVE_HALF: ret i1 %hlsl.any
bool test_any_int16_t3x2(int16_t3x2 p0) { return any(p0); }

// NATIVE_HALF-LABEL: test_any_int16_t3x3
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v9i16
// NATIVE_HALF: ret i1 %hlsl.any
bool test_any_int16_t3x3(int16_t3x3 p0) { return any(p0); }

// NATIVE_HALF-LABEL: test_any_int16_t4x4
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v16i16
// NATIVE_HALF: ret i1 %hlsl.any
bool test_any_int16_t4x4(int16_t4x4 p0) { return any(p0); }

// NATIVE_HALF-LABEL: test_any_uint16_t1x3
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3i16
// NATIVE_HALF: ret i1 %hlsl.any
bool test_any_uint16_t1x3(uint16_t1x3 p0) { return any(p0); }

// NATIVE_HALF-LABEL: test_any_uint16_t2x3
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6i16
// NATIVE_HALF: ret i1 %hlsl.any
bool test_any_uint16_t2x3(uint16_t2x3 p0) { return any(p0); }

// NATIVE_HALF-LABEL: test_any_uint16_t3x1
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3i16
// NATIVE_HALF: ret i1 %hlsl.any
bool test_any_uint16_t3x1(uint16_t3x1 p0) { return any(p0); }

// NATIVE_HALF-LABEL: test_any_uint16_t3x2
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6i16
// NATIVE_HALF: ret i1 %hlsl.any
bool test_any_uint16_t3x2(uint16_t3x2 p0) { return any(p0); }

// NATIVE_HALF-LABEL: test_any_uint16_t3x3
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v9i16
// NATIVE_HALF: ret i1 %hlsl.any
bool test_any_uint16_t3x3(uint16_t3x3 p0) { return any(p0); }

// NATIVE_HALF-LABEL: test_any_uint16_t4x4
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v16i16
// NATIVE_HALF: ret i1 %hlsl.any
bool test_any_uint16_t4x4(uint16_t4x4 p0) { return any(p0); }

#endif // __HLSL_ENABLE_16_BIT

// CHECK-LABEL: test_any_half1x3
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3f16
// NO_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3f32
// CHECK: ret i1 %hlsl.any
bool test_any_half1x3(half1x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_half2x3
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6f16
// NO_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6f32
// CHECK: ret i1 %hlsl.any
bool test_any_half2x3(half2x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_half3x1
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3f16
// NO_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3f32
// CHECK: ret i1 %hlsl.any
bool test_any_half3x1(half3x1 p0) { return any(p0); }

// CHECK-LABEL: test_any_half3x2
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6f16
// NO_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6f32
// CHECK: ret i1 %hlsl.any
bool test_any_half3x2(half3x2 p0) { return any(p0); }

// CHECK-LABEL: test_any_half3x3
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v9f16
// NO_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v9f32
// CHECK: ret i1 %hlsl.any
bool test_any_half3x3(half3x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_half4x4
// NATIVE_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v16f16
// NO_HALF: %hlsl.any = call i1 @llvm.[[TARGET]].any.v16f32
// CHECK: ret i1 %hlsl.any
bool test_any_half4x4(half4x4 p0) { return any(p0); }

// CHECK-LABEL: test_any_float1x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3f32
// CHECK: ret i1 %hlsl.any
bool test_any_float1x3(float1x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_float2x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6f32
// CHECK: ret i1 %hlsl.any
bool test_any_float2x3(float2x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_float3x1
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3f32
// CHECK: ret i1 %hlsl.any
bool test_any_float3x1(float3x1 p0) { return any(p0); }

// CHECK-LABEL: test_any_float3x2
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6f32
// CHECK: ret i1 %hlsl.any
bool test_any_float3x2(float3x2 p0) { return any(p0); }

// CHECK-LABEL: test_any_float3x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v9f32
// CHECK: ret i1 %hlsl.any
bool test_any_float3x3(float3x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_float4x4
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v16f32
// CHECK: ret i1 %hlsl.any
bool test_any_float4x4(float4x4 p0) { return any(p0); }

// CHECK-LABEL: test_any_double1x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3f64
// CHECK: ret i1 %hlsl.any
bool test_any_double1x3(double1x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_double2x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6f64
// CHECK: ret i1 %hlsl.any
bool test_any_double2x3(double2x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_double3x1
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3f64
// CHECK: ret i1 %hlsl.any
bool test_any_double3x1(double3x1 p0) { return any(p0); }

// CHECK-LABEL: test_any_double3x2
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6f64
// CHECK: ret i1 %hlsl.any
bool test_any_double3x2(double3x2 p0) { return any(p0); }

// CHECK-LABEL: test_any_double3x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v9f64
// CHECK: ret i1 %hlsl.any
bool test_any_double3x3(double3x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_double4x4
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v16f64
// CHECK: ret i1 %hlsl.any
bool test_any_double4x4(double4x4 p0) { return any(p0); }

// CHECK-LABEL: test_any_int1x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3i32
// CHECK: ret i1 %hlsl.any
bool test_any_int1x3(int1x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_int2x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6i32
// CHECK: ret i1 %hlsl.any
bool test_any_int2x3(int2x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_int3x1
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3i32
// CHECK: ret i1 %hlsl.any
bool test_any_int3x1(int3x1 p0) { return any(p0); }

// CHECK-LABEL: test_any_int3x2
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6i32
// CHECK: ret i1 %hlsl.any
bool test_any_int3x2(int3x2 p0) { return any(p0); }

// CHECK-LABEL: test_any_int3x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v9i32
// CHECK: ret i1 %hlsl.any
bool test_any_int3x3(int3x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_int4x4
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v16i32
// CHECK: ret i1 %hlsl.any
bool test_any_int4x4(int4x4 p0) { return any(p0); }

// CHECK-LABEL: test_any_uint1x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3i32
// CHECK: ret i1 %hlsl.any
bool test_any_uint1x3(uint1x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_uint2x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6i32
// CHECK: ret i1 %hlsl.any
bool test_any_uint2x3(uint2x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_uint3x1
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3i32
// CHECK: ret i1 %hlsl.any
bool test_any_uint3x1(uint3x1 p0) { return any(p0); }

// CHECK-LABEL: test_any_uint3x2
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6i32
// CHECK: ret i1 %hlsl.any
bool test_any_uint3x2(uint3x2 p0) { return any(p0); }

// CHECK-LABEL: test_any_uint3x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v9i32
// CHECK: ret i1 %hlsl.any
bool test_any_uint3x3(uint3x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_uint4x4
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v16i32
// CHECK: ret i1 %hlsl.any
bool test_any_uint4x4(uint4x4 p0) { return any(p0); }

// CHECK-LABEL: test_any_int64_t1x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3i64
// CHECK: ret i1 %hlsl.any
bool test_any_int64_t1x3(int64_t1x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_int64_t2x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6i64
// CHECK: ret i1 %hlsl.any
bool test_any_int64_t2x3(int64_t2x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_int64_t3x1
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3i64
// CHECK: ret i1 %hlsl.any
bool test_any_int64_t3x1(int64_t3x1 p0) { return any(p0); }

// CHECK-LABEL: test_any_int64_t3x2
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6i64
// CHECK: ret i1 %hlsl.any
bool test_any_int64_t3x2(int64_t3x2 p0) { return any(p0); }

// CHECK-LABEL: test_any_int64_t3x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v9i64
// CHECK: ret i1 %hlsl.any
bool test_any_int64_t3x3(int64_t3x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_int64_t4x4
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v16i64
// CHECK: ret i1 %hlsl.any
bool test_any_int64_t4x4(int64_t4x4 p0) { return any(p0); }

// CHECK-LABEL: test_any_uint64_t1x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3i64
// CHECK: ret i1 %hlsl.any
bool test_any_uint64_t1x3(uint64_t1x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_uint64_t2x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6i64
// CHECK: ret i1 %hlsl.any
bool test_any_uint64_t2x3(uint64_t2x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_uint64_t3x1
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3i64
// CHECK: ret i1 %hlsl.any
bool test_any_uint64_t3x1(uint64_t3x1 p0) { return any(p0); }

// CHECK-LABEL: test_any_uint64_t3x2
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6i64
// CHECK: ret i1 %hlsl.any
bool test_any_uint64_t3x2(uint64_t3x2 p0) { return any(p0); }

// CHECK-LABEL: test_any_uint64_t3x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v9i64
// CHECK: ret i1 %hlsl.any
bool test_any_uint64_t3x3(uint64_t3x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_uint64_t4x4
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v16i64
// CHECK: ret i1 %hlsl.any
bool test_any_uint64_t4x4(uint64_t4x4 p0) { return any(p0); }

// CHECK-LABEL: test_any_bool1x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3i1
// CHECK: ret i1 %hlsl.any
bool test_any_bool1x3(bool1x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_bool2x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6i1
// CHECK: ret i1 %hlsl.any
bool test_any_bool2x3(bool2x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_bool3x1
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v3i1
// CHECK: ret i1 %hlsl.any
bool test_any_bool3x1(bool3x1 p0) { return any(p0); }

// CHECK-LABEL: test_any_bool3x2
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v6i1
// CHECK: ret i1 %hlsl.any
bool test_any_bool3x2(bool3x2 p0) { return any(p0); }

// CHECK-LABEL: test_any_bool3x3
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v9i1
// CHECK: ret i1 %hlsl.any
bool test_any_bool3x3(bool3x3 p0) { return any(p0); }

// CHECK-LABEL: test_any_bool4x4
// CHECK: %hlsl.any = call i1 @llvm.[[TARGET]].any.v16i1
// CHECK: ret i1 %hlsl.any
bool test_any_bool4x4(bool4x4 p0) { return any(p0); }
