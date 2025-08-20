`timescale 1ns/1ps
module tb_fft2;
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

  //first output takes 7 clk cycles (latency)

  // Clock generation
  initial
    clk_tb = 0;
  always #(CLK_PERIOD / 2.0) clk_tb = ~clk_tb;
  integer clk_cycle = 0;
  // Convert fixed-point to real
  function real fxp_to_real;
    input signed [OP_WIDTH-1:0] val;
    input [1:0] stage;
    case (stage)
      2'd0:
        fxp_to_real = $itor(val) / (1 << WI_FRAC);
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
    // Initialize
    initialize();
    @(negedge clk_tb);

    //apply reset
    reset();

    clk_cycle = 0;
    $display("***************RESET DEASSERTED , CLK_CYCLE = 1 ***************");
    // Apply test vector 1 (Q7.5 format)
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
    repeat (1) @(negedge clk_tb);
    $display("input vector 1 is loaded at clk cycle = %0d",clk_cycle);
    display();
    // Apply test vector 2 (Q7.5 format)
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
    repeat (1) @(negedge clk_tb);
    $display("input vector 2 is loaded,Stage 1 is evaluated for vector 1 at clk cycle = %0d",clk_cycle);

    display();
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
    repeat (1) @(negedge clk_tb);
    $display("Stage 1 is evaluated for vector 2 ,Stage 1 is registered for vector 1 at clk cycle = %0d",clk_cycle);

    display();

    repeat (1) @(negedge clk_tb);
    $display("Stage 1 is registered for vector 2 ,Stage 2 is evaluated for vector 1 at clk cycle = %0d",clk_cycle);
    display();

    repeat (1) @(negedge clk_tb);
    $display("Stage 2 is registered for vector 1 ,Stage 2 is evaluated for vector 2 at clk cycle = %0d",clk_cycle);
    display();

    repeat (1) @(negedge clk_tb);
    $display("Stage 2 is registered for vector 2 ,Stage 3 is evaluated for vector 1 at clk cycle = %0d",clk_cycle);
    display();

    repeat (1) @(negedge clk_tb);
    $display("Stage 3 is registered for vector 1 ,Stage 3 is evaluated for vector 2 at clk cycle = %0d",clk_cycle);
    display();

    repeat (1) @(negedge clk_tb);
    $display("Stage 3 is registered for vector 2 , vector 1 out at clk cycle = %0d",clk_cycle);
    display();

    repeat (1) @(negedge clk_tb);
    $display(" vector 2 out at clk cycle = %0d",clk_cycle);
    display();

    repeat (1) @(negedge clk_tb);
    $display(" vector 3 out at clk cycle = %0d",clk_cycle);
    display();

    $finish;
  end
  // Add this function to display twiddle factors
  task display_twiddle_factors;
    begin
      $display("=== TWIDDLE FACTORS (Q%0d.%0d format) ===",TW_IN, TW_FRAC);
      $display("W8_REAL[0] = %0d (%.4f)", DUT.W8_REAL0, $itor(DUT.W8_REAL0)/(1 << TW_FRAC));
      $display("W8_IMAG[0] = %0d (%.4f)", DUT.W8_IMAG0, $itor(DUT.W8_IMAG0)/(1 << TW_FRAC));
      $display("W8_REAL[1] = %0d (%.4f)", DUT.W8_REAL1, $itor(DUT.W8_REAL1)/(1 << TW_FRAC));
      $display("W8_IMAG[1] = %0d (%.4f)", DUT.W8_IMAG1, $itor(DUT.W8_IMAG1)/(1 << TW_FRAC));
      $display("W8_REAL[2] = %0d (%.4f)", DUT.W8_REAL2, $itor(DUT.W8_REAL2)/(1 << TW_FRAC));
      $display("W8_IMAG[2] = %0d (%.4f)", DUT.W8_IMAG2, $itor(DUT.W8_IMAG2)/(1 << TW_FRAC));
      $display("W8_REAL[3] = %0d (%.4f)", DUT.W8_REAL3, $itor(DUT.W8_REAL3)/(1 << TW_FRAC));
      $display("W8_IMAG[3] = %0d (%.4f)", DUT.W8_IMAG3, $itor(DUT.W8_IMAG3)/(1 << TW_FRAC));
    end
  endtask
  task display_test_inputs;
    begin
      $display("=== Inputs (Q%0d.%0d format) ===", WI_INT, WI_FRAC);
      $display("in0 =  %.4f + j  %.4f", fxp_to_real(in0_tb_r,0),  fxp_to_real(in0_tb_i,0));
      $display("in1 =  %.4f + j  %.4f", fxp_to_real(in1_tb_r,0),  fxp_to_real(in1_tb_i,0));
      $display("in2 =  %.4f + j  %.4f", fxp_to_real(in2_tb_r,0),  fxp_to_real(in2_tb_i,0));
      $display("in3 =  %.4f + j  %.4f", fxp_to_real(in3_tb_r,0),  fxp_to_real(in3_tb_i,0));
      $display("in4 =  %.4f + j  %.4f", fxp_to_real(in4_tb_r,0),  fxp_to_real(in4_tb_i,0));
      $display("in5 =  %.4f + j  %.4f", fxp_to_real(in5_tb_r,0),  fxp_to_real(in5_tb_i,0));
      $display("in6 =  %.4f + j  %.4f", fxp_to_real(in6_tb_r,0),  fxp_to_real(in6_tb_i,0));
      $display("in7 =  %.4f + j  %.4f", fxp_to_real(in7_tb_r,0),  fxp_to_real(in7_tb_i,0));

      $display("=== Registerd Bit Reversed inputs (Q%0d.%0d format) ===", DUT.WI_INT, DUT.WI_FRAC);
      $display("reg0 =  %.4f + j  %.4f", fxp_to_real(DUT.in0_reg_r,0),  fxp_to_real(DUT.in0_reg_i,0));
      $display("reg1 =  %.4f + j  %.4f", fxp_to_real(DUT.in1_reg_r,0),  fxp_to_real(DUT.in1_reg_i,0));
      $display("reg2 =  %.4f + j  %.4f", fxp_to_real(DUT.in2_reg_r,0),  fxp_to_real(DUT.in2_reg_i,0));
      $display("reg3 =  %.4f + j  %.4f", fxp_to_real(DUT.in3_reg_r,0),  fxp_to_real(DUT.in3_reg_i,0));
      $display("reg4 =  %.4f + j  %.4f", fxp_to_real(DUT.in4_reg_r,0),  fxp_to_real(DUT.in4_reg_i,0));
      $display("reg5 =  %.4f + j  %.4f", fxp_to_real(DUT.in5_reg_r,0),  fxp_to_real(DUT.in5_reg_i,0));
      $display("reg6 =  %.4f + j  %.4f", fxp_to_real(DUT.in6_reg_r,0),  fxp_to_real(DUT.in6_reg_i,0));
      $display("reg7 =  %.4f + j  %.4f", fxp_to_real(DUT.in7_reg_r,0),  fxp_to_real(DUT.in7_reg_i,0));
    end
  endtask
  task display_stage1_outputs;
    begin

      $display("=== STAGE1 BUTTERFLY OUTPUTS (Q%0d.%0d format) ===", DUT.butterfly1_inst.WO_INT, DUT.butterfly1_inst.WO_FRAC);
      $display("stage1_out0 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out0_r,1),  fxp_to_real(DUT.stage1_out0_i,1));
      $display("stage1_out1 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out1_r,1),  fxp_to_real(DUT.stage1_out1_i,1));
      $display("stage1_out2 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out2_r,1),  fxp_to_real(DUT.stage1_out2_i,1));
      $display("stage1_out3 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out3_r,1),  fxp_to_real(DUT.stage1_out3_i,1));
      $display("stage1_out4 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out4_r,1),  fxp_to_real(DUT.stage1_out4_i,1));
      $display("stage1_out5 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out5_r,1),  fxp_to_real(DUT.stage1_out5_i,1));
      $display("stage1_out6 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out6_r,1),  fxp_to_real(DUT.stage1_out6_i,1));
      $display("stage1_out7 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_out7_r,1),  fxp_to_real(DUT.stage1_out7_i,1));


      $display("=== Registered STAGE1 BUTTERFLY OUTPUTS (Q%0d.%0d format) ===", DUT.butterfly1_inst.WO_INT, DUT.butterfly1_inst.WO_FRAC);
      $display("reg0 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_reg0_r,1),  fxp_to_real(DUT.stage1_reg0_i,1));
      $display("reg1 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_reg1_r,1),  fxp_to_real(DUT.stage1_reg1_i,1));
      $display("reg2 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_reg2_r,1),  fxp_to_real(DUT.stage1_reg2_i,1));
      $display("reg3 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_reg3_r,1),  fxp_to_real(DUT.stage1_reg3_i,1));
      $display("reg4 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_reg4_r,1),  fxp_to_real(DUT.stage1_reg4_i,1));
      $display("reg5 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_reg5_r,1),  fxp_to_real(DUT.stage1_reg5_i,1));
      $display("reg6 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_reg6_r,1),  fxp_to_real(DUT.stage1_reg6_i,1));
      $display("reg7 =  %.4f + j  %.4f", fxp_to_real(DUT.stage1_reg7_r,1),  fxp_to_real(DUT.stage1_reg7_i,1));



    end
  endtask
  task display_stage2_outputs;
    begin

      $display("=== STAGE2 BUTTERFLY OUTPUTS (Q%0d.%0d format) ===", DUT.butterfly2_inst.WO_INT, DUT.butterfly2_inst.WO_FRAC);
      $display("stage2_out0 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out0_r,2),  fxp_to_real(DUT.stage2_out0_i,2));
      $display("stage2_out1 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out1_r,2),  fxp_to_real(DUT.stage2_out1_i,2));
      $display("stage2_out2 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out2_r,2),  fxp_to_real(DUT.stage2_out2_i,2));
      $display("stage2_out3 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out3_r,2),  fxp_to_real(DUT.stage2_out3_i,2));
      $display("stage2_out4 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out4_r,2),  fxp_to_real(DUT.stage2_out4_i,2));
      $display("stage2_out5 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out5_r,2),  fxp_to_real(DUT.stage2_out5_i,2));
      $display("stage2_out6 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out6_r,2),  fxp_to_real(DUT.stage2_out6_i,2));
      $display("stage2_out7 = %.4f + j %.4f", fxp_to_real(DUT.stage2_out7_r,2),  fxp_to_real(DUT.stage2_out7_i,2));

      $display("=== Registered STAGE2 BUTTERFLY OUTPUTS (Q%0d.%0d format) ===", DUT.butterfly2_inst.WO_INT, DUT.butterfly2_inst.WO_FRAC);
      $display("reg0 = %.4f + j %.4f", fxp_to_real(DUT.stage2_reg0_r,2),  fxp_to_real(DUT.stage2_reg0_i,2));
      $display("reg1 = %.4f + j %.4f", fxp_to_real(DUT.stage2_reg1_r,2),  fxp_to_real(DUT.stage2_reg1_i,2));
      $display("reg2 = %.4f + j %.4f", fxp_to_real(DUT.stage2_reg2_r,2),  fxp_to_real(DUT.stage2_reg2_i,2));
      $display("reg3 = %.4f + j %.4f", fxp_to_real(DUT.stage2_reg3_r,2),  fxp_to_real(DUT.stage2_reg3_i,2));
      $display("reg4 = %.4f + j %.4f", fxp_to_real(DUT.stage2_reg4_r,2),  fxp_to_real(DUT.stage2_reg4_i,2));
      $display("reg5 = %.4f + j %.4f", fxp_to_real(DUT.stage2_reg5_r,2),  fxp_to_real(DUT.stage2_reg5_i,2));
      $display("reg6 = %.4f + j %.4f", fxp_to_real(DUT.stage2_reg6_r,2),  fxp_to_real(DUT.stage2_reg6_i,2));
      $display("reg7 = %.4f + j %.4f", fxp_to_real(DUT.stage2_reg7_r,2),  fxp_to_real(DUT.stage2_reg7_i,2));

    end
  endtask
  task display_stage3_outputs;
    begin

      $display("=== STAGE3 BUTTERFLY OUTPUTS (Q%0d.%0d format) ===", DUT.butterfly3_inst.WO_INT, DUT.butterfly3_inst.WO_FRAC);
      $display("stage3_out0 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out0_r,3), fxp_to_real(DUT.stage3_out0_i,3));
      $display("stage3_out1 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out1_r,3), fxp_to_real(DUT.stage3_out1_i,3));
      $display("stage3_out2 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out2_r,3), fxp_to_real(DUT.stage3_out2_i,3));
      $display("stage3_out3 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out3_r,3), fxp_to_real(DUT.stage3_out3_i,3));
      $display("stage3_out4 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out4_r,3), fxp_to_real(DUT.stage3_out4_i,3));
      $display("stage3_out5 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out5_r,3), fxp_to_real(DUT.stage3_out5_i,3));
      $display("stage3_out6 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out6_r,3), fxp_to_real(DUT.stage3_out6_i,3));
      $display("stage3_out7 = %.4f + j %.4f", fxp_to_real(DUT.stage3_out7_r,3), fxp_to_real(DUT.stage3_out7_i,3));

      $display("=== Registered STAGE3 BUTTERFLY OUTPUTS (Q%0d.%0d format) ===", DUT.butterfly3_inst.WO_INT, DUT.butterfly3_inst.WO_FRAC);
      $display("reg0 = %.4f + j %.4f", fxp_to_real(DUT.stage3_reg0_r,3), fxp_to_real(DUT.stage3_reg0_i,3));
      $display("reg1 = %.4f + j %.4f", fxp_to_real(DUT.stage3_reg1_r,3), fxp_to_real(DUT.stage3_reg1_i,3));
      $display("reg2 = %.4f + j %.4f", fxp_to_real(DUT.stage3_reg2_r,3), fxp_to_real(DUT.stage3_reg2_i,3));
      $display("reg3 = %.4f + j %.4f", fxp_to_real(DUT.stage3_reg3_r,3), fxp_to_real(DUT.stage3_reg3_i,3));
      $display("reg4 = %.4f + j %.4f", fxp_to_real(DUT.stage3_reg4_r,3), fxp_to_real(DUT.stage3_reg4_i,3));
      $display("reg5 = %.4f + j %.4f", fxp_to_real(DUT.stage3_reg5_r,3), fxp_to_real(DUT.stage3_reg5_i,3));
      $display("reg6 = %.4f + j %.4f", fxp_to_real(DUT.stage3_reg6_r,3), fxp_to_real(DUT.stage3_reg6_i,3));
      $display("reg7 = %.4f + j %.4f", fxp_to_real(DUT.stage3_reg7_r,3), fxp_to_real(DUT.stage3_reg7_i,3));

    end
  endtask
  task display_outputs;
    begin
      $display("=== OUTPUTS (Q%0d.%0d format) ===", WO_INT, WO_FRAC);
      $display("out0 = %.4f + j %.4f", fxp_to_real(out0_tb_r,3), fxp_to_real(out0_tb_i,3));
      $display("out1 = %.4f + j %.4f", fxp_to_real(out1_tb_r,3), fxp_to_real(out1_tb_i,3));
      $display("out2 = %.4f + j %.4f", fxp_to_real(out2_tb_r,3), fxp_to_real(out2_tb_i,3));
      $display("out3 = %.4f + j %.4f", fxp_to_real(out3_tb_r,3), fxp_to_real(out3_tb_i,3));
      $display("out4 = %.4f + j %.4f", fxp_to_real(out4_tb_r,3), fxp_to_real(out4_tb_i,3));
      $display("out5 = %.4f + j %.4f", fxp_to_real(out5_tb_r,3), fxp_to_real(out5_tb_i,3));
      $display("out6 = %.4f + j %.4f", fxp_to_real(out6_tb_r,3), fxp_to_real(out6_tb_i,3));
      $display("out7 = %.4f + j %.4f", fxp_to_real(out7_tb_r,3), fxp_to_real(out7_tb_i,3));
    end
  endtask
  task display;
    begin
      display_test_inputs();
      display_stage1_outputs();
      display_stage2_outputs();
      display_stage3_outputs();
      display_outputs();
    end
  endtask
  task initialize;
    begin
      rst_n_tb = 1;
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
    end
  endtask
  task reset;
    begin
      rst_n_tb = 0;
      repeat (2) @(negedge clk_tb);
      rst_n_tb = 1;
    end
  endtask
  always @(posedge clk_tb)
  begin
    clk_cycle <= clk_cycle + 1'd1;
    $display("CLK_CYCLE: %0d", clk_cycle);
  end
endmodule








