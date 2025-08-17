// =============================================================
// Fixed-point Zoomer (Resizer/Converter)
// Converts between two fixed-point formats (different integer
// and fractional bit widths). Supports rounding and overflow.
// =============================================================

module fxp_zoom #(
    // Input fixed-point format: (INT.IN + FRAC.IN)
    parameter INPUT_INT   = 8,   // Integer bits of input
    parameter INPUT_FRAC  = 8,   // Fractional bits of input

    // Output fixed-point format: (INT.OUT + FRAC.OUT)
    parameter OUTPUT_INT  = 8,   // Integer bits of output
    parameter OUTPUT_FRAC = 8,   // Fractional bits of output

    // Rounding control
    // 0 = truncate, 1 = round-to-nearest
    parameter ROUNDING    = 0
)(
    // Input fixed-point number (signed or unsigned depending
    // on how you interpret it externally)
    input  wire [INPUT_INT+INPUT_FRAC-1:0] in_val,

    // Output fixed-point number
    output wire [OUTPUT_INT+OUTPUT_FRAC-1:0] out_val,

    // Overflow flag (saturation occurred)
    output reg  overflow
);

  // ------------------------------------------------------------
  // Internal registers
  // ------------------------------------------------------------
  // Extended intermediate value after fractional adjustment
  reg [INPUT_INT+OUTPUT_FRAC-1:0] in_rescaled = 0;

  // Integer part extracted from rescaled input
  reg [INPUT_INT-1:0] in_integer = 0;

  // Final integer part for output
  reg [OUTPUT_INT-1:0] out_integer = 0;

  // Final fractional part for output
  reg [OUTPUT_FRAC-1:0] out_fraction = 0;

  // Initialize overflow to zero
  initial overflow = 1'b0;

  // ------------------------------------------------------------
  // Step 1: Adjust fractional width
  // ------------------------------------------------------------
  // If OUTPUT_FRAC < INPUT_FRAC → must drop some fractional bits
  // If OUTPUT_FRAC > INPUT_FRAC → must pad zeros (increase precision)
  // If OUTPUT_FRAC == INPUT_FRAC → pass-through
  // ------------------------------------------------------------

  generate
    if (OUTPUT_FRAC < INPUT_FRAC) begin : reduce_fractional
      // Case: reducing fractional resolution
      if (ROUNDING == 0) begin
        // Truncate: simply drop lower bits
        always @(*) in_rescaled = in_val[INPUT_INT+INPUT_FRAC-1 : INPUT_FRAC-OUTPUT_FRAC];
      end
      else if (INPUT_INT+OUTPUT_FRAC >= 2) begin
        // Round to nearest
        always @(*) begin
          in_rescaled = in_val[INPUT_INT+INPUT_FRAC-1 : INPUT_FRAC-OUTPUT_FRAC];
          // Check rounding bit
          if (in_val[INPUT_FRAC-OUTPUT_FRAC-1] &
              ~(~in_rescaled[INPUT_INT+OUTPUT_FRAC-1] &
               (&in_rescaled[INPUT_INT+OUTPUT_FRAC-2:0])))
            in_rescaled = in_rescaled + 1; // round up
        end
      end
      else begin
        // Degenerate small-width case
        always @(*) begin
          in_rescaled = in_val[INPUT_INT+INPUT_FRAC-1 : INPUT_FRAC-OUTPUT_FRAC];
          if (in_val[INPUT_FRAC-OUTPUT_FRAC-1] & in_rescaled[INPUT_INT+OUTPUT_FRAC-1])
            in_rescaled = in_rescaled + 1; // round up negative numbers properly
        end
      end
    end
    else if (OUTPUT_FRAC == INPUT_FRAC) begin : same_fractional
      // Case: equal fractional resolution → direct assignment
      always @(*) in_rescaled[INPUT_INT+OUTPUT_FRAC-1 : OUTPUT_FRAC-INPUT_FRAC] = in_val;
    end
    else begin : increase_fractional
      // Case: increasing fractional resolution → pad with zeros
      always @(*) begin
        in_rescaled[INPUT_INT+OUTPUT_FRAC-1 : OUTPUT_FRAC-INPUT_FRAC] = in_val;
        in_rescaled[OUTPUT_FRAC-INPUT_FRAC-1 : 0] = 0;
      end
    end
  endgenerate

  // ------------------------------------------------------------
  // Step 2: Adjust integer width (and detect overflow)
  // ------------------------------------------------------------
  // If OUTPUT_INT < INPUT_INT → possible overflow (saturation needed)
  // If OUTPUT_INT >= INPUT_INT → safe, just extend sign or zero
  // ------------------------------------------------------------

  generate
    if (OUTPUT_INT < INPUT_INT) begin : reduce_integer
      // Case: reducing integer range → check for overflow
      always @(*) begin
        {in_integer, out_fraction} = in_rescaled;

        // Positive overflow detection:
        // If input is positive and higher bits don't fit
        if (~in_integer[INPUT_INT-1] & |in_integer[INPUT_INT-2:OUTPUT_INT-1]) begin
          overflow   = 1'b1;
          out_integer = {OUTPUT_INT{1'b1}};   // max positive
          out_integer[OUTPUT_INT-1] = 1'b0;   // clear sign
          out_fraction = {OUTPUT_FRAC{1'b1}}; // fractional max
        end
        // Negative overflow detection:
        // If input is negative and high bits are not all 1s
        else if (in_integer[INPUT_INT-1] & ~(&in_integer[INPUT_INT-2:OUTPUT_INT-1])) begin
          overflow   = 1'b1;
          out_integer = 0;
          out_integer[OUTPUT_INT-1] = 1'b1;   // min negative
          out_fraction = 0;
        end
        else begin
          // No overflow → safe fit
          overflow = 1'b0;
          out_integer = in_integer[OUTPUT_INT-1:0];
        end
      end
    end
    else begin : extend_integer
      // Case: extending integer width → safe, just sign-extend
      always @(*) begin
        {in_integer, out_fraction} = in_rescaled;
        overflow = 1'b0;
        // If input is negative, fill extra bits with 1's
        out_integer = in_integer[INPUT_INT-1] ? {OUTPUT_INT{1'b1}} : 0;
        out_integer[INPUT_INT-1:0] = in_integer;
      end
    end
  endgenerate

  // ------------------------------------------------------------
  // Final concatenated output
  // ------------------------------------------------------------
  assign out_val = {out_integer, out_fraction};

endmodule
