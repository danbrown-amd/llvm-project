// RUN: %clang_cc1 -finclude-default-header -x hlsl -triple dxil-pc-shadermodel6.6-library %s -fnative-half-type -fnative-int16-type -emit-llvm-only -disable-llvm-passes -verify -verify-ignore-unexpected=note

float test_too_few_arg() {
  return degrees();
  // expected-error@-1 {{no matching function for call to 'degrees'}}
}

float2 test_too_many_arg(float2 p0) {
  return degrees(p0, p0);
  // expected-error@-1 {{no matching function for call to 'degrees'}}
}

float builtin_bool_to_float_type_promotion(bool p1) {
  return degrees(p1);
  // expected-error@-1 {{call to 'degrees' is ambiguous}}
}

float builtin_degrees_int_to_float_promotion(int p1) {
  return degrees(p1);
  // expected-warning@-1 {{'degrees' is deprecated: In 202x int lowering for degrees is deprecated. Explicitly cast parameters to float types.}}
}

float2 builtin_degrees_int2_to_float2_promotion(int2 p1) {
  return degrees(p1);
  // expected-warning@-1 {{'degrees' is deprecated: In 202x int lowering for degrees is deprecated. Explicitly cast parameters to float types.}}
}
