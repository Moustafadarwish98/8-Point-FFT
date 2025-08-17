`timescale 1ns/1ps
module tb_fft;
  parameter WIDTH = 12;
  parameter WI_INT   = 6;
  parameter WI_FRAC  = WIDTH - WI_INT;
  parameter WO_INT   = 8;
  parameter WO_FRAC  = WIDTH - WO_INT;
  parameter OP_WIDTH = WO_FRAC + WO_INT;
  parameter TW_FRAC = 10;
  parameter TW_IN = 2;
  parameter IP_WIDTH = WI_FRAC + WI_INT;

  localparam CLK_PERIOD  = 10;
  localparam HALF_PERIOD = CLK_PERIOD/2.0;

  parameter STAGE_1_OUT_INT = 7 ;
  parameter STAGE_1_OUT_FRAC = WIDTH - STAGE_1_OUT_INT;
  parameter STAGE_2_OUT_INT = 7;
  parameter STAGE_2_OUT_FRAC = WIDTH - STAGE_2_OUT_INT;
  parameter STAGE_3_OUT_INT = 8;
  parameter STAGE_3_OUT_FRAC = WIDTH - STAGE_3_OUT_INT;
  // DUT input regs
  reg signed [IP_WIDTH - 1:0] in0_tb_r;
  reg signed [IP_WIDTH - 1:0] in1_tb_r;
  reg signed [IP_WIDTH - 1:0] in2_tb_r;
  reg signed [IP_WIDTH - 1:0] in3_tb_r;
  reg signed [IP_WIDTH - 1:0] in4_tb_r;
  reg signed [IP_WIDTH - 1:0] in5_tb_r;
  reg signed [IP_WIDTH - 1:0] in6_tb_r;
  reg signed [IP_WIDTH - 1:0] in7_tb_r;
  reg signed [IP_WIDTH - 1:0] in0_tb_i;
  reg signed [IP_WIDTH - 1:0] in1_tb_i;
  reg signed [IP_WIDTH - 1:0] in2_tb_i;
  reg signed [IP_WIDTH - 1:0] in3_tb_i;
  reg signed [IP_WIDTH - 1:0] in4_tb_i;
  reg signed [IP_WIDTH - 1:0] in5_tb_i;
  reg signed [IP_WIDTH - 1:0] in6_tb_i;
  reg signed [IP_WIDTH - 1:0] in7_tb_i;
  reg clk_tb;
  reg rst_n_tb;

  // DUT outputs
  wire signed [OP_WIDTH - 1:0] out0_tb_r;
  wire signed [OP_WIDTH - 1:0] out1_tb_r;
  wire signed [OP_WIDTH - 1:0] out2_tb_r;
  wire signed [OP_WIDTH - 1:0] out3_tb_r;
  wire signed [OP_WIDTH - 1:0] out4_tb_r;
  wire signed [OP_WIDTH - 1:0] out5_tb_r;
  wire signed [OP_WIDTH - 1:0] out6_tb_r;
  wire signed [OP_WIDTH - 1:0] out7_tb_r;
  wire signed [OP_WIDTH - 1:0] out0_tb_i;
  wire signed [OP_WIDTH - 1:0] out1_tb_i;
  wire signed [OP_WIDTH - 1:0] out2_tb_i;
  wire signed [OP_WIDTH - 1:0] out3_tb_i;
  wire signed [OP_WIDTH - 1:0] out4_tb_i;
  wire signed [OP_WIDTH - 1:0] out5_tb_i;
  wire signed [OP_WIDTH - 1:0] out6_tb_i;
  wire signed [OP_WIDTH - 1:0] out7_tb_i;

  // Instantiate top DUT
  // Instantiate DUT
  fft_top #( .WIDTH(WIDTH),
             .IP_WIDTH(IP_WIDTH),
             .OP_WIDTH(OP_WIDTH),
             .WI_INT(WI_INT), .WI_FRAC(WI_FRAC), .WO_INT(WO_INT), .WO_FRAC(WO_FRAC),
             .TW_FRAC(TW_FRAC), .TW_IN(TW_IN)
           ) DUT (
            .clk(clk_tb),
            .rst_n(rst_n_tb),
            // Inputs
            .in0_r(in0_tb_r), .in1_r(in1_tb_r), .in2_r(in2_tb_r), .in3_r(in3_tb_r),
            .in4_r(in4_tb_r), .in5_r(in5_tb_r), .in6_r(in6_tb_r), .in7_r(in7_tb_r),
            .in0_imag(in0_tb_i), .in1_imag(in1_tb_i), .in2_imag(in2_tb_i), .in3_imag(in3_tb_i),
            .in4_imag(in4_tb_i), .in5_imag(in5_tb_i), .in6_imag(in6_tb_i), .in7_imag(in7_tb_i),

            // Outputs
            .out0_r(out0_tb_r), .out1_r(out1_tb_r), .out2_r(out2_tb_r), .out3_r(out3_tb_r),
            .out4_r(out4_tb_r), .out5_r(out5_tb_r), .out6_r(out6_tb_r), .out7_r(out7_tb_r),
            .out0_imag(out0_tb_i), .out1_imag(out1_tb_i), .out2_imag(out2_tb_i), .out3_imag(out3_tb_i),
            .out4_imag(out4_tb_i), .out5_imag(out5_tb_i), .out6_imag(out6_tb_i), .out7_imag(out7_tb_i)
          );



  // Clock generation
  initial
    clk_tb = 0;
  always #5 clk_tb = ~clk_tb;

  // Convert fixed-point to real
  function real fxp_to_real;
    input signed [OP_WIDTH-1:0] val;
    input [1:0] stage;
    case (stage)
      2'd1:
        fxp_to_real = $itor(val) / (1 << STAGE_1_OUT_FRAC);
      2'd2:
        fxp_to_real = $itor(val) / (1 << STAGE_2_OUT_FRAC);
      2'd3:
        fxp_to_real = $itor(val) / (1 << STAGE_3_OUT_FRAC);
      default:
      begin
        $display("DEFAULT SCALING");
        fxp_to_real = $itor(val) / (1 << WO_FRAC);
      end
    endcase
  endfunction
  initial
  begin
    // Reset
    rst_n_tb = 0;
    in0_tb_r = 0;
    in1_tb_r = 0;
    in2_tb_r = 0;
    in3_tb_r = 0;
    in4_tb_r = 0;
    in5_tb_r = 0;
    in6_tb_r = 0;
    in7_tb_r = 0;
    in0_tb_i = 0;
    in1_tb_i = 0;
    in2_tb_i = 0;
    in3_tb_i = 0;
    in4_tb_i = 0;
    in5_tb_i = 0;
    in6_tb_i = 0;
    in7_tb_i = 0;
    #20 rst_n_tb = 1;

    // Apply test vector (Q7.5 format)
    in0_tb_r = $rtoi(1.0 * (1 << WI_FRAC));
    in0_tb_i = 0;
    in1_tb_r = 2 << WI_FRAC;
    in1_tb_i = 0;
    in2_tb_r =  3 << WI_FRAC;
    in2_tb_i = 0;
    in3_tb_r = 4 << WI_FRAC;
    in3_tb_i = 0;
    in4_tb_r = 4 << WI_FRAC;
    in4_tb_i = 0;
    in5_tb_r = 3 << WI_FRAC;
    in5_tb_i = 0;
    in6_tb_r =  2 << WI_FRAC;
    in6_tb_i = 0;
    in7_tb_r =  1 << WI_FRAC;
    in7_tb_i = 0;
    #40;
    display_twiddle_factors();
    display_stages_outputs();

    #20;
    // Apply test vector (Q7.5 format)
    in0_tb_r = $rtoi(0.0 * (1 << WI_FRAC));
    in0_tb_i = 0;
    in1_tb_r = 1 << WI_FRAC;
    in1_tb_i = 0;
    in2_tb_r = 2 << WI_FRAC;
    in2_tb_i = 0;
    in3_tb_r = 3 << WI_FRAC;
    in3_tb_i = 0;
    in4_tb_r = 4 << WI_FRAC;
    in4_tb_i = 0;
    in5_tb_r = 5 << WI_FRAC;
    in5_tb_i = 0;
    in6_tb_r = 6 << WI_FRAC;
    in6_tb_i = 0;
    in7_tb_r = 7 << WI_FRAC;
    in7_tb_i = 0;
    #40;
    display_twiddle_factors();
    display_stages_outputs();

    #20;

/*  Matlab
    
================ Test Input 964 ================
Input x(n):
  Columns 1 through 5
   1.4688 + 5.4688i -19.9062 - 1.9531i   7.6719 - 7.3750i  -5.3125 + 9.7812i  -1.5312 -21.4531i
  Columns 6 through 8
  11.4375 -16.5000i  -6.1250 + 6.0000i  -2.6875 -19.5156i

          DataTypeMode: Fixed-point: binary point scaling
            Signedness: Signed
            WordLength: 12
        FractionLength: 6
Bit-reversed order:
  Columns 1 through 5
   1.4688 + 5.4688i  -1.5312 -21.4531i   7.6719 - 7.3750i  -6.1250 + 6.0000i -19.9062 - 1.9531i
  Columns 6 through 8
  11.4375 -16.5000i  -5.3125 + 9.7812i  -2.6875 -19.5156i

          DataTypeMode: Fixed-point: binary point scaling
            Signedness: Signed
            WordLength: 12
        FractionLength: 6
After Stage 1:
  Columns 1 through 5
  -0.0625 -15.9688i   3.0000 +26.9375i   1.5625 - 1.3750i  13.8125 -13.3750i  -8.4688 -18.4375i
  Columns 6 through 8
 -31.3438 +14.5625i  -8.0000 - 9.7188i  -2.6250 +29.3125i

          DataTypeMode: Fixed-point: binary point scaling
            Signedness: Signed
            WordLength: 12
        FractionLength: 5
After Stage 2:
  Columns 1 through 5
   1.5000 -17.3438i -10.3750 +13.1250i  -1.6250 -14.5938i  16.3750 +40.7500i -16.4688 -28.1562i
  Columns 6 through 8
  -2.0312 +17.1875i  -0.4688 - 8.7188i -60.6562 +11.9375i

          DataTypeMode: Fixed-point: binary point scaling
            Signedness: Signed
            WordLength: 12
        FractionLength: 5
Final FFT Output (Stage 3):
  Columns 1 through 5
 -14.9375 -45.5000i   0.3125 +26.6875i -10.3125 -14.1250i  67.6875 +75.1875i  17.9375 +10.8125i
  Columns 6 through 8
 -21.0625 - 0.4375i   7.1250 -15.0625i -34.9375 + 6.3125i

          DataTypeMode: Fixed-point: binary point scaling
            Signedness: Signed
            WordLength: 12
        FractionLength: 4
MATLAB fft(x) Output:
  Columns 1 through 5

 -14.9844 -45.5469i   0.3200 +26.7147i -10.3281 -14.1406i  67.6844 +75.1681i  17.9531 +10.8281i

  Columns 6 through 8

 -21.0700 - 0.4647i   7.1094 -15.0781i -34.9344 + 6.2694i*/
    in0_tb_r = $rtoi(1.4688 * (1 << WI_FRAC));
    in0_tb_i = $rtoi(5.4688 * (1 << WI_FRAC));
    in1_tb_r = $rtoi(-19.9062 * (1 << WI_FRAC));
    in1_tb_i = $rtoi(- 1.9531 * (1 << WI_FRAC));
    in2_tb_r = $rtoi(7.6719 * (1 << WI_FRAC));
    in2_tb_i = $rtoi(- 7.3750* (1 << WI_FRAC));
    in3_tb_r = $rtoi(-5.3125 * (1 << WI_FRAC));
    in3_tb_i = $rtoi(9.7812 * (1 << WI_FRAC));
    in4_tb_r = $rtoi(-1.5312 * (1 << WI_FRAC));
    in4_tb_i = $rtoi(-21.4531 * (1 << WI_FRAC));
    in5_tb_r = $rtoi(11.4375 * (1 << WI_FRAC));
    in5_tb_i = $rtoi(-16.5000 * (1 << WI_FRAC));
    in6_tb_r = $rtoi(-6.1250 * (1 << WI_FRAC));
    in6_tb_i = $rtoi(6.0000* (1 << WI_FRAC));
    in7_tb_r = $rtoi(-2.6875 * (1 << WI_FRAC));
    in7_tb_i = $rtoi(-19.5156 * (1 << WI_FRAC));
  #40;
    display_twiddle_factors();
    display_stages_outputs();

    #40;
    $finish;
  end
  // Add this function to display twiddle factors
  task display_twiddle_factors;
    begin
      $display("=== TWIDDLE FACTORS (Q%0d.%0d format) ===",TW_IN, TW_FRAC);
      $display("W8_REAL[0] = %0d (%.4f)", DUT.W8_REAL[0], $itor(DUT.W8_REAL[0])/(1 << TW_FRAC));
      $display("W8_IMAG[0] = %0d (%.4f)", DUT.W8_IMAG[0], $itor(DUT.W8_IMAG[0])/(1 << TW_FRAC));
      $display("W8_REAL[1] = %0d (%.4f)", DUT.W8_REAL[1], $itor(DUT.W8_REAL[1])/(1 << TW_FRAC));
      $display("W8_IMAG[1] = %0d (%.4f)", DUT.W8_IMAG[1], $itor(DUT.W8_IMAG[1])/(1 << TW_FRAC));
      $display("W8_REAL[2] = %0d (%.4f)", DUT.W8_REAL[2], $itor(DUT.W8_REAL[2])/(1 << TW_FRAC));
      $display("W8_IMAG[2] = %0d (%.4f)", DUT.W8_IMAG[2], $itor(DUT.W8_IMAG[2])/(1 << TW_FRAC));
      $display("W8_REAL[3] = %0d (%.4f)", DUT.W8_REAL[3], $itor(DUT.W8_REAL[3])/(1 << TW_FRAC));
      $display("W8_IMAG[3] = %0d (%.4f)", DUT.W8_IMAG[3], $itor(DUT.W8_IMAG[3])/(1 << TW_FRAC));
    end
  endtask

  task display_stages_outputs;
    begin
      $display("=== STAGE1 BUTTERFLY OUTPUTS (Q%0d.%0d format) ===", DUT.butterfly1_inst.WO_INT, DUT.butterfly1_inst.WO_FRAC);
      $display("out0 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out0_r,1),  fxp_to_real(DUT.stage1_out0_i,1));
      $display("out1 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out1_r,1),  fxp_to_real(DUT.stage1_out1_i,1));
      $display("out2 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out2_r,1),  fxp_to_real(DUT.stage1_out2_i,1));
      $display("out3 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out3_r,1),  fxp_to_real(DUT.stage1_out3_i,1));
      $display("out4 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out4_r,1),  fxp_to_real(DUT.stage1_out4_i,1));
      $display("out5 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out5_r,1),  fxp_to_real(DUT.stage1_out5_i,1));
      $display("out6 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out6_r,1),  fxp_to_real(DUT.stage1_out6_i,1));
      $display("out7 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out7_r,1),  fxp_to_real(DUT.stage1_out7_i,1));

      $display("=== STAGE2 BUTTERFLY OUTPUTS (Q%0d.%0d format) ===", DUT.butterfly2_inst.WO_INT, DUT.butterfly2_inst.WO_FRAC);
      $display("out0 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out0_r,2),  fxp_to_real(DUT.stage2_out0_i,2));
      $display("out1 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out1_r,2),  fxp_to_real(DUT.stage2_out1_i,2));
      $display("out2 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out2_r,2),  fxp_to_real(DUT.stage2_out2_i,2));
      $display("out3 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out3_r,2),  fxp_to_real(DUT.stage2_out3_i,2));
      $display("out4 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out4_r,2),  fxp_to_real(DUT.stage2_out4_i,2));
      $display("out5 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out5_r,2),  fxp_to_real(DUT.stage2_out5_i,2));
      $display("out6 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out6_r,2),  fxp_to_real(DUT.stage2_out6_i,2));
      $display("out7 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out7_r,2),  fxp_to_real(DUT.stage2_out7_i,2));

      $display("=== STAGE3 BUTTERFLY OUTPUTS (Q%0d.%0d format) ===", DUT.butterfly3_inst.WO_INT, DUT.butterfly3_inst.WO_FRAC);
      $display("out0 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out0_r,3), fxp_to_real(DUT.stage3_out0_i,3));
      $display("out1 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out1_r,3), fxp_to_real(DUT.stage3_out1_i,3));
      $display("out2 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out2_r,3), fxp_to_real(DUT.stage3_out2_i,3));
      $display("out3 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out3_r,3), fxp_to_real(DUT.stage3_out3_i,3));
      $display("out4 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out4_r,3), fxp_to_real(DUT.stage3_out4_i,3));
      $display("out5 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out5_r,3), fxp_to_real(DUT.stage3_out5_i,3));
      $display("out6 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out6_r,3), fxp_to_real(DUT.stage3_out6_i,3));
      $display("out7 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out7_r,3), fxp_to_real(DUT.stage3_out7_i,3));
    end
  endtask
endmodule








