// ============================================================================
// fxp_multiplier.sv
// Fixed-point multiplier wrapper
//
// Multiplies two signed fixed-point values and resizes the result.
// Uses fxp_zoom to adjust fractional precision and detect saturation.
//
// Notes:
// - Inputs are treated as two's complement (signed).
// - Result is sign-correct because multiplication uses $signed().
// - fxp_zoom handles fractional truncation/rounding and saturation.
// ============================================================================
module fxp_multiplier #(
    // Operand A format
    parameter A_INT   = 8,  // integer bits of operand A
    parameter A_FRAC  = 8,  // fractional bits of operand A

    // Operand B format
    parameter B_INT   = 8,  // integer bits of operand B
    parameter B_FRAC  = 8,  // fractional bits of operand B

    // Output format
    parameter OUT_INT = 8,  // integer bits of output (includes sign)
    parameter OUT_FRAC= 8,  // fractional bits of output

    // Rounding control
    parameter ROUNDING= 0   // 0 = truncate, 1 = round-to-nearest
  )(
    // Fixed-point operands (two's complement encoded)
    input  wire [A_INT+A_FRAC-1:0] operand_a,
    input  wire [B_INT+B_FRAC-1:0] operand_b,

    // Resized result
    output wire [OUT_INT+OUT_FRAC-1:0] result,

    // Overflow indicator (set if saturation applied)
    output wire                        overflow
  );

  // -------------------------
  // Step 1: Define intermediate raw product widths
  // -------------------------
  localparam PROD_INT  = A_INT + B_INT;   // integer part of raw product
  localparam PROD_FRAC = A_FRAC + B_FRAC; // fractional part of raw product

  // -------------------------
  // Step 2: Perform signed multiplication
  // -------------------------
  // Inputs are cast to $signed() to ensure correct two's complement multiply.
  // The raw product "prod_raw" has PROD_INT + PROD_FRAC bits.
  wire signed [PROD_INT+PROD_FRAC-1:0] prod_raw =
       $signed(operand_a) * $signed(operand_b);

  // -------------------------
  // Step 3: Resize using fxp_zoom
  // -------------------------
  // fxp_zoom will:
  //  - Align fractional bits (PROD_FRAC -> OUT_FRAC)
  //  - Round or truncate if needed
  //  - Detect integer overflow (PROD_INT -> OUT_INT)
  //  - Saturate on overflow
  fxp_zoom #(
             .INPUT_INT   (PROD_INT),   // input integer bits
             .INPUT_FRAC   (PROD_FRAC),  // input fractional bits
             .OUTPUT_INT   (OUT_INT),    // output integer bits
             .OUTPUT_FRAC   (OUT_FRAC),   // output fractional bits
             .ROUNDING (ROUNDING)    // rounding/truncation control
           ) resize_inst (
             .in_val       ( prod_raw) ,
             .out_val      ( result ),     // resized output
             .overflow ( overflow )        // overflow flag
           );

endmodule
