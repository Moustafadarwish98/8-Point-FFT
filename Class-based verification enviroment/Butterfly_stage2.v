module stage2_butterfly #(
    parameter WIDTH = 12,
    parameter WI_INT = 7,
    parameter WI_FRAC = WIDTH - WI_INT,
    parameter WO_INT = 7,
    parameter WO_FRAC = WIDTH - WO_INT,
    parameter OP_WIDTH = WO_FRAC + WO_INT,
    parameter IP_WIDTH = WI_FRAC + WI_INT,
    parameter ROUND = 0,
    parameter TW_FRAC = 10,
    parameter TW_IN = 2
  )(
    input wire clk,
    input wire rst_n,
    input wire signed [IP_WIDTH-1:0] in0_r,
    input wire signed [IP_WIDTH-1:0] in1_r,
    input wire signed [IP_WIDTH-1:0] in2_r,
    input wire signed [IP_WIDTH-1:0] in3_r,
    input wire signed [IP_WIDTH-1:0] in4_r,
    input wire signed [IP_WIDTH-1:0] in5_r,
    input wire signed [IP_WIDTH-1:0] in6_r,
    input wire signed [IP_WIDTH-1:0] in7_r,
    input wire signed [IP_WIDTH-1:0] in0_imag,
    input wire signed [IP_WIDTH-1:0] in1_imag,
    input wire signed [IP_WIDTH-1:0] in2_imag,
    input wire signed [IP_WIDTH-1:0] in3_imag,
    input wire signed [IP_WIDTH-1:0] in4_imag,
    input wire signed [IP_WIDTH-1:0] in5_imag,
    input wire signed [IP_WIDTH-1:0] in6_imag,
    input wire signed [IP_WIDTH-1:0] in7_imag,

    output reg signed [OP_WIDTH-1:0] stage2_out0_r,
    output reg signed [OP_WIDTH-1:0] stage2_out1_r,
    output reg signed [OP_WIDTH-1:0] stage2_out2_r,
    output reg signed [OP_WIDTH-1:0] stage2_out3_r,
    output reg signed [OP_WIDTH-1:0] stage2_out4_r,
    output reg signed [OP_WIDTH-1:0] stage2_out5_r,
    output reg signed [OP_WIDTH-1:0] stage2_out6_r,
    output reg signed [OP_WIDTH-1:0] stage2_out7_r,
    output reg signed [OP_WIDTH-1:0] stage2_out0_imag,
    output reg signed [OP_WIDTH-1:0] stage2_out1_imag,
    output reg signed [OP_WIDTH-1:0] stage2_out2_imag,
    output reg signed [OP_WIDTH-1:0] stage2_out3_imag,
    output reg signed [OP_WIDTH-1:0] stage2_out4_imag,
    output reg signed [OP_WIDTH-1:0] stage2_out5_imag,
    output reg signed [OP_WIDTH-1:0] stage2_out6_imag,
    output reg signed [OP_WIDTH-1:0] stage2_out7_imag
  );

  // --------------------------------------------------------
  // Twiddle multiply for groups
  // For (1,3) and (5,7), multiply second input by -j
  // directly (a + jb) * (-j) =  b - ja --> instead of using a complex multiplier
  // --------------------------------------------------------

  // Twiddle applied versions of inputs
  wire signed [IP_WIDTH-1:0] w2_r, w2_i;
  wire signed [IP_WIDTH-1:0] w3_r, w3_i;
  wire signed [IP_WIDTH-1:0] w6_r, w6_i;
  wire signed [IP_WIDTH-1:0] w7_r, w7_i;

  // multiply in2, in3, in6, in7 by twiddles
  assign w2_r = in2_r;        // twiddle = 1
  assign w2_i = in2_imag;

  assign w3_r =  in3_imag;    // twiddle = -j
  assign w3_i = -in3_r;

  assign w6_r = in6_r;        // twiddle = 1
  assign w6_i = in6_imag;

  assign w7_r =  in7_imag;    // twiddle = -j
  assign w7_i = -in7_r;

  // --------------------------------------------------------
  // Butterfly outputs: (a+b), (a-b)
  // --------------------------------------------------------
  wire [OP_WIDTH-1:0] temp_r [0:7];
  wire [OP_WIDTH-1:0] temp_i [0:7];
  wire overflow [0:7];
  wire overflow_i [0:7];

  // Butterfly (0,2)
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             add0_r (.operand_a(in0_r), .operand_b(w2_r), .subtract(1'b0), .result(temp_r[0]), .overflow(overflow[0]));
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             sub0_r (.operand_a(in0_r), .operand_b(w2_r), .subtract(1'b1), .result(temp_r[2]), .overflow(overflow[2]));

  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             add0_i (.operand_a(in0_imag), .operand_b(w2_i), .subtract(1'b0), .result(temp_i[0]), .overflow(overflow_i[0]));
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             sub0_i (.operand_a(in0_imag), .operand_b(w2_i), .subtract(1'b1), .result(temp_i[2]), .overflow(overflow_i[2]));

  // Butterfly (1,3)
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             add1_r (.operand_a(in1_r), .operand_b(w3_r), .subtract(1'b0), .result(temp_r[1]), .overflow(overflow[1]));
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             sub1_r (.operand_a(in1_r), .operand_b(w3_r), .subtract(1'b1), .result(temp_r[3]), .overflow(overflow[3]));

  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             add1_i (.operand_a(in1_imag), .operand_b(w3_i), .subtract(1'b0), .result(temp_i[1]), .overflow(overflow_i[1]));
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             sub1_i (.operand_a(in1_imag), .operand_b(w3_i), .subtract(1'b1), .result(temp_i[3]), .overflow(overflow_i[3]));

  // Butterfly (4,6)
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             add2_r (.operand_a(in4_r), .operand_b(w6_r), .subtract(1'b0), .result(temp_r[4]), .overflow(overflow[4]));
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             sub2_r (.operand_a(in4_r), .operand_b(w6_r), .subtract(1'b1), .result(temp_r[6]), .overflow(overflow[6]));

  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             add2_i (.operand_a(in4_imag), .operand_b(w6_i), .subtract(1'b0), .result(temp_i[4]), .overflow(overflow_i[4]));
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             sub2_i (.operand_a(in4_imag), .operand_b(w6_i), .subtract(1'b1), .result(temp_i[6]), .overflow(overflow_i[6]));

  // Butterfly (5,7)
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             add3_r (.operand_a(in5_r), .operand_b(w7_r), .subtract(1'b0), .result(temp_r[5]), .overflow(overflow[5]));
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             sub3_r (.operand_a(in5_r), .operand_b(w7_r), .subtract(1'b1), .result(temp_r[7]), .overflow(overflow[7]));

  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             add3_i (.operand_a(in5_imag), .operand_b(w7_i), .subtract(1'b0), .result(temp_i[5]), .overflow(overflow_i[5]));
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND)
             sub3_i (.operand_a(in5_imag), .operand_b(w7_i), .subtract(1'b1), .result(temp_i[7]), .overflow(overflow_i[7]));

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      stage2_out0_r <= 0;
      stage2_out0_imag <= 0;
      stage2_out1_r <= 0;
      stage2_out1_imag <= 0;
      stage2_out2_r <= 0;
      stage2_out2_imag <= 0;
      stage2_out3_r <= 0;
      stage2_out3_imag <= 0;
      stage2_out4_r <= 0;
      stage2_out4_imag <= 0;
      stage2_out5_r <= 0;
      stage2_out5_imag <= 0;
      stage2_out6_r <= 0;
      stage2_out6_imag <= 0;
      stage2_out7_r <= 0;
      stage2_out7_imag <= 0;
    end
    else
    begin
      stage2_out0_r <= temp_r[0];
      stage2_out0_imag <= temp_i[0];
      stage2_out1_r <= temp_r[1];
      stage2_out1_imag <= temp_i[1];
      stage2_out2_r <= temp_r[2];
      stage2_out2_imag <= temp_i[2];
      stage2_out3_r <= temp_r[3];
      stage2_out3_imag <= temp_i[3];
      stage2_out4_r <= temp_r[4];
      stage2_out4_imag <= temp_i[4];
      stage2_out5_r <= temp_r[5];
      stage2_out5_imag <= temp_i[5];
      stage2_out6_r <= temp_r[6];
      stage2_out6_imag <= temp_i[6];
      stage2_out7_r <= temp_r[7];
      stage2_out7_imag <= temp_i[7];
    end
  end

endmodule
