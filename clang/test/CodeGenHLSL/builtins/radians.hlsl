// RUN: %clang_cc1 -finclude-default-header -x hlsl -triple \
// RUN:   dxil-pc-shadermodel6.3-library %s -fnative-half-type -fnative-int16-type \
// RUN:   -emit-llvm -disable-llvm-passes -o - | FileCheck %s \
// RUN:   --check-prefix=NATIVE_HALF
// RUN: %clang_cc1 -finclude-default-header -x hlsl -triple \
// RUN:   dxil-pc-shadermodel6.3-library %s -emit-llvm -disable-llvm-passes \
// RUN:   -o - | FileCheck %s --check-prefix=NO_HALF
// RUN: %clang_cc1 -finclude-default-header -x hlsl -triple \
// RUN:   spirv-unknown-vulkan-library %s -fnative-half-type -fnative-int16-type \
// RUN:   -emit-llvm -disable-llvm-passes -o - | FileCheck %s \
// RUN:   --check-prefix=NATIVE_HALF
// RUN: %clang_cc1 -finclude-default-header -x hlsl -triple \
// RUN:   spirv-unknown-vulkan-library %s -emit-llvm -disable-llvm-passes \
// RUN:   -o - | FileCheck %s --check-prefix=NO_HALF

// NATIVE_HALF-LABEL: define {{.*}} half @_ZN4hlsl8__detail12radians_implIDhEET_S2_
// NATIVE_HALF: %{{.*}} = fpext {{.*}} half %{{.*}} to float
// NATIVE_HALF: %{{.*}} = fmul {{.*}} float %{{.*}}, [[FD2R:f0x[0-9A-F]+]]
// NATIVE_HALF: %{{.*}} = fptrunc {{.*}} float %{{.*}} to half
// NATIVE_HALF: ret half %{{.*}}
// NO_HALF-LABEL: define {{.*}} float @_ZN4hlsl8__detail12radians_implIfEET_S2_
// NO_HALF: %{{.*}} = fmul {{.*}} float %{{.*}}, [[FD2R:f0x[0-9A-F]+]]
// NO_HALF: ret float %{{.*}}
half test_radians_half(half p0) { return radians(p0); }

// NATIVE_HALF-LABEL: define {{.*}} <2 x half> @_ZN4hlsl8__detail12radians_implIDv2_DhEET_S3_
// NATIVE_HALF: %{{.*}} = fpext {{.*}} <2 x half> %{{.*}} to <2 x float>
// NATIVE_HALF: %{{.*}} = fmul {{.*}} <2 x float> %{{.*}}, splat (float [[FD2R]])
// NATIVE_HALF: %{{.*}} = fptrunc {{.*}} <2 x float> %{{.*}} to <2 x half>
// NATIVE_HALF: ret <2 x half> %{{.*}}
// NO_HALF-LABEL: define {{.*}} <2 x float> @_ZN4hlsl8__detail12radians_implIDv2_fEET_S3_
// NO_HALF: %{{.*}} = fmul {{.*}} <2 x float> %{{.*}}, splat (float [[FD2R]])
// NO_HALF: ret <2 x float> %{{.*}}
half2 test_radians_half2(half2 p0) { return radians(p0); }

// NATIVE_HALF-LABEL: define {{.*}} <3 x half> @_ZN4hlsl8__detail12radians_implIDv3_DhEET_S3_
// NATIVE_HALF: %{{.*}} = fpext {{.*}} <3 x half> %{{.*}} to <3 x float>
// NATIVE_HALF: %{{.*}} = fmul {{.*}} <3 x float> %{{.*}}, splat (float [[FD2R]])
// NATIVE_HALF: %{{.*}} = fptrunc {{.*}} <3 x float> %{{.*}} to <3 x half>
// NATIVE_HALF: ret <3 x half> %{{.*}}
// NO_HALF-LABEL: define {{.*}} <3 x float> @_ZN4hlsl8__detail12radians_implIDv3_fEET_S3_
// NO_HALF: %{{.*}} = fmul {{.*}} <3 x float> %{{.*}}, splat (float [[FD2R]])
// NO_HALF: ret <3 x float> %{{.*}}
half3 test_radians_half3(half3 p0) { return radians(p0); }

// NATIVE_HALF-LABEL: define {{.*}} <4 x half> @_ZN4hlsl8__detail12radians_implIDv4_DhEET_S3_
// NATIVE_HALF: %{{.*}} = fpext {{.*}} <4 x half> %{{.*}} to <4 x float>
// NATIVE_HALF: %{{.*}} = fmul {{.*}} <4 x float> %{{.*}}, splat (float [[FD2R]])
// NATIVE_HALF: %{{.*}} = fptrunc {{.*}} <4 x float> %{{.*}} to <4 x half>
// NATIVE_HALF: ret <4 x half> %{{.*}}
// NO_HALF-LABEL: define {{.*}} <4 x float> @_ZN4hlsl8__detail12radians_implIDv4_fEET_S3_
// NO_HALF: %{{.*}} = fmul {{.*}} <4 x float> %{{.*}}, splat (float [[FD2R]])
// NO_HALF: ret <4 x float> %{{.*}}
half4 test_radians_half4(half4 p0) { return radians(p0); }

// When native half is disabled, half is lowered to float, so radians_impl<float>
// is already emitted and matched above by the NO_HALF half-function checks.
// Use NATIVE_HALF here to avoid matching the same linkonce_odr definition twice.
// NATIVE_HALF-LABEL: define {{.*}} float @_ZN4hlsl8__detail12radians_implIfEET_S2_
// NATIVE_HALF: %{{.*}} = fmul {{.*}} float %{{.*}}, [[FD2R]]
// NATIVE_HALF: ret float %{{.*}}
float test_radians_float(float p0) { return radians(p0); }

// NATIVE_HALF-LABEL: define {{.*}} <2 x float> @_ZN4hlsl8__detail12radians_implIDv2_fEET_S3_
// NATIVE_HALF: %{{.*}} = fmul {{.*}} <2 x float> %{{.*}}, splat (float [[FD2R]])
// NATIVE_HALF: ret <2 x float> %{{.*}}
float2 test_radians_float2(float2 p0) { return radians(p0); }

// NATIVE_HALF-LABEL: define {{.*}} <3 x float> @_ZN4hlsl8__detail12radians_implIDv3_fEET_S3_
// NATIVE_HALF: %{{.*}} = fmul {{.*}} <3 x float> %{{.*}}, splat (float [[FD2R]])
// NATIVE_HALF: ret <3 x float> %{{.*}}
float3 test_radians_float3(float3 p0) { return radians(p0); }

// NATIVE_HALF-LABEL: define {{.*}} <4 x float> @_ZN4hlsl8__detail12radians_implIDv4_fEET_S3_
// NATIVE_HALF: %{{.*}} = fmul {{.*}} <4 x float> %{{.*}}, splat (float [[FD2R]])
// NATIVE_HALF: ret <4 x float> %{{.*}}
float4 test_radians_float4(float4 p0) { return radians(p0); }
