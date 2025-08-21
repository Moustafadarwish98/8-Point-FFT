module output_wire #(
    parameter WO_INT   = 8,
    WO_FRAC  = 4,
    OP_WIDTH = WO_FRAC + WO_INT)
  (
    input wire signed [OP_WIDTH - 1:0] in0_r,
    input wire signed [OP_WIDTH - 1:0] in1_r,
    input wire signed [OP_WIDTH - 1:0] in2_r,
    input wire signed [OP_WIDTH - 1:0] in3_r,
    input wire signed [OP_WIDTH - 1:0] in4_r,
    input wire signed [OP_WIDTH - 1:0] in5_r,
    input wire signed [OP_WIDTH - 1:0] in6_r,
    input wire signed [OP_WIDTH - 1:0] in7_r,
    input wire signed [OP_WIDTH - 1:0] in0_i,
    input wire signed [OP_WIDTH - 1:0] in1_i,
    input wire signed [OP_WIDTH - 1:0] in2_i,
    input wire signed [OP_WIDTH - 1:0] in3_i,
    input wire signed [OP_WIDTH - 1:0] in4_i,
    input wire signed [OP_WIDTH - 1:0] in5_i,
    input wire signed [OP_WIDTH - 1:0] in6_i,
    input wire signed [OP_WIDTH - 1:0] in7_i,

    output wire signed [OP_WIDTH - 1:0] out0_r,
    output wire signed [OP_WIDTH - 1:0] out0_i,
    output wire signed [OP_WIDTH - 1:0] out1_r,
    output wire signed [OP_WIDTH - 1:0] out1_i,
    output wire signed [OP_WIDTH - 1:0] out2_i,
    output wire signed [OP_WIDTH - 1:0] out2_r,
    output wire signed [OP_WIDTH - 1:0] out3_i,
    output wire signed [OP_WIDTH - 1:0] out3_r,
    output wire signed [OP_WIDTH - 1:0] out4_i,
    output wire signed [OP_WIDTH - 1:0] out4_r,
    output wire signed [OP_WIDTH - 1:0] out5_r,
    output wire signed [OP_WIDTH - 1:0] out5_i,
    output wire signed [OP_WIDTH - 1:0] out6_r,
    output wire signed [OP_WIDTH - 1:0] out6_i,
    output wire signed [OP_WIDTH - 1:0] out7_r,
    output wire signed [OP_WIDTH - 1:0] out7_i
  );

  assign out0_r = in0_r;
  assign out1_r = in4_r;
  assign out2_r = in2_r;
  assign out3_r = in6_r;
  assign out4_r = in1_r;
  assign out5_r = in5_r;
  assign out6_r = in3_r;
  assign out7_r = in7_r;
  assign out0_i = in0_i;
  assign out1_i = in4_i;
  assign out2_i = in2_i;
  assign out3_i = in6_i;
  assign out4_i = in1_i;
  assign out5_i = in5_i;
  assign out6_i = in3_i;
  assign out7_i = in7_i;
endmodule
