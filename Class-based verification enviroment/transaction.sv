package transaction_pkg;

  class fft_transaction;

    // Parameters
    localparam int VEC_LEN   = 8;
    localparam int IP_WIDTH  = 12;
    localparam int OP_WIDTH  = 12;
    localparam int PIPELINE_LATENCY  = 6;

    int id;  // vector number

    // input samples
    bit signed [IP_WIDTH-1:0] in_r [VEC_LEN];
    bit signed [IP_WIDTH-1:0] in_i [VEC_LEN];

    // Golden reference
    bit signed [OP_WIDTH-1:0] golden_r [VEC_LEN];
    bit signed [OP_WIDTH-1:0] golden_i [VEC_LEN];

    // DUT captured outputs
    bit signed [OP_WIDTH-1:0] dut_r [VEC_LEN];
    bit signed [OP_WIDTH-1:0] dut_i [VEC_LEN];

    function new(int id = 0);
      this.id = id;
    endfunction

  endclass

endpackage