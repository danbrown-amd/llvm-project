// RUN: %clang_cc1 -finclude-default-header -x hlsl -triple dxil-pc-shadermodel6.6-library %s -fnative-half-type -fnative-int16-type -emit-llvm-only -disable-llvm-passes -verify -verify-ignore-unexpected=note

float test_too_few_arg() {
  return radians();
  // expected-error@-1 {{no matching function for call to 'radians'}}
}

float2 test_too_many_arg(float2 p0) {
  return radians(p0, p0);
  // expected-error@-1 {{no matching function for call to 'radians'}}
}

float builtin_bool_to_float_type_promotion(bool p1) {
  return radians(p1);
  // expected-error@-1 {{call to 'radians' is ambiguous}}
}

float builtin_radians_int_to_float_promotion(int p1) {
  return radians(p1);
  // expected-warning@-1 {{'radians' is deprecated: In 202x int lowering for radians is deprecated. Explicitly cast parameters to float types.}}
}

float2 builtin_radians_int2_to_float2_promotion(int2 p1) {
  return radians(p1);
  // expected-warning@-1 {{'radians' is deprecated: In 202x int lowering for radians is deprecated. Explicitly cast parameters to float types.}}
}
