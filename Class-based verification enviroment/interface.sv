interface fft_if #(
    // Parameters
  parameter int WIDTH     = 12,
  parameter int WI_INT    = 6,
  parameter int WI_FRAC   = WIDTH - WI_INT,
  parameter int WO_INT    = 8,
  parameter int WO_FRAC   = WIDTH - WO_INT,
  parameter int OP_WIDTH  = WO_INT + WO_FRAC,
  parameter int TW_FRAC   = 10,
  parameter int TW_IN     = 2,
  parameter int IP_WIDTH  = WI_INT + WI_FRAC,
  parameter int VEC_LEN           = 8,   
  parameter int PIPELINE_LATENCY  = 6    
)(
  input  logic clk
);
  // ========= Reset =========
  logic rst_n;
  // ========= DUT Inputs =========
  logic signed [IP_WIDTH-1:0] in0_r, in1_r, in2_r, in3_r, in4_r, in5_r, in6_r, in7_r;
  logic signed [IP_WIDTH-1:0] in0_imag, in1_imag, in2_imag, in3_imag,
                              in4_imag, in5_imag, in6_imag, in7_imag;
  // ========= DUT Outputs =========
  logic signed [OP_WIDTH-1:0] out0_r, out1_r, out2_r, out3_r, out4_r, out5_r, out6_r, out7_r;
  logic signed [OP_WIDTH-1:0] out0_imag, out1_imag, out2_imag, out3_imag,
                              out4_imag, out5_imag, out6_imag, out7_imag;
  // ========= Modports =========
  // For DUT connection 
  modport DUT (
    input  clk, rst_n,
    input  in0_r, in1_r, in2_r, in3_r, in4_r, in5_r, in6_r, in7_r,
    input  in0_imag, in1_imag, in2_imag, in3_imag, in4_imag, in5_imag, in6_imag, in7_imag,
    output out0_r, out1_r, out2_r, out3_r, out4_r, out5_r, out6_r, out7_r,
    output out0_imag, out1_imag, out2_imag, out3_imag, out4_imag, out5_imag, out6_imag, out7_imag
  );
  // For driver 
  modport DRV (
    input  clk,
    output rst_n,
    output in0_r, in1_r, in2_r, in3_r, in4_r, in5_r, in6_r, in7_r,
    output in0_imag, in1_imag, in2_imag, in3_imag, in4_imag, in5_imag, in6_imag, in7_imag
  );
  // For monitor 
  modport MON (
    input  clk, rst_n,
    input  in0_r, in1_r, in2_r, in3_r, in4_r, in5_r, in6_r, in7_r,
    input  in0_imag, in1_imag, in2_imag, in3_imag, in4_imag, in5_imag, in6_imag, in7_imag,
    input  out0_r, out1_r, out2_r, out3_r, out4_r, out5_r, out6_r, out7_r,
    input  out0_imag, out1_imag, out2_imag, out3_imag, out4_imag, out5_imag, out6_imag, out7_imag
  );
endinterface