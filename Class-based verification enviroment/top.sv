`timescale 1ns/1ps
// =====================
// Top testbench
// =====================
import transaction_pkg::*;
import generator_pkg::*;
import driver_pkg::*;
import monitor_pkg::*;
import scoreboard_pkg::*;
import enviroment_pkg::*;

module fft_tb;
  // Clock
  bit clk;
  initial clk = 0;
  always #5 clk = ~clk;
  // Interface instance 
  fft_if fft_if0 (.clk(clk));
  // DUT instance 
  fft_top #(
    .WIDTH(12),
    .WI_INT(6)
  ) DUT (
    .clk        (fft_if0.clk),
    .rst_n      (fft_if0.rst_n),
    // Inputs
    .in0_r      (fft_if0.in0_r),
    .in1_r      (fft_if0.in1_r),
    .in2_r      (fft_if0.in2_r),
    .in3_r      (fft_if0.in3_r),
    .in4_r      (fft_if0.in4_r),
    .in5_r      (fft_if0.in5_r),
    .in6_r      (fft_if0.in6_r),
    .in7_r      (fft_if0.in7_r),
    .in0_imag   (fft_if0.in0_imag),
    .in1_imag   (fft_if0.in1_imag),
    .in2_imag   (fft_if0.in2_imag),
    .in3_imag   (fft_if0.in3_imag),
    .in4_imag   (fft_if0.in4_imag),
    .in5_imag   (fft_if0.in5_imag),
    .in6_imag   (fft_if0.in6_imag),
    .in7_imag   (fft_if0.in7_imag),
    // Outputs
    .out0_r     (fft_if0.out0_r),
    .out1_r     (fft_if0.out1_r),
    .out2_r     (fft_if0.out2_r),
    .out3_r     (fft_if0.out3_r),
    .out4_r     (fft_if0.out4_r),
    .out5_r     (fft_if0.out5_r),
    .out6_r     (fft_if0.out6_r),
    .out7_r     (fft_if0.out7_r),
    .out0_imag  (fft_if0.out0_imag),
    .out1_imag  (fft_if0.out1_imag),
    .out2_imag  (fft_if0.out2_imag),
    .out3_imag  (fft_if0.out3_imag),
    .out4_imag  (fft_if0.out4_imag),
    .out5_imag  (fft_if0.out5_imag),
    .out6_imag  (fft_if0.out6_imag),
    .out7_imag  (fft_if0.out7_imag)
  );
  // Environment
  fft_env env;
  initial begin
    env = new(fft_if0);
    env.run();
    // let the scoreboard decide
    #1100
    $display("[TB] Simulation finished.");
     $finish;
  end
endmodule
