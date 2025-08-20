// ============================================================================
// stage3_butterfly.sv
// Stage-3 (final) butterfly for 8-point DIT FFT
// Inputs:  Q7.5  (IP_WIDTH = 12)
// Outputs: Q8.4  (OP_WIDTH = 12)
// Twiddles: Q2.10
// Uses explicit, unrolled fxp_multiplier and fxp_zoom instances (no generate)
// ============================================================================

module stage3_butterfly_full_mul #(
  parameter WIDTH   = 12,
  parameter WI_INT  = 7,                       // data integer bits (Q7.5)
  parameter WI_FRAC = WIDTH - WI_INT,          // 5
  parameter WO_INT  = 8,                       // output integer bits (Q8.4)
  parameter WO_FRAC = WIDTH - WO_INT,          // 4
  parameter OP_WIDTH = WO_INT + WO_FRAC,       // 12
  parameter IP_WIDTH = WI_INT + WI_FRAC,       // 12
  parameter TW_INT  = 2,                       // twiddle integer bits (Q2.10)
  parameter TW_FRAC = 10,
  parameter ROUND   = 1                        // rounding on final zoom
)(
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

  // Twiddle inputs for groups 0..3 in_val Q2.10
  input  wire signed [TW_INT+TW_FRAC-1:0] tw0_r,
  input  wire signed [TW_INT+TW_FRAC-1:0] tw0_i,
  input  wire signed [TW_INT+TW_FRAC-1:0] tw1_r,
  input  wire signed [TW_INT+TW_FRAC-1:0] tw1_i,
  input  wire signed [TW_INT+TW_FRAC-1:0] tw2_r,
  input  wire signed [TW_INT+TW_FRAC-1:0] tw2_i,
  input  wire signed [TW_INT+TW_FRAC-1:0] tw3_r,
  input  wire signed [TW_INT+TW_FRAC-1:0] tw3_i,

  input  wire clk,
  input  wire rst_n,

  output reg signed [OP_WIDTH-1:0] stage3_out0_r,
  output reg signed [OP_WIDTH-1:0] stage3_out1_r,
  output reg signed [OP_WIDTH-1:0] stage3_out2_r,
  output reg signed [OP_WIDTH-1:0] stage3_out3_r,
  output reg signed [OP_WIDTH-1:0] stage3_out4_r,
  output reg signed [OP_WIDTH-1:0] stage3_out5_r,
  output reg signed [OP_WIDTH-1:0] stage3_out6_r,
  output reg signed [OP_WIDTH-1:0] stage3_out7_r,
  output reg signed [OP_WIDTH-1:0] stage3_out0_imag,
  output reg signed [OP_WIDTH-1:0] stage3_out1_imag,
  output reg signed [OP_WIDTH-1:0] stage3_out2_imag,
  output reg signed [OP_WIDTH-1:0] stage3_out3_imag,
  output reg signed [OP_WIDTH-1:0] stage3_out4_imag,
  output reg signed [OP_WIDTH-1:0] stage3_out5_imag,
  output reg signed [OP_WIDTH-1:0] stage3_out6_imag,
  output reg signed [OP_WIDTH-1:0] stage3_out7_imag
);

  // ------------------------------------------------------------------
  // Intermediate width parameters (explicit)
  // data Q7.5 * tw Q2.10 -> product Q9.15
  // sum/diff of two products -> Q10.15
  // final zoom -> Q8.4
  // ------------------------------------------------------------------
  localparam PROD_INT  = WI_INT + TW_INT;    // 9
  localparam PROD_FRAC = WI_FRAC + TW_FRAC;  // 15
  localparam PROD_W    = PROD_INT + PROD_FRAC; // 24

  localparam SUM_INT   = PROD_INT + 1;       // 10
  localparam SUM_FRAC  = PROD_FRAC;          // 15
  localparam SUM_W     = SUM_INT + SUM_FRAC; // 25

  // ------------------------------------------------------------------
  // Products (explicit, 4 multiplies per group, 4 groups => 16 fxp_multiplier)
  // Each product is signed [PROD_W-1:0]
  // naming: p_<group>_<term>
  // term: ar_cr (a_r*tw_r), ai_di (a_i*tw_i), ar_di (a_r*tw_i), ai_cr (a_i*tw_r)
  // ------------------------------------------------------------------
  // Group 0 (a=in0, b=in4) products
  wire signed [PROD_W-1:0] p0_ar_cr;
  wire signed [PROD_W-1:0] p0_ai_di;
  wire signed [PROD_W-1:0] p0_ar_di;
  wire signed [PROD_W-1:0] p0_ai_cr;

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul0_ar_cr (.operand_a(in4_r), .operand_b(tw0_r), .result(p0_ar_cr), .overflow());

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul0_ai_di (.operand_a(in4_imag), .operand_b(tw0_i), .result(p0_ai_di), .overflow());

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul0_ar_di (.operand_a(in4_r), .operand_b(tw0_i), .result(p0_ar_di), .overflow());

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul0_ai_cr (.operand_a(in4_imag), .operand_b(tw0_r), .result(p0_ai_cr), .overflow());

  // Group 1 (a=in1, b=in5)
  wire signed [PROD_W-1:0] p1_ar_cr;
  wire signed [PROD_W-1:0] p1_ai_di;
  wire signed [PROD_W-1:0] p1_ar_di;
  wire signed [PROD_W-1:0] p1_ai_cr;

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul1_ar_cr (.operand_a(in5_r), .operand_b(tw1_r), .result(p1_ar_cr), .overflow());

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul1_ai_di (.operand_a(in5_imag), .operand_b(tw1_i), .result(p1_ai_di), .overflow());

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul1_ar_di (.operand_a(in5_r), .operand_b(tw1_i), .result(p1_ar_di), .overflow());

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul1_ai_cr (.operand_a(in5_imag), .operand_b(tw1_r), .result(p1_ai_cr), .overflow());

  // Group 2 (a=in2, b=in6)
  wire signed [PROD_W-1:0] p2_ar_cr;
  wire signed [PROD_W-1:0] p2_ai_di;
  wire signed [PROD_W-1:0] p2_ar_di;
  wire signed [PROD_W-1:0] p2_ai_cr;

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul2_ar_cr (.operand_a(in6_r), .operand_b(tw2_r), .result(p2_ar_cr), .overflow());

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul2_ai_di (.operand_a(in6_imag), .operand_b(tw2_i), .result(p2_ai_di), .overflow());

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul2_ar_di (.operand_a(in6_r), .operand_b(tw2_i), .result(p2_ar_di), .overflow());

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul2_ai_cr (.operand_a(in6_imag), .operand_b(tw2_r), .result(p2_ai_cr), .overflow());

  // Group 3 (a=in3, b=in7)
  wire signed [PROD_W-1:0] p3_ar_cr;
  wire signed [PROD_W-1:0] p3_ai_di;
  wire signed [PROD_W-1:0] p3_ar_di;
  wire signed [PROD_W-1:0] p3_ai_cr;

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul3_ar_cr (.operand_a(in7_r), .operand_b(tw3_r), .result(p3_ar_cr), .overflow());

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul3_ai_di (.operand_a(in7_imag), .operand_b(tw3_i), .result(p3_ai_di), .overflow());

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul3_ar_di (.operand_a(in7_r), .operand_b(tw3_i), .result(p3_ar_di), .overflow());

  fxp_multiplier #(.A_INT(WI_INT), .A_FRAC(WI_FRAC), .B_INT(TW_INT), .B_FRAC(TW_FRAC),
            .OUT_INT(PROD_INT), .OUT_FRAC(PROD_FRAC), .ROUNDING(ROUND))
    mul3_ai_cr (.operand_a(in7_imag), .operand_b(tw3_r), .result(p3_ai_cr), .overflow());

  // ------------------------------------------------------------------
  // Combine products into complex product (wr_tmp, wi_tmp) for each group
  // wr_tmp = ar_cr - ai_di  (signed SUM_W)
  // wi_tmp = ar_di + ai_cr
  // ------------------------------------------------------------------
  wire signed [SUM_W-1:0] wr0_tmp = $signed(p0_ar_cr) - $signed(p0_ai_di);
  wire signed [SUM_W-1:0] wi0_tmp = $signed(p0_ar_di) + $signed(p0_ai_cr);

  wire signed [SUM_W-1:0] wr1_tmp = $signed(p1_ar_cr) - $signed(p1_ai_di);
  wire signed [SUM_W-1:0] wi1_tmp = $signed(p1_ar_di) + $signed(p1_ai_cr);

  wire signed [SUM_W-1:0] wr2_tmp = $signed(p2_ar_cr) - $signed(p2_ai_di);
  wire signed [SUM_W-1:0] wi2_tmp = $signed(p2_ar_di) + $signed(p2_ai_cr);

  wire signed [SUM_W-1:0] wr3_tmp = $signed(p3_ar_cr) - $signed(p3_ai_di);
  wire signed [SUM_W-1:0] wi3_tmp = $signed(p3_ar_di) + $signed(p3_ai_cr);

  // ------------------------------------------------------------------
  // Align 'a' (Q7.5) into SUM scale (Q10.15): left-shift fractional part
  // SHIFT = SUM_FRAC - WI_FRAC = 15 - 5 = 10
  // We sign-extend 'a' into SUM_W then shift left by 10 by concatenation
  // ------------------------------------------------------------------
  wire signed [SUM_W-1:0] a0_r_wide = $signed({{(SUM_W-IP_WIDTH){in0_r[IP_WIDTH-1]}}, in0_r}) <<< (SUM_FRAC - WI_FRAC);
  wire signed [SUM_W-1:0] a0_i_wide = $signed({{(SUM_W-IP_WIDTH){in0_imag[IP_WIDTH-1]}}, in0_imag}) <<< (SUM_FRAC - WI_FRAC);

  wire signed [SUM_W-1:0] a1_r_wide = $signed({{(SUM_W-IP_WIDTH){in1_r[IP_WIDTH-1]}}, in1_r}) <<< (SUM_FRAC - WI_FRAC);
  wire signed [SUM_W-1:0] a1_i_wide = $signed({{(SUM_W-IP_WIDTH){in1_imag[IP_WIDTH-1]}}, in1_imag}) <<< (SUM_FRAC - WI_FRAC);

  wire signed [SUM_W-1:0] a2_r_wide = $signed({{(SUM_W-IP_WIDTH){in2_r[IP_WIDTH-1]}}, in2_r}) <<< (SUM_FRAC - WI_FRAC);
  wire signed [SUM_W-1:0] a2_i_wide = $signed({{(SUM_W-IP_WIDTH){in2_imag[IP_WIDTH-1]}}, in2_imag}) <<< (SUM_FRAC - WI_FRAC);

  wire signed [SUM_W-1:0] a3_r_wide = $signed({{(SUM_W-IP_WIDTH){in3_r[IP_WIDTH-1]}}, in3_r}) <<< (SUM_FRAC - WI_FRAC);
  wire signed [SUM_W-1:0] a3_i_wide = $signed({{(SUM_W-IP_WIDTH){in3_imag[IP_WIDTH-1]}}, in3_imag}) <<< (SUM_FRAC - WI_FRAC);

  // ------------------------------------------------------------------
  // Compute A = a + product, B = a - product for each group (wide)
  // Then zoom (SUM_INT:SUM_FRAC -> WO_INT:WO_FRAC) using fxp_zoom
  // Outputs arranged: for group k produce temp[2k] = A, temp[2k+1] = B
  // ------------------------------------------------------------------
  // Group 0: positions 0 and 4
  wire signed [SUM_W-1:0] A0_r_wide = a0_r_wide + wr0_tmp;
  wire signed [SUM_W-1:0] A0_i_wide = a0_i_wide + wi0_tmp;
  wire signed [SUM_W-1:0] B0_r_wide = a0_r_wide - wr0_tmp;
  wire signed [SUM_W-1:0] B0_i_wide = a0_i_wide - wi0_tmp;

  wire [OP_WIDTH-1:0] temp_r [0:7];
  wire [OP_WIDTH-1:0] temp_i [0:7];

  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom0_A_r (.in_val($unsigned(A0_r_wide)), .out_val(temp_r[0]), .overflow());
  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom0_A_i (.in_val($unsigned(A0_i_wide)), .out_val(temp_i[0]), .overflow());
  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom0_B_r (.in_val($unsigned(B0_r_wide)), .out_val(temp_r[4]), .overflow());
  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom0_B_i (.in_val($unsigned(B0_i_wide)), .out_val(temp_i[4]), .overflow());

  // Group 1: positions 1 and 5
  wire signed [SUM_W-1:0] A1_r_wide = a1_r_wide + wr1_tmp;
  wire signed [SUM_W-1:0] A1_i_wide = a1_i_wide + wi1_tmp;
  wire signed [SUM_W-1:0] B1_r_wide = a1_r_wide - wr1_tmp;
  wire signed [SUM_W-1:0] B1_i_wide = a1_i_wide - wi1_tmp;

  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom1_A_r (.in_val($unsigned(A1_r_wide)), .out_val(temp_r[1]), .overflow());
  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom1_A_i (.in_val($unsigned(A1_i_wide)), .out_val(temp_i[1]), .overflow());
  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom1_B_r (.in_val($unsigned(B1_r_wide)), .out_val(temp_r[5]), .overflow());
  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom1_B_i (.in_val($unsigned(B1_i_wide)), .out_val(temp_i[5]), .overflow());

  // Group 2: positions 2 and 6
  wire signed [SUM_W-1:0] A2_r_wide = a2_r_wide + wr2_tmp;
  wire signed [SUM_W-1:0] A2_i_wide = a2_i_wide + wi2_tmp;
  wire signed [SUM_W-1:0] B2_r_wide = a2_r_wide - wr2_tmp;
  wire signed [SUM_W-1:0] B2_i_wide = a2_i_wide - wi2_tmp;

  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom2_A_r (.in_val($unsigned(A2_r_wide)), .out_val(temp_r[2]), .overflow());
  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom2_A_i (.in_val($unsigned(A2_i_wide)), .out_val(temp_i[2]), .overflow());
  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom2_B_r (.in_val($unsigned(B2_r_wide)), .out_val(temp_r[6]), .overflow());
  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom2_B_i (.in_val($unsigned(B2_i_wide)), .out_val(temp_i[6]), .overflow());

  // Group 3: positions 3 and 7
  wire signed [SUM_W-1:0] A3_r_wide = a3_r_wide + wr3_tmp;
  wire signed [SUM_W-1:0] A3_i_wide = a3_i_wide + wi3_tmp;
  wire signed [SUM_W-1:0] B3_r_wide = a3_r_wide - wr3_tmp;
  wire signed [SUM_W-1:0] B3_i_wide = a3_i_wide - wi3_tmp;

  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom3_A_r (.in_val($unsigned(A3_r_wide)), .out_val(temp_r[3]), .overflow());
  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom3_A_i (.in_val($unsigned(A3_i_wide)), .out_val(temp_i[3]), .overflow());
  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom3_B_r (.in_val($unsigned(B3_r_wide)), .out_val(temp_r[7]), .overflow());
  fxp_zoom #(.INPUT_INT(SUM_INT), .INPUT_FRAC(SUM_FRAC), .OUTPUT_INT(WO_INT), .OUTPUT_FRAC(WO_FRAC), .ROUNDING(ROUND))
    zoom3_B_i (.in_val($unsigned(B3_i_wide)), .out_val(temp_i[7]), .overflow());

  // ------------------------------------------------------------------
  // Register outputs (one-cycle latency)
  // ------------------------------------------------------------------
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      stage3_out0_r <= 0; stage3_out0_imag <= 0;
      stage3_out1_r <= 0; stage3_out1_imag <= 0;
      stage3_out2_r <= 0; stage3_out2_imag <= 0;
      stage3_out3_r <= 0; stage3_out3_imag <= 0;
      stage3_out4_r <= 0; stage3_out4_imag <= 0;
      stage3_out5_r <= 0; stage3_out5_imag <= 0;
      stage3_out6_r <= 0; stage3_out6_imag <= 0;
      stage3_out7_r <= 0; stage3_out7_imag <= 0;
    end else begin
      stage3_out0_r <= temp_r[0]; stage3_out0_imag <= temp_i[0];
      stage3_out1_r <= temp_r[1]; stage3_out1_imag <= temp_i[1];
      stage3_out2_r <= temp_r[2]; stage3_out2_imag <= temp_i[2];
      stage3_out3_r <= temp_r[3]; stage3_out3_imag <= temp_i[3];
      stage3_out4_r <= temp_r[4]; stage3_out4_imag <= temp_i[4];
      stage3_out5_r <= temp_r[5]; stage3_out5_imag <= temp_i[5];
      stage3_out6_r <= temp_r[6]; stage3_out6_imag <= temp_i[6];
      stage3_out7_r <= temp_r[7]; stage3_out7_imag <= temp_i[7];
    end
  end

endmodule
