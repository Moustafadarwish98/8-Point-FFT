module bit_reversal #(
    parameter WI_INT   = 6,
    WI_FRAC  = 6,
    IP_WIDTH = WI_FRAC + WI_INT)
  (
    input wire signed [IP_WIDTH - 1:0] in0_r,
    input wire signed [IP_WIDTH - 1:0] in1_r,
    input wire signed [IP_WIDTH - 1:0] in2_r,
    input wire signed [IP_WIDTH - 1:0] in3_r,
    input wire signed [IP_WIDTH - 1:0] in4_r,
    input wire signed [IP_WIDTH - 1:0] in5_r,
    input wire signed [IP_WIDTH - 1:0] in6_r,
    input wire signed [IP_WIDTH - 1:0] in7_r,
    input wire signed [IP_WIDTH - 1:0] in0_imag,
    input wire signed [IP_WIDTH - 1:0] in1_imag,
    input wire signed [IP_WIDTH - 1:0] in2_imag,
    input wire signed [IP_WIDTH - 1:0] in3_imag,
    input wire signed [IP_WIDTH - 1:0] in4_imag,
    input wire signed [IP_WIDTH - 1:0] in5_imag,
    input wire signed [IP_WIDTH - 1:0] in6_imag,
    input wire signed [IP_WIDTH - 1:0] in7_imag,

    output wire signed [IP_WIDTH - 1:0] in0_reversed_r,
    output wire signed [IP_WIDTH - 1:0] in1_reversed_r,
    output wire signed [IP_WIDTH - 1:0] in2_reversed_r,
    output wire signed [IP_WIDTH - 1:0] in3_reversed_r,
    output wire signed [IP_WIDTH - 1:0] in4_reversed_r,
    output wire signed [IP_WIDTH - 1:0] in5_reversed_r,
    output wire signed [IP_WIDTH - 1:0] in6_reversed_r,
    output wire signed [IP_WIDTH - 1:0] in7_reversed_r,
    output wire signed [IP_WIDTH - 1:0] in0_reversed_imag,
    output wire signed [IP_WIDTH - 1:0] in1_reversed_imag,
    output wire signed [IP_WIDTH - 1:0] in2_reversed_imag,
    output wire signed [IP_WIDTH - 1:0] in3_reversed_imag,
    output wire signed [IP_WIDTH - 1:0] in4_reversed_imag,
    output wire signed [IP_WIDTH - 1:0] in5_reversed_imag,
    output wire signed [IP_WIDTH - 1:0] in6_reversed_imag,
    output wire signed [IP_WIDTH - 1:0] in7_reversed_imag
  );

  // Bit reversal logic
  assign in0_reversed_r = in0_r;
  assign in1_reversed_r = in4_r;
  assign in2_reversed_r = in2_r;
  assign in3_reversed_r = in6_r;
  assign in4_reversed_r = in1_r;
  assign in5_reversed_r = in5_r;
  assign in6_reversed_r = in3_r;
  assign in7_reversed_r = in7_r;
  assign in0_reversed_imag = in0_imag;
  assign in1_reversed_imag = in4_imag;
  assign in2_reversed_imag = in2_imag;
  assign in3_reversed_imag = in6_imag;
  assign in4_reversed_imag = in1_imag;
  assign in5_reversed_imag = in5_imag;
  assign in6_reversed_imag = in3_imag;
  assign in7_reversed_imag = in7_imag;
endmodule




