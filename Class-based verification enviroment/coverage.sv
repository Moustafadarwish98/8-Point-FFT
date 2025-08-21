package coverage_pkg;
  import transaction_pkg::*;

  class fft_coverage;
    // Parameters
    localparam int IPW    = fft_transaction::IP_WIDTH;
    localparam int OPW    = fft_transaction::OP_WIDTH;
    localparam int VECLEN = fft_transaction::VEC_LEN;

    int                       idx;        
    bit signed [IPW-1:0]      cur_in_r, cur_in_i;
    bit signed [OPW-1:0]      cur_out_r, cur_out_i;
    bit                       cur_mismatch;

    // ---------- Input coverage ----------
    covergroup cg_inputs with function sample();
      option.per_instance = 1;

      idx_cp : coverpoint idx { bins lanes[] = {[0:VECLEN-1]}; }

      in_r_val : coverpoint cur_in_r {
        bins zero      = {0};
        bins small_pos = {[  1:   7]};
        bins small_neg = {[ -7:  -1]};
        bins mid_pos   = {[  8:  63]};
        bins mid_neg   = {[ -63:  -8]};
        bins large_pos = {[ 64: (1<<(IPW-1))-1]};
        bins large_neg = {[ -(1<<(IPW-1)) : -64 ]};
      }

      in_i_val : coverpoint cur_in_i {
        bins zero      = {0};
        bins small_pos = {[  1:   7]};
        bins small_neg = {[ -7:  -1]};
        bins mid_pos   = {[  8:  63]};
        bins mid_neg   = {[ -63:  -8]};
        bins large_pos = {[ 64: (1<<(IPW-1))-1]};
        bins large_neg = {[ -(1<<(IPW-1)) : -64 ]};
      }
      //in_cross : cross in_r_val, in_i_val;
    endgroup
    // ---------- Output coverage ----------
    covergroup cg_outputs with function sample();
      option.per_instance = 1;

      idx_cp : coverpoint idx { bins lanes[] = {[0:VECLEN-1]}; }

      out_r_val : coverpoint cur_out_r {
        bins zero      = {0};
        bins pos       = {[               1 :  (1<<(OPW-1))-1]};
        bins neg       = {[ -(1<<(OPW-1)) :             -1 ]};
      }

      out_i_val : coverpoint cur_out_i {
        bins zero      = {0};
        bins pos       = {[               1 :  (1<<(OPW-1))-1]};
        bins neg       = {[ -(1<<(OPW-1)) :             -1 ]};
      }
      //out_cross : cross out_r_val, out_i_val;
    endgroup

    covergroup cg_match with function sample();
      option.per_instance = 1;

      idx_cp   : coverpoint idx { bins lanes[] = {[0:VECLEN-1]}; }
      result_cp: coverpoint cur_mismatch { bins MATCH = {0}; bins MISMATCH = {1}; }
      //cross_idx_result : cross idx_cp, result_cp;
    endgroup

    // Constructor
    function new();
      cg_inputs  = new();
      cg_outputs = new();
      cg_match   = new();
    endfunction
    // 1) Inputs-only (call once per transaction)
    function void sample_inputs(fft_transaction tr);
      for (int i = 0; i < VECLEN; i++) begin
        idx      = i;
        cur_in_r = tr.in_r[i];
        cur_in_i = tr.in_i[i];
        cg_inputs.sample();
      end
    endfunction

    // 2) Outputs-only (call once per transaction)
    function void sample_outputs(fft_transaction tr);
      for (int i = 0; i < VECLEN; i++) begin
        idx       = i;
        cur_out_r = tr.dut_r[i];
        cur_out_i = tr.dut_i[i];
        cg_outputs.sample();
      end
    endfunction

    // 3) Match vs mismatch per lane 
    function void sample_compare(fft_transaction gen_tr, fft_transaction mon_tr);
      for (int i = 0; i < VECLEN; i++) begin
        idx          = i;
        cur_mismatch = ((mon_tr.dut_r[i] !== gen_tr.golden_r[i]) ||
                        (mon_tr.dut_i[i] !== gen_tr.golden_i[i]));
        cg_match.sample();
      end
    endfunction
  endclass
endpackage
