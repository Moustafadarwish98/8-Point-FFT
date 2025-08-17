module fft_top#(parameter WIDTH = 12,
                  WI_INT   = 6,
                  WI_FRAC  = WIDTH - WI_INT,
                  WO_INT   = 8,
                  WO_FRAC  = WIDTH - WO_INT,
                  OP_WIDTH = WO_FRAC + WO_INT,
                  TW_FRAC = 10,
                  TW_IN = 2,
                  IP_WIDTH = WI_FRAC + WI_INT)
  (input wire signed [IP_WIDTH - 1:0] in0_r,
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
   input wire clk,
   input wire rst_n,

   output wire signed [OP_WIDTH - 1:0] out0_r,
   output wire signed [OP_WIDTH - 1:0] out1_r,
   output wire signed [OP_WIDTH - 1:0] out2_r,
   output wire signed [OP_WIDTH - 1:0] out3_r,
   output wire signed [OP_WIDTH - 1:0] out4_r,
   output wire signed [OP_WIDTH - 1:0] out5_r,
   output wire signed [OP_WIDTH - 1:0] out6_r,
   output wire signed [OP_WIDTH - 1:0] out7_r,
   output wire signed [OP_WIDTH - 1:0] out0_imag,
   output wire signed [OP_WIDTH - 1:0] out1_imag,
   output wire signed [OP_WIDTH - 1:0] out2_imag,
   output wire signed [OP_WIDTH - 1:0] out3_imag,
   output wire signed [OP_WIDTH - 1:0] out4_imag,
   output wire signed [OP_WIDTH - 1:0] out5_imag,
   output wire signed [OP_WIDTH - 1:0] out6_imag,
   output wire signed [OP_WIDTH - 1:0] out7_imag
  );
  parameter STAGE_1_OUT_INT = 7 ;
  parameter STAGE_1_OUT_FRAC = WIDTH - STAGE_1_OUT_INT;
  parameter STAGE_2_OUT_INT = 7;
  parameter STAGE_2_OUT_FRAC = WIDTH - STAGE_2_OUT_INT;
  parameter STAGE_3_OUT_INT = 8;
  parameter STAGE_3_OUT_FRAC = WIDTH - STAGE_3_OUT_INT;

  // ROM arrays for twiddle factors, Q1.11 format
  localparam reg signed [IP_WIDTH -1:0] W8_REAL [0:7] = '{
               (1 << TW_FRAC),    // W8^0 = cos(0)
               0.707106*(1 << TW_FRAC),    // W8^1 = cos(pi/4)
               0.000,    // W8^2 = cos(pi/2)
               -0.707106*(1 << TW_FRAC),    // W8^3 = cos(3pi/4)
               -(1 << TW_FRAC),    // W8^4 = cos(pi)
               -0.707106*(1 << TW_FRAC),    // W8^5 = cos(5pi/4)
               0.000,    // W8^6 = cos(3pi/2)
               0.707106*(1 << TW_FRAC)     // W8^7 = cos(7pi/4)
             };

  localparam reg signed [IP_WIDTH -1:0] W8_IMAG [0:7] = '{
               0.000,    // W8^0 = -sin(0)
               -0.707106*(1 << TW_FRAC),    // W8^1 = -sin(pi/4)
               -(1 << TW_FRAC),    // W8^2 = -sin(pi/2)
               -0.707106*(1 << TW_FRAC),    // W8^3 = -sin(3pi/4)
               0.000,    // W8^4 = -sin(pi)
               0.707106*(1 << TW_FRAC),    // W8^5 = -sin(5pi/4)
               (1 << TW_FRAC),    // W8^6 = -sin(3pi/2)
               0.707106*(1 << TW_FRAC)     // W8^7 = -sin(7pi/4)
             };

  //reversed inputs wires
  wire [IP_WIDTH - 1:0] in0_reversed_r;
  wire [IP_WIDTH - 1:0] in1_reversed_r;
  wire [IP_WIDTH - 1:0] in2_reversed_r;
  wire [IP_WIDTH - 1:0] in3_reversed_r;
  wire [IP_WIDTH - 1:0] in4_reversed_r;
  wire [IP_WIDTH - 1:0] in5_reversed_r;
  wire [IP_WIDTH - 1:0] in6_reversed_r;
  wire [IP_WIDTH - 1:0] in7_reversed_r;
  wire [IP_WIDTH - 1:0] in0_reversed_imag;
  wire [IP_WIDTH - 1:0] in1_reversed_imag;
  wire [IP_WIDTH - 1:0] in2_reversed_imag;
  wire [IP_WIDTH - 1:0] in3_reversed_imag;
  wire [IP_WIDTH - 1:0] in4_reversed_imag;
  wire [IP_WIDTH - 1:0] in5_reversed_imag;
  wire [IP_WIDTH - 1:0] in6_reversed_imag;
  wire [IP_WIDTH - 1:0] in7_reversed_imag;

  // Instantiate the bit_reversal
  bit_reversal #(WI_INT,WI_FRAC,IP_WIDTH) bit_reversal_inst (
                 .in0_r(in0_r),
                 .in1_r(in1_r),
                 .in2_r(in2_r),
                 .in3_r(in3_r),
                 .in4_r(in4_r),
                 .in5_r(in5_r),
                 .in6_r(in6_r),
                 .in7_r(in7_r),
                 .in0_imag(in0_imag),
                 .in1_imag(in1_imag),
                 .in2_imag(in2_imag),
                 .in3_imag(in3_imag),
                 .in4_imag(in4_imag),
                 .in5_imag(in5_imag),
                 .in6_imag(in6_imag),
                 .in7_imag(in7_imag),

                 .in0_reversed_r(in0_reversed_r),
                 .in1_reversed_r(in1_reversed_r),
                 .in2_reversed_r(in2_reversed_r),
                 .in3_reversed_r(in3_reversed_r),
                 .in4_reversed_r(in4_reversed_r),
                 .in5_reversed_r(in5_reversed_r),
                 .in6_reversed_r(in6_reversed_r),
                 .in7_reversed_r(in7_reversed_r),
                 .in0_reversed_imag(in0_reversed_imag),
                 .in1_reversed_imag(in1_reversed_imag),
                 .in2_reversed_imag(in2_reversed_imag),
                 .in3_reversed_imag(in3_reversed_imag),
                 .in4_reversed_imag(in4_reversed_imag),
                 .in5_reversed_imag(in5_reversed_imag),
                 .in6_reversed_imag(in6_reversed_imag),
                 .in7_reversed_imag(in7_reversed_imag)
               );

  //STAGE 1: BUTTERFLY\\

  // Stage 1 output wires / Stage 2 input wires
  wire [OP_WIDTH - 1:0] stage1_out0_r;
  wire [OP_WIDTH - 1:0] stage1_out1_r;
  wire [OP_WIDTH - 1:0] stage1_out2_r;
  wire [OP_WIDTH - 1:0] stage1_out3_r;
  wire [OP_WIDTH - 1:0] stage1_out4_r;
  wire [OP_WIDTH - 1:0] stage1_out5_r;
  wire [OP_WIDTH - 1:0] stage1_out6_r;
  wire [OP_WIDTH - 1:0] stage1_out7_r;
  wire [OP_WIDTH - 1:0] stage1_out0_i;
  wire [OP_WIDTH - 1:0] stage1_out1_i;
  wire [OP_WIDTH - 1:0] stage1_out2_i;
  wire [OP_WIDTH - 1:0] stage1_out3_i;
  wire [OP_WIDTH - 1:0] stage1_out4_i;
  wire [OP_WIDTH - 1:0] stage1_out5_i;
  wire [OP_WIDTH - 1:0] stage1_out6_i;
  wire [OP_WIDTH - 1:0] stage1_out7_i;

  // Instantiate the stage1_butterfly module
  stage1_butterfly #(.IP_WIDTH(IP_WIDTH), .OP_WIDTH(OP_WIDTH),.WI_INT(WI_INT),.WI_FRAC(WI_FRAC),.WO_INT(STAGE_1_OUT_INT),.WO_FRAC(STAGE_1_OUT_FRAC)) butterfly1_inst (
                     .clk(clk),
                     .rst_n(rst_n),
                     .in0_r(in0_reversed_r),
                     .in1_r(in1_reversed_r),
                     .in2_r(in2_reversed_r),
                     .in3_r(in3_reversed_r),
                     .in4_r(in4_reversed_r),
                     .in5_r(in5_reversed_r),
                     .in6_r(in6_reversed_r),
                     .in7_r(in7_reversed_r),
                     .in0_imag(in0_reversed_imag),
                     .in1_imag(in1_reversed_imag),
                     .in2_imag(in2_reversed_imag),
                     .in3_imag(in3_reversed_imag),
                     .in4_imag(in4_reversed_imag),
                     .in5_imag(in5_reversed_imag),
                     .in6_imag(in6_reversed_imag),
                     .in7_imag(in7_reversed_imag),
                     .stage1_out0_r(stage1_out0_r),
                     .stage1_out1_r(stage1_out1_r),
                     .stage1_out2_r(stage1_out2_r),
                     .stage1_out3_r(stage1_out3_r),
                     .stage1_out4_r(stage1_out4_r),
                     .stage1_out5_r(stage1_out5_r),
                     .stage1_out6_r(stage1_out6_r),
                     .stage1_out7_r(stage1_out7_r),
                     .stage1_out0_imag(stage1_out0_i),
                     .stage1_out1_imag(stage1_out1_i),
                     .stage1_out2_imag(stage1_out2_i),
                     .stage1_out3_imag(stage1_out3_i),
                     .stage1_out4_imag(stage1_out4_i),
                     .stage1_out5_imag(stage1_out5_i),
                     .stage1_out6_imag(stage1_out6_i),
                     .stage1_out7_imag(stage1_out7_i)
                   );

  //Stage 2 output wires / Stage 3 input wires
  wire [OP_WIDTH - 1:0] stage2_out0_r;
  wire [OP_WIDTH - 1:0] stage2_out1_r;
  wire [OP_WIDTH - 1:0] stage2_out2_r;
  wire [OP_WIDTH - 1:0] stage2_out3_r;
  wire [OP_WIDTH - 1:0] stage2_out4_r;
  wire [OP_WIDTH - 1:0] stage2_out5_r;
  wire [OP_WIDTH - 1:0] stage2_out6_r;
  wire [OP_WIDTH - 1:0] stage2_out7_r;
  wire [OP_WIDTH - 1:0] stage2_out0_i;
  wire [OP_WIDTH - 1:0] stage2_out1_i;
  wire [OP_WIDTH - 1:0] stage2_out2_i;
  wire [OP_WIDTH - 1:0] stage2_out3_i;
  wire [OP_WIDTH - 1:0] stage2_out4_i;
  wire [OP_WIDTH - 1:0] stage2_out5_i;
  wire [OP_WIDTH - 1:0] stage2_out6_i;
  wire [OP_WIDTH - 1:0] stage2_out7_i;

  //Instantiate Stage 2 butterfly
  stage2_butterfly #(.IP_WIDTH(IP_WIDTH), .OP_WIDTH(OP_WIDTH),.WI_INT(STAGE_1_OUT_INT),.WI_FRAC(STAGE_1_OUT_FRAC),.WO_INT(STAGE_2_OUT_INT),.WO_FRAC(STAGE_2_OUT_FRAC),.TW_FRAC(TW_FRAC), .TW_IN(TW_IN)) butterfly2_inst (
                     .clk(clk),
                     .rst_n(rst_n),
                     .in0_r(stage1_out0_r),
                     .in1_r(stage1_out1_r),
                     .in2_r(stage1_out2_r),
                     .in3_r(stage1_out3_r),
                     .in4_r(stage1_out4_r),
                     .in5_r(stage1_out5_r),
                     .in6_r(stage1_out6_r),
                     .in7_r(stage1_out7_r),
                     .in0_imag(stage1_out0_i),
                     .in1_imag(stage1_out1_i),
                     .in2_imag(stage1_out2_i),
                     .in3_imag(stage1_out3_i),
                     .in4_imag(stage1_out4_i),
                     .in5_imag(stage1_out5_i),
                     .in6_imag(stage1_out6_i),
                     .in7_imag(stage1_out7_i),
                     .stage2_out0_r(stage2_out0_r),
                     .stage2_out1_r(stage2_out1_r),
                     .stage2_out2_r(stage2_out2_r),
                     .stage2_out3_r(stage2_out3_r),
                     .stage2_out4_r(stage2_out4_r),
                     .stage2_out5_r(stage2_out5_r),
                     .stage2_out6_r(stage2_out6_r),
                     .stage2_out7_r(stage2_out7_r),
                     .stage2_out0_imag(stage2_out0_i),
                     .stage2_out1_imag(stage2_out1_i),
                     .stage2_out2_imag(stage2_out2_i),
                     .stage2_out3_imag(stage2_out3_i),
                     .stage2_out4_imag(stage2_out4_i),
                     .stage2_out5_imag(stage2_out5_i),
                     .stage2_out6_imag(stage2_out6_i),
                     .stage2_out7_imag(stage2_out7_i)
                   );

  wire [OP_WIDTH - 1:0] stage3_out0_r;
  wire [OP_WIDTH - 1:0] stage3_out1_r;
  wire [OP_WIDTH - 1:0] stage3_out2_r;
  wire [OP_WIDTH - 1:0] stage3_out3_r;
  wire [OP_WIDTH - 1:0] stage3_out4_r;
  wire [OP_WIDTH - 1:0] stage3_out5_r;
  wire [OP_WIDTH - 1:0] stage3_out6_r;
  wire [OP_WIDTH - 1:0] stage3_out7_r;
  wire [OP_WIDTH - 1:0] stage3_out0_i;
  wire [OP_WIDTH - 1:0] stage3_out1_i;
  wire [OP_WIDTH - 1:0] stage3_out2_i;
  wire [OP_WIDTH - 1:0] stage3_out3_i;
  wire [OP_WIDTH - 1:0] stage3_out4_i;
  wire [OP_WIDTH - 1:0] stage3_out5_i;
  wire [OP_WIDTH - 1:0] stage3_out6_i;
  wire [OP_WIDTH - 1:0] stage3_out7_i;

  //Instantiate butterfly 3
  stage3_butterfly #(.IP_WIDTH(IP_WIDTH), .OP_WIDTH(OP_WIDTH),.WI_INT(STAGE_2_OUT_INT),.WI_FRAC(STAGE_2_OUT_FRAC),.WO_INT(STAGE_3_OUT_INT),.WO_FRAC(STAGE_3_OUT_FRAC),.TW_FRAC(TW_FRAC), .TW_INT(TW_IN)) butterfly3_inst (
                     .clk(clk),
                     .rst_n(rst_n),
                     .in0_r(stage2_out0_r),
                     .in1_r(stage2_out1_r),
                     .in2_r(stage2_out2_r),
                     .in3_r(stage2_out3_r),
                     .in4_r(stage2_out4_r),
                     .in5_r(stage2_out5_r),
                     .in6_r(stage2_out6_r),
                     .in7_r(stage2_out7_r),
                     .in0_imag(stage2_out0_i),
                     .in1_imag(stage2_out1_i),
                     .in2_imag(stage2_out2_i),
                     .in3_imag(stage2_out3_i),
                     .in4_imag(stage2_out4_i),
                     .in5_imag(stage2_out5_i),
                     .in6_imag(stage2_out6_i),
                     .in7_imag(stage2_out7_i),
                     .tw0_r(W8_REAL[0]), // Twiddle factor for stage 3
                     .tw0_i(W8_IMAG[0]), // Twiddle factor for stage 3
                     .tw2_r(W8_REAL[2]), // Twiddle factor for stage 3
                     .tw2_i(W8_IMAG[2]), // Twiddle factor for stage 3
                     .tw1_r(W8_REAL[1]), // Twiddle factor for stage 3
                     .tw1_i(W8_IMAG[1]), // Twiddle factor for stage 3
                     .tw3_r(W8_REAL[3]), // Twiddle factor for stage 3
                     .tw3_i(W8_IMAG[3]), // Twiddle factor for stage 3
                     .stage3_out0_r(stage3_out0_r),
                     .stage3_out1_r(stage3_out1_r),
                     .stage3_out2_r(stage3_out2_r),
                     .stage3_out3_r(stage3_out3_r),
                     .stage3_out4_r(stage3_out4_r),
                     .stage3_out5_r(stage3_out5_r),
                     .stage3_out6_r(stage3_out6_r),
                     .stage3_out7_r(stage3_out7_r),
                     .stage3_out0_imag(stage3_out0_i),
                     .stage3_out1_imag(stage3_out1_i),
                     .stage3_out2_imag(stage3_out2_i),
                     .stage3_out3_imag(stage3_out3_i),
                     .stage3_out4_imag(stage3_out4_i),
                     .stage3_out5_imag(stage3_out5_i),
                     .stage3_out6_imag(stage3_out6_i),
                     .stage3_out7_imag(stage3_out7_i)
                   );

endmodule
