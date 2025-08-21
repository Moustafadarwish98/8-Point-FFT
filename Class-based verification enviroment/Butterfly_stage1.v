module stage1_butterfly #(
    parameter WIDTH = 12,
    parameter WI_INT = 6,
    parameter WI_FRAC = WIDTH - WI_INT,
    parameter WO_INT = 7,
    parameter WO_FRAC = WIDTH - WO_INT,
    parameter OP_WIDTH = WO_FRAC + WO_INT,
    parameter IP_WIDTH = WI_FRAC + WI_INT,
    parameter ROUND = 0
  )(
    input  wire clk,
    input  wire rst_n,
    input  wire signed [IP_WIDTH-1:0] in0_r,
    input  wire signed [IP_WIDTH-1:0] in1_r,
    input  wire signed [IP_WIDTH-1:0] in2_r,
    input  wire signed [IP_WIDTH-1:0] in3_r,
    input  wire signed [IP_WIDTH-1:0] in4_r,
    input  wire signed [IP_WIDTH-1:0] in5_r,
    input  wire signed [IP_WIDTH-1:0] in6_r,
    input  wire signed [IP_WIDTH-1:0] in7_r,
    input  wire signed [IP_WIDTH-1:0] in0_imag,
    input  wire signed [IP_WIDTH-1:0] in1_imag,
    input  wire signed [IP_WIDTH-1:0] in2_imag,
    input  wire signed [IP_WIDTH-1:0] in3_imag,
    input  wire signed [IP_WIDTH-1:0] in4_imag,
    input  wire signed [IP_WIDTH-1:0] in5_imag,
    input  wire signed [IP_WIDTH-1:0] in6_imag,
    input  wire signed [IP_WIDTH-1:0] in7_imag,

    output reg signed [OP_WIDTH-1:0] stage1_out0_r,
    output reg signed [OP_WIDTH-1:0] stage1_out1_r,
    output reg signed [OP_WIDTH-1:0] stage1_out2_r,
    output reg signed [OP_WIDTH-1:0] stage1_out3_r,
    output reg signed [OP_WIDTH-1:0] stage1_out4_r,
    output reg signed [OP_WIDTH-1:0] stage1_out5_r,
    output reg signed [OP_WIDTH-1:0] stage1_out6_r,
    output reg signed [OP_WIDTH-1:0] stage1_out7_r,
    output reg signed [OP_WIDTH-1:0] stage1_out0_imag,
    output reg signed [OP_WIDTH-1:0] stage1_out1_imag,
    output reg signed [OP_WIDTH-1:0] stage1_out2_imag,
    output reg signed [OP_WIDTH-1:0] stage1_out3_imag,
    output reg signed [OP_WIDTH-1:0] stage1_out4_imag,
    output reg signed [OP_WIDTH-1:0] stage1_out5_imag,
    output reg signed [OP_WIDTH-1:0] stage1_out6_imag,
    output reg signed [OP_WIDTH-1:0] stage1_out7_imag
  );

  // Internal wires for fxp results
  wire [OP_WIDTH-1:0] temp_r [0:7]; 
  wire [OP_WIDTH-1:0] temp_i [0:7];
  wire overflow [0:7];
  wire overflow_i [0:7];
  
  // Butterfly calculations using fixed-point module
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) add0_r (
               .operand_a(in0_r), .operand_b(in1_r), .subtract(1'b0), .result(temp_r[0]), .overflow(overflow[0])
             );
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) sub0_r (
               .operand_a(in0_r), .operand_b(in1_r), .subtract(1'b1), .result(temp_r[1]), .overflow(overflow[1])
             );
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) add1_r (
               .operand_a(in2_r), .operand_b(in3_r), .subtract(1'b0), .result(temp_r[2]), .overflow(overflow[2])
             );
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) sub1_r (
               .operand_a(in2_r), .operand_b(in3_r), .subtract(1'b1), .result(temp_r[3]), .overflow(overflow[3])
             );
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) add2_r (
               .operand_a(in4_r), .operand_b(in5_r), .subtract(1'b0), .result(temp_r[4]), .overflow(overflow[4])
             );
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) sub2_r (
               .operand_a(in4_r), .operand_b(in5_r), .subtract(1'b1), .result(temp_r[5]), .overflow(overflow[5])
             );
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) add3_r (
               .operand_a(in6_r), .operand_b(in7_r), .subtract(1'b0), .result(temp_r[6]), .overflow(overflow[6])
             );
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) sub3_r (
               .operand_a(in6_r), .operand_b(in7_r), .subtract(1'b1), .result(temp_r[7]), .overflow(overflow[7])
             );

  // Imaginary parts
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) add0_i (
               .operand_a(in0_imag), .operand_b(in1_imag), .subtract(1'b0), .result(temp_i[0]), .overflow(overflow_i[0])
             );
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) sub0_i (
               .operand_a(in0_imag), .operand_b(in1_imag), .subtract(1'b1), .result(temp_i[1]), .overflow(overflow_i[1])
             );
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) add1_i (
               .operand_a(in2_imag), .operand_b(in3_imag), .subtract(1'b0), .result(temp_i[2]), .overflow(overflow_i[2])
             );
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) sub1_i (
               .operand_a(in2_imag), .operand_b(in3_imag), .subtract(1'b1), .result(temp_i[3]), .overflow(overflow_i[3])
             );
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) add2_i (
               .operand_a(in4_imag), .operand_b(in5_imag), .subtract(1'b0), .result(temp_i[4]), .overflow(overflow_i[4])
             );
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) sub2_i (
               .operand_a(in4_imag), .operand_b(in5_imag), .subtract(1'b1), .result(temp_i[5]), .overflow(overflow_i[5])
             );
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) add3_i (
               .operand_a(in6_imag), .operand_b(in7_imag), .subtract(1'b0), .result(temp_i[6]), .overflow(overflow_i[6])
             );
  fxp_addsub #(WI_INT, WI_FRAC, WI_INT, WI_FRAC, WO_INT, WO_FRAC, ROUND ) sub3_i (
               .operand_a(in6_imag), .operand_b(in7_imag), .subtract(1'b1), .result(temp_i[7]), .overflow(overflow_i[7])
             );

  always @(posedge clk )
  begin
    if (!rst_n)
    begin
      stage1_out0_r <= 0;
      stage1_out1_r <= 0;
      stage1_out2_r <= 0;
      stage1_out3_r <= 0;
      stage1_out4_r <= 0;
      stage1_out5_r <= 0;
      stage1_out6_r <= 0;
      stage1_out7_r <= 0;
      stage1_out0_imag <= 0;
      stage1_out1_imag <= 0;
      stage1_out2_imag <= 0;
      stage1_out3_imag <= 0;
      stage1_out4_imag <= 0;
      stage1_out5_imag <= 0;
      stage1_out6_imag <= 0;
      stage1_out7_imag <= 0;
    end
    else
    begin
      // Assign to outputs
      stage1_out0_r <= temp_r[0];
      stage1_out1_r <= temp_r[1];
      stage1_out2_r <= temp_r[2];
      stage1_out3_r <= temp_r[3];
      stage1_out4_r <= temp_r[4];
      stage1_out5_r <= temp_r[5];
      stage1_out6_r <= temp_r[6];
      stage1_out7_r <= temp_r[7];

      stage1_out0_imag <= temp_i[0];
      stage1_out1_imag <= temp_i[1];
      stage1_out2_imag <= temp_i[2];
      stage1_out3_imag <= temp_i[3];
      stage1_out4_imag <= temp_i[4];
      stage1_out5_imag <= temp_i[5];
      stage1_out6_imag <= temp_i[6];
      stage1_out7_imag <= temp_i[7];
    end
  end

endmodule
