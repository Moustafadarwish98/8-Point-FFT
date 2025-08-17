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

    #10;
    display_twiddle_factors();

    // Add to your testbench's initial block after applying inputs
    #40; // Wait for pipeline to fill

    $display("=== STAGE1 BUTTERFLY OUTPUTS (Q%0d.%0d format) ===", DUT.butterfly1_inst.WO_INT, DUT.butterfly1_inst.WO_FRAC);
    $display("out0 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out0_r, fxp_to_real(DUT.stage1_out0_r,1), DUT.stage1_out0_i, fxp_to_real(DUT.stage1_out0_i,1));
    $display("out1 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out1_r, fxp_to_real(DUT.stage1_out1_r,1), DUT.stage1_out1_i, fxp_to_real(DUT.stage1_out1_i,1));
    $display("out2 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out2_r, fxp_to_real(DUT.stage1_out2_r,1), DUT.stage1_out2_i, fxp_to_real(DUT.stage1_out2_i,1));
    $display("out3 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out3_r, fxp_to_real(DUT.stage1_out3_r,1), DUT.stage1_out3_i, fxp_to_real(DUT.stage1_out3_i,1));
    $display("out4 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out4_r, fxp_to_real(DUT.stage1_out4_r,1), DUT.stage1_out4_i, fxp_to_real(DUT.stage1_out4_i,1));
    $display("out5 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out5_r, fxp_to_real(DUT.stage1_out5_r,1), DUT.stage1_out5_i, fxp_to_real(DUT.stage1_out5_i,1));
    $display("out6 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out6_r, fxp_to_real(DUT.stage1_out6_r,1), DUT.stage1_out6_i, fxp_to_real(DUT.stage1_out6_i,1));
    $display("out7 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out7_r, fxp_to_real(DUT.stage1_out7_r,1), DUT.stage1_out7_i, fxp_to_real(DUT.stage1_out7_i,1));

    $display("=== STAGE2 BUTTERFLY OUTPUTS (Q%0d.%0d format) ===", DUT.butterfly2_inst.WO_INT, DUT.butterfly2_inst.WO_FRAC);
    $display("out0 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out0_r, fxp_to_real(DUT.stage2_out0_r,2), DUT.stage2_out0_i, fxp_to_real(DUT.stage2_out0_i,2));
    $display("out1 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out1_r, fxp_to_real(DUT.stage2_out1_r,2), DUT.stage2_out1_i, fxp_to_real(DUT.stage2_out1_i,2));
    $display("out2 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out2_r, fxp_to_real(DUT.stage2_out2_r,2), DUT.stage2_out2_i, fxp_to_real(DUT.stage2_out2_i,2));
    $display("out3 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out3_r, fxp_to_real(DUT.stage2_out3_r,2), DUT.stage2_out3_i, fxp_to_real(DUT.stage2_out3_i,2));
    $display("out4 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out4_r, fxp_to_real(DUT.stage2_out4_r,2), DUT.stage2_out4_i, fxp_to_real(DUT.stage2_out4_i,2));
    $display("out5 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out5_r, fxp_to_real(DUT.stage2_out5_r,2), DUT.stage2_out5_i, fxp_to_real(DUT.stage2_out5_i,2));
    $display("out6 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out6_r, fxp_to_real(DUT.stage2_out6_r,2), DUT.stage2_out6_i, fxp_to_real(DUT.stage2_out6_i,2));
    $display("out7 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out7_r, fxp_to_real(DUT.stage2_out7_r,2), DUT.stage2_out7_i, fxp_to_real(DUT.stage2_out7_i,2));

    $display("=== STAGE3 BUTTERFLY OUTPUTS (Q%0d.%0d format) ===", DUT.butterfly3_inst.WO_INT, DUT.butterfly3_inst.WO_FRAC);
    $display("out0 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out0_r, fxp_to_real(DUT.stage3_out0_r,3), DUT.stage2_out0_i, fxp_to_real(DUT.stage3_out0_i,3));
    $display("out1 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out1_r, fxp_to_real(DUT.stage3_out1_r,3), DUT.stage2_out1_i, fxp_to_real(DUT.stage3_out1_i,3));
    $display("out2 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out2_r, fxp_to_real(DUT.stage3_out2_r,3), DUT.stage2_out2_i, fxp_to_real(DUT.stage3_out2_i,3));
    $display("out3 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out3_r, fxp_to_real(DUT.stage3_out3_r,3), DUT.stage2_out3_i, fxp_to_real(DUT.stage3_out3_i,3));
    $display("out4 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out4_r, fxp_to_real(DUT.stage3_out4_r,3), DUT.stage2_out4_i, fxp_to_real(DUT.stage3_out4_i,3));
    $display("out5 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out5_r, fxp_to_real(DUT.stage3_out5_r,3), DUT.stage2_out5_i, fxp_to_real(DUT.stage3_out5_i,3));
    $display("out6 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out6_r, fxp_to_real(DUT.stage3_out6_r,3), DUT.stage2_out6_i, fxp_to_real(DUT.stage3_out6_i,3));
    $display("out7 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out7_r, fxp_to_real(DUT.stage3_out7_r,3), DUT.stage2_out7_i, fxp_to_real(DUT.stage3_out7_i,3));

    $finish;
  end
endmodule
/* Display all intermediate calculations for Stage 3
$display("\n=== STAGE 3 DEBUGGING ===");
 
// ----------------------
// Butterfly 0: in0 + in4*W0
$display("BUTTERFLY 0 (k=0):");
$display("  in0_r = %d (%.4f), in4_r = %d (%.4f)",
         DUT.butterfly3_inst.in0_r, fxp_to_real(DUT.butterfly3_inst.in0_r),
         DUT.butterfly3_inst.in4_r, fxp_to_real(DUT.butterfly3_inst.in4_r));
$display("  W0 = %d + j%d (%.4f + j%.4f)",
         DUT.butterfly3_inst.twiddle0_real, DUT.butterfly3_inst.twiddle0_imag,
         $itor(DUT.butterfly3_inst.twiddle0_real)/(1<<TW_FRAC),
         $itor(DUT.butterfly3_inst.twiddle0_imag)/(1<<TW_FRAC));
$display("  tmp0_rr = in4_r*W0_real = %d (%.4f * %.4f = %.4f)",
         DUT.butterfly3_inst.tmp0_rr,
         fxp_to_real(DUT.butterfly3_inst.in4_r),
         $itor(DUT.butterfly3_inst.twiddle0_real)/(1<<TW_FRAC),
         $itor(DUT.butterfly3_inst.tmp0_rr)/(1<<(WI_INT+TW_FRAC)));
$display("  sub0_r = (tmp0_rr - tmp0_ii) = %d (%.4f)",
         DUT.butterfly3_inst.sub_temp_r[0],
         $itor(DUT.butterfly3_inst.sub_temp_r[0])/(1<<WO_FRAC));
$display("  FINAL: out0_r = %d (%.4f), out4_r = %d (%.4f)",
         DUT.stage3_out0_r, fxp_to_real(DUT.stage3_out0_r),
         DUT.stage3_out4_r, fxp_to_real(DUT.stage3_out4_r));
 
// ----------------------
// Butterfly 1: in1 + in5*W1
$display("\nBUTTERFLY 1 (k=1):");
$display("  in1_r = %d (%.4f), in5_r = %d (%.4f)",
         DUT.butterfly3_inst.in1_r, fxp_to_real(DUT.butterfly3_inst.in1_r),
         DUT.butterfly3_inst.in5_r, fxp_to_real(DUT.butterfly3_inst.in5_r));
$display("  W1 = %d + j%d (%.4f + j%.4f)",
         DUT.butterfly3_inst.twiddle1_real, DUT.butterfly3_inst.twiddle1_imag,
         $itor(DUT.butterfly3_inst.twiddle1_real)/(1<<TW_FRAC),
         $itor(DUT.butterfly3_inst.twiddle1_imag)/(1<<TW_FRAC));
$display("  tmp1_rr = in5_r*W1_real = %d (%.4f)",
         DUT.butterfly3_inst.tmp1_rr,
         $itor(DUT.butterfly3_inst.tmp1_rr)/(1<<(WI_INT+TW_FRAC)));
$display("  tmp1_ii = in5_i*W1_imag = %d (%.4f)",
         DUT.butterfly3_inst.tmp1_ii,
         $itor(DUT.butterfly3_inst.tmp1_ii)/(1<<(WI_INT+TW_FRAC)));
$display("  sub1_r = (tmp1_rr - tmp1_ii) = %d (%.4f)",
         DUT.butterfly3_inst.sub_temp_r[1],
         $itor(DUT.butterfly3_inst.sub_temp_r[1])/(1<<WO_FRAC));
$display("  FINAL: out1 = %d + j%d (%.4f + j%.4f)",
         DUT.stage3_out1_r, DUT.stage3_out1_i,
         fxp_to_real(DUT.stage3_out1_r), fxp_to_real(DUT.stage3_out1_i));
$display("         out5 = %d + j%d (%.4f + j%.4f)",
         DUT.stage3_out5_r, DUT.stage3_out5_i,
         fxp_to_real(DUT.stage3_out5_r), fxp_to_real(DUT.stage3_out5_i));
 
// ----------------------
// Butterfly 2: in2 + in6*W2
$display("\nBUTTERFLY 2 (k=2):");
$display("  W2 = %d + j%d (%.4f + j%.4f)",
         DUT.butterfly3_inst.twiddle2_real, DUT.butterfly3_inst.twiddle2_imag,
         $itor(DUT.butterfly3_inst.twiddle2_real)/(1<<TW_FRAC),
         $itor(DUT.butterfly3_inst.twiddle2_imag)/(1<<TW_FRAC));
$display("  tmp2_ri = in6_r*W2_imag = %d (%.4f)",
         DUT.butterfly3_inst.tmp2_ri,
         $itor(DUT.butterfly3_inst.tmp2_ri)/(1<<(WI_INT+TW_FRAC)));
$display("  FINAL: out2 = %d + j%d (%.4f + j%.4f)",
         DUT.stage3_out2_r, DUT.stage3_out2_i,
         fxp_to_real(DUT.stage3_out2_r), fxp_to_real(DUT.stage3_out2_i));
$display("         out6 = %d + j%d (%.4f + j%.4f)",
         DUT.stage3_out6_r, DUT.stage3_out6_i,
         fxp_to_real(DUT.stage3_out6_r), fxp_to_real(DUT.stage3_out6_i));
 
// ----------------------
// Butterfly 3: in3 + in7*W3
$display("\nBUTTERFLY 3 (k=3):");
$display("  W3 = %d + j%d (%.4f + j%.4f)",
         DUT.butterfly3_inst.twiddle3_real, DUT.butterfly3_inst.twiddle3_imag,
         $itor(DUT.butterfly3_inst.twiddle3_real)/(1<<TW_FRAC),
         $itor(DUT.butterfly3_inst.twiddle3_imag)/(1<<TW_FRAC));
$display("  tmp3_rr = in7_r*W3_real = %d (%.4f)",
         DUT.butterfly3_inst.tmp3_rr,
         $itor(DUT.butterfly3_inst.tmp3_rr)/(1<<(WI_INT+TW_FRAC)));
$display("  FINAL: out3 = %d + j%d (%.4f + j%.4f)",
         DUT.stage3_out3_r, DUT.stage3_out3_i,
         fxp_to_real(DUT.stage3_out3_r), fxp_to_real(DUT.stage3_out3_i));
$display("         out7 = %d + j%d (%.4f + j%.4f)",
         DUT.stage3_out7_r, DUT.stage3_out7_i,
         fxp_to_real(DUT.stage3_out7_r), fxp_to_real(DUT.stage3_out7_i));
 
// ----------------------
// Summary check
$display("\nTOTAL CHECK:");
$display("Sum of inputs = %d (%.4f)",
         (1+2+3+4+4+3+2+1)*(1<<WI_INT),
         (1+2+3+4+4+3+2+1));
$display("X[0] = %d (%.4f) (should be sum)",
         DUT.stage3_out0_r + DUT.stage3_out4_r,
         fxp_to_real(DUT.stage3_out0_r) + fxp_to_real(DUT.stage3_out4_r));
 
#40;
$display("=== STAGE1 BUTTERFLY OUTPUTS (Q%0d.%0d format) ===", DUT.butterfly1_inst.WO_INT, DUT.butterfly1_inst.WO_FRAC);
$display("out0 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out0_r, fxp_to_real(DUT.stage1_out0_r), DUT.stage1_out0_i, fxp_to_real(DUT.stage1_out0_i));
$display("out1 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out1_r, fxp_to_real(DUT.stage1_out1_r), DUT.stage1_out1_i, fxp_to_real(DUT.stage1_out1_i));
$display("out2 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out2_r, fxp_to_real(DUT.stage1_out2_r), DUT.stage1_out2_i, fxp_to_real(DUT.stage1_out2_i));
$display("out3 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out3_r, fxp_to_real(DUT.stage1_out3_r), DUT.stage1_out3_i, fxp_to_real(DUT.stage1_out3_i));
$display("out4 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out4_r, fxp_to_real(DUT.stage1_out4_r), DUT.stage1_out4_i, fxp_to_real(DUT.stage1_out4_i));
$display("out5 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out5_r, fxp_to_real(DUT.stage1_out5_r), DUT.stage1_out5_i, fxp_to_real(DUT.stage1_out5_i));
$display("out6 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out6_r, fxp_to_real(DUT.stage1_out6_r), DUT.stage1_out6_i, fxp_to_real(DUT.stage1_out6_i));
$display("out7 = %0d (%.4f) + j %0d (%.4f)", DUT.stage1_out7_r, fxp_to_real(DUT.stage1_out7_r), DUT.stage1_out7_i, fxp_to_real(DUT.stage1_out7_i));
/*
 
$display("=== STAGE2 BUTTERFLY OUTPUTS (Q%0d.%0d format) ===", DUT.butterfly2_inst.WO_INT, DUT.butterfly2_inst.WO_FRAC);
$display("out0 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out0_r, fxp_to_real(DUT.stage2_out0_r), DUT.stage2_out0_i, fxp_to_real(DUT.stage2_out0_i));
$display("out1 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out1_r, fxp_to_real(DUT.stage2_out1_r), DUT.stage2_out1_i, fxp_to_real(DUT.stage2_out1_i));
$display("out2 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out2_r, fxp_to_real(DUT.stage2_out2_r), DUT.stage2_out2_i, fxp_to_real(DUT.stage2_out2_i));
$display("out3 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out3_r, fxp_to_real(DUT.stage2_out3_r), DUT.stage2_out3_i, fxp_to_real(DUT.stage2_out3_i));
$display("out4 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out4_r, fxp_to_real(DUT.stage2_out4_r), DUT.stage2_out4_i, fxp_to_real(DUT.stage2_out4_i));
$display("out5 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out5_r, fxp_to_real(DUT.stage2_out5_r), DUT.stage2_out5_i, fxp_to_real(DUT.stage2_out5_i));
$display("out6 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out6_r, fxp_to_real(DUT.stage2_out6_r), DUT.stage2_out6_i, fxp_to_real(DUT.stage2_out6_i));
$display("out7 = %0d (%.4f) + j %0d (%.4f)", DUT.stage2_out7_r, fxp_to_real(DUT.stage2_out7_r), DUT.stage2_out7_i, fxp_to_real(DUT.stage2_out7_i));
 
 
// Also add these debug displays for stage3 twiddle inputs
$display("=== STAGE3 TWIDDLE INPUTS ===");
$display("tw0_real = %0d (%.4f)", DUT.butterfly3_inst.twiddle0_real,
         $itor(DUT.butterfly3_inst.twiddle0_real)/(1 << TW_FRAC));
$display("tw0_real = %0d (%.4f)", DUT.butterfly3_inst.twiddle1_real,
         $itor(DUT.butterfly3_inst.twiddle1_real)/(1 << TW_FRAC));
$display("tw1_real = %0d (%.4f)", DUT.butterfly3_inst.twiddle2_real,
         $itor(DUT.butterfly3_inst.twiddle2_real)/(1 << TW_FRAC));
$display("tw1_real = %0d (%.4f)", DUT.butterfly3_inst.twiddle3_real,
         $itor(DUT.butterfly3_inst.twiddle3_real)/(1 << TW_FRAC));
$display("tw2_imag = %0d (%.4f)", DUT.butterfly3_inst.twiddle0_imag,
         $itor(DUT.butterfly3_inst.twiddle0_imag)/(1 << TW_FRAC));
$display("tw2_imag = %0d (%.4f)", DUT.butterfly3_inst.twiddle1_imag,
         $itor(DUT.butterfly3_inst.twiddle1_imag)/(1 << TW_FRAC));
$display("tw3_imag = %0d (%.4f)", DUT.butterfly3_inst.twiddle2_imag,
         $itor(DUT.butterfly3_inst.twiddle2_imag)/(1 << TW_FRAC));
$display("tw3_imag = %0d (%.4f)", DUT.butterfly3_inst.twiddle3_imag,
         $itor(DUT.butterfly3_inst.twiddle3_imag)/(1 << TW_FRAC));
 
$display("=== STAGE3 BUTTERFLY OUTPUTS (Q%0d.%0d format) ===", DUT.butterfly3_inst.WO_INT, DUT.butterfly3_inst.WO_FRAC);
$display("out0 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out0_r, fxp_to_real(DUT.stage3_out0_r), DUT.stage2_out0_i, fxp_to_real(DUT.stage3_out0_i));
$display("out1 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out1_r, fxp_to_real(DUT.stage3_out1_r), DUT.stage2_out1_i, fxp_to_real(DUT.stage3_out1_i));
$display("out2 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out2_r, fxp_to_real(DUT.stage3_out2_r), DUT.stage2_out2_i, fxp_to_real(DUT.stage3_out2_i));
$display("out3 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out3_r, fxp_to_real(DUT.stage3_out3_r), DUT.stage2_out3_i, fxp_to_real(DUT.stage3_out3_i));
$display("out4 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out4_r, fxp_to_real(DUT.stage3_out4_r), DUT.stage2_out4_i, fxp_to_real(DUT.stage3_out4_i));
$display("out5 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out5_r, fxp_to_real(DUT.stage3_out5_r), DUT.stage2_out5_i, fxp_to_real(DUT.stage3_out5_i));
$display("out6 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out6_r, fxp_to_real(DUT.stage3_out6_r), DUT.stage2_out6_i, fxp_to_real(DUT.stage3_out6_i));
$display("out7 = %0d (%.4f) + j %0d (%.4f)", DUT.stage3_out7_r, fxp_to_real(DUT.stage3_out7_r), DUT.stage2_out7_i, fxp_to_real(DUT.stage3_out7_i));
$finish;
end*/







