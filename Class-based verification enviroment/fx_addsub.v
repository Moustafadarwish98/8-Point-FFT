// ============================================================================
// fxp_addsub.sv
// Fixed-Point Adder/Subtractor
//
// Adds or subtracts two signed fixed-point values with possibly different
// integer and fractional widths. Internally aligns both operands to a
// common format, performs addition/subtraction, then resizes (zoom) the
// result into the desired output format.
//
// Notes:
// - Operands are interpreted as two's complement.
// - Subtraction is performed via two’s complement negation of operand B.
// - fxp_zoom is used to align inputs to a common format and to resize
//   the final result with saturation/overflow handling.
// ============================================================================
module fxp_addsub #(
    // Operand A format
    parameter A_INT   = 7,   // integer bits for operand A
    parameter A_FRAC  = 5,   // fractional bits for operand A

    // Operand B format
    parameter B_INT   = 7,   // integer bits for operand B
    parameter B_FRAC  = 5,   // fractional bits for operand B

    // Output format
    parameter OUT_INT = 7,   // output integer bits
    parameter OUT_FRAC= 5,   // output fractional bits

    // Rounding control
    parameter ROUNDING= 0    // enable rounding in_val final zoom
  )(
    input  wire [A_INT+A_FRAC-1:0] operand_a, // fixed-point input A
    input  wire [B_INT+B_FRAC-1:0] operand_b, // fixed-point input B
    input  wire                    subtract,  // 0 = add, 1 = subtract
    output wire [OUT_INT+OUT_FRAC-1:0] result, // fixed-point output
    output wire                    overflow   // overflow indicator
  );

  // ==========================================================================
  // Step 1: Determine common internal widths
  // ==========================================================================
  localparam B_INT_EXT  = B_INT + 1;   // B extended by 1 integer bit (sign ext)
  localparam COMMON_INT = (A_INT > B_INT_EXT) ? A_INT : B_INT_EXT; // max integer
  localparam COMMON_FRAC= (A_FRAC > B_FRAC)   ? A_FRAC: B_FRAC;    // max fractional
  localparam RES_INT    = COMMON_INT + 1;  // add 1 more bit for carry/overflow
  localparam RES_FRAC   = COMMON_FRAC;     // fractional width remains same

  // ==========================================================================
  // Step 2: Internal signals
  // ==========================================================================
  localparam [B_INT_EXT+B_FRAC-1:0] CONST_ONE = 1; // constant "1" for negation
  wire [B_INT_EXT+B_FRAC-1:0] operand_b_ext; // sign-extended version of operand B
  wire [COMMON_INT+COMMON_FRAC-1:0] operand_a_aligned; // operand A zoomed
  wire [COMMON_INT+COMMON_FRAC-1:0] operand_b_aligned; // operand B zoomed (after sub)
  wire [B_INT_EXT+B_FRAC-1:0] operand_b_negated;       // optional negated B

  // ==========================================================================
  // Step 3: Subtraction handled as two's complement negation
  // ==========================================================================
  assign operand_b_negated = subtract ? (~operand_b_ext) + CONST_ONE
         : operand_b_ext;

  // ==========================================================================
  // Step 4: Perform signed addition
  // ==========================================================================
  wire signed [RES_INT+RES_FRAC-1:0] res_sum =
       $signed(operand_a_aligned) + $signed(operand_b_aligned);

  // ==========================================================================
  // Step 5: Input zooming/extension
  // ==========================================================================

  // Extend operand B by one integer bit (sign extend)
  fxp_zoom #(
             .INPUT_INT  (B_INT),  .INPUT_FRAC    (B_FRAC),
             .OUTPUT_INT   (B_INT_EXT), .OUTPUT_FRAC (B_FRAC),
             .ROUNDING (0)
           ) b_extend (
             .in_val (operand_b),
             .out_val(operand_b_ext),
             .overflow()
           );

  // Zoom operand A to common width (COMMON_INT:COMMON_FRAC)
  fxp_zoom #(
             .INPUT_INT    (A_INT),  .INPUT_FRAC  (A_FRAC),
             .OUTPUT_INT    (COMMON_INT), .OUTPUT_FRAC (COMMON_FRAC),
             .ROUNDING (0)
           ) a_zoom (
             .in_val (operand_a),
             .out_val(operand_a_aligned),
             .overflow()
           );

  // Zoom operand B (possibly negated) to common width
  fxp_zoom #(
             .INPUT_INT    (B_INT_EXT), .INPUT_FRAC  (B_FRAC),
             .OUTPUT_INT    (COMMON_INT), .OUTPUT_FRAC (COMMON_FRAC),
             .ROUNDING (0)
           ) b_zoom (
             .in_val (operand_b_negated),
             .out_val(operand_b_aligned),
             .overflow()
           );

  // ==========================================================================
  // Step 6: Final zoom of result to desired output width
  // ==========================================================================
  fxp_zoom #(
             .INPUT_INT    (RES_INT), .INPUT_FRAC  (RES_FRAC),
             .OUTPUT_INT    (OUT_INT), .OUTPUT_FRAC (OUT_FRAC),
             .ROUNDING (ROUNDING)
           ) result_zoom (
             .in_val (res_sum),
             .out_val(result),
             .overflow(overflow)
           );

endmodule
