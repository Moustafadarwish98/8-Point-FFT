`timescale 1ns/1ps
module tb_fft;
  // Parameters
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

  // DUT input regs
  reg clk_tb;
  reg rst_n_tb;
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

  // ===== MEM BUFFERS & CAPTURED OUTPUTS =====
  localparam integer VEC_LEN   = 8;
  localparam integer MAX_LINES = 816;

  localparam NUM_VECS = 108;
  localparam PIPELINE_LATENCY = 6; // for pipelined 8-point FFT, 3 stages + reg after each stage + reversed inputs register = 6 cycles

  // Flat memories that hold ALL lines from the .mem files
  reg signed [IP_WIDTH-1:0] input_mem_r  [0:MAX_LINES-1];
  reg signed [IP_WIDTH-1:0] input_mem_i  [0:MAX_LINES-1];
  reg signed [OP_WIDTH-1:0] golden_mem_r [0:MAX_LINES-1];
  reg signed [OP_WIDTH-1:0] golden_mem_i [0:MAX_LINES-1];

  // Sliding pointer to step through consecutive 8-sample vectors
  integer mem_ptr;
  integer k;

  // test vector count
  integer vec;

  // Per-vector DUT captures (8 complex samples)
  reg signed [OP_WIDTH-1:0] dut_out_r [0:VEC_LEN-1];
  reg signed [OP_WIDTH-1:0] dut_out_i [0:VEC_LEN-1];

  // Valid out flag
  wire valid_out;
  assign valid_out = (vec >= PIPELINE_LATENCY);

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
  always #(CLK_PERIOD / 2.0) clk_tb = ~clk_tb;

  integer clk_cycle = 0;
  initial
  begin
    // Initialize
    initialize();
    @(negedge clk_tb);

    // Load all test vectors and golden outputs into memory
    load_mem();

    // Apply reset
    reset();
    clk_cycle = 0;
    $display("*************** RESET DEASSERTED , CLK_CYCLE = %0d ***************", clk_cycle);

    for (vec = 0; vec < NUM_VECS; vec = vec + 1)
    begin
      // Apply new input vector (Q6.6 format)
      apply_mem_inputs();
      $display("Input vector %0d is loaded at clk_cycle = %0d", vec+1, clk_cycle);
      clk_cycle = clk_cycle + 1;
      // Advance one cycle so DUT processes it
      @(negedge clk_tb);

      // Wait for pipeline latency before valid output appears
      if (valid_out)
      begin
        capture_outputs();
        compare_outputs();
      end
    end
    $display("*************** ALL TEST VECTORS COMPLETE ***************");
    $finish;
  end

  // =========================================================
  // TASK: Load .mem files into input and golden reference
  // =========================================================
  task load_mem;
    begin
      mem_ptr = 0;

      // Use HEX as we wrote 12-bit hex words in MATLAB
      $readmemh("fft_inputs_real.mem",   input_mem_r);
      $readmemh("fft_inputs_imag.mem",   input_mem_i);
      $readmemh("fft_outputs_real.mem",  golden_mem_r);
      $readmemh("fft_outputs_imag.mem",  golden_mem_i);

      $display("Memory files loaded successfully! mem_ptr=%0d", mem_ptr);
    end
  endtask
  // =========================================================
  // TASK: Initialize DUT
  // =========================================================
  task initialize;
    begin
      clk_tb = 0;
      k = 0;
      rst_n_tb = 1;
      in0_tb_r = 0;
      in0_tb_i = 0;
      in1_tb_r = 0;
      in1_tb_i = 0;
      in2_tb_r = 0;
      in2_tb_i = 0;
      in3_tb_r = 0;
      in3_tb_i = 0;
      in4_tb_r = 0;
      in4_tb_i = 0;
      in5_tb_r = 0;
      in5_tb_i = 0;
      in6_tb_r = 0;
      in6_tb_i = 0;
      in7_tb_r = 0;
      in7_tb_i = 0;
    end
  endtask
  // =========================================================
  // TASK: Apply Reset
  // =========================================================
  task reset;
    begin
      rst_n_tb = 0;
      repeat (2) @(negedge clk_tb);
      rst_n_tb = 1;
    end
  endtask
  // =========================================================
  // TASK: Apply inputs from .mem to DUT
  // =========================================================
  task apply_mem_inputs;
    integer i;
    begin
      // Apply 8 complex samples starting at mem_ptr
      for (i = 0; i < VEC_LEN; i = i+1)
      begin
        case (i)
          0:
          begin
            in0_tb_r = input_mem_r[mem_ptr+i];
            in0_tb_i = input_mem_i[mem_ptr+i];
          end
          1:
          begin
            in1_tb_r = input_mem_r[mem_ptr+i];
            in1_tb_i = input_mem_i[mem_ptr+i];
          end
          2:
          begin
            in2_tb_r = input_mem_r[mem_ptr+i];
            in2_tb_i = input_mem_i[mem_ptr+i];
          end
          3:
          begin
            in3_tb_r = input_mem_r[mem_ptr+i];
            in3_tb_i = input_mem_i[mem_ptr+i];
          end
          4:
          begin
            in4_tb_r = input_mem_r[mem_ptr+i];
            in4_tb_i = input_mem_i[mem_ptr+i];
          end
          5:
          begin
            in5_tb_r = input_mem_r[mem_ptr+i];
            in5_tb_i = input_mem_i[mem_ptr+i];
          end
          6:
          begin
            in6_tb_r = input_mem_r[mem_ptr+i];
            in6_tb_i = input_mem_i[mem_ptr+i];
          end
          7:
          begin
            in7_tb_r = input_mem_r[mem_ptr+i];
            in7_tb_i = input_mem_i[mem_ptr+i];
          end
        endcase
      end
      $display("Applied input vector from memory at base index %0d", mem_ptr);
      // Advance to the next vector for the next call
      mem_ptr = mem_ptr + VEC_LEN;
    end
  endtask
  // =========================================================
  // TASK: Capture DUT outputs when ready
  // =========================================================
  task capture_outputs;
    begin
      dut_out_r[0] = out0_tb_r;
      dut_out_i[0] = out0_tb_i;
      dut_out_r[1] = out1_tb_r;
      dut_out_i[1] = out1_tb_i;
      dut_out_r[2] = out2_tb_r;
      dut_out_i[2] = out2_tb_i;
      dut_out_r[3] = out3_tb_r;
      dut_out_i[3] = out3_tb_i;
      dut_out_r[4] = out4_tb_r;
      dut_out_i[4] = out4_tb_i;
      dut_out_r[5] = out5_tb_r;
      dut_out_i[5] = out5_tb_i;
      dut_out_r[6] = out6_tb_r;
      dut_out_i[6] = out6_tb_i;
      dut_out_r[7] = out7_tb_r;
      dut_out_i[7] = out7_tb_i;
      $display("Captured DUT outputs at cycle %0d", clk_cycle);
    end
  endtask
  // =========================================================
  // TASK: Compare DUT outputs vs Golden reference for each input vector
  // =========================================================
task compare_outputs;
  integer i;
  real in_r, in_i;
  real dut_r, dut_i;
  real golden_r, golden_i;
  begin
    $display("----------------------------------------------------------------------------------------------------------------------------");
    $display("| Idx |       Input (Q6.6)       |          DUT (Q8.4)          |         Golden (Q8.4)        |");
    $display("----------------------------------------------------------------------------------------------------------------------------");

    for (i = k; i < 8 + k; i = i + 1)
    begin
      // Input scaling (Q6.6)
      in_r = input_mem_r[i] / (1.0 * (1 << WI_FRAC));
      in_i = input_mem_i[i] / (1.0 * (1 << WI_FRAC));

      // DUT scaling (Q8.4)
      dut_r = dut_out_r[i - k] / (1.0 * (1 << WO_FRAC));
      dut_i = dut_out_i[i - k] / (1.0 * (1 << WO_FRAC));

      // Golden scaling (Q8.4)
      golden_r = golden_mem_r[i] / (1.0 * (1 << WO_FRAC));
      golden_i = golden_mem_i[i] / (1.0 * (1 << WO_FRAC));

      // Print row with fixed-width fields
      $display("| %3d | %10.6f + j%10.6f | %12.6f + j%12.6f | %12.6f + j%12.6f |",
               i, in_r, in_i, dut_r, dut_i, golden_r, golden_i);
    end

    $display("----------------------------------------------------------------------------------------------------------------------------");
    k = k + VEC_LEN;
  end
endtask
endmodule








