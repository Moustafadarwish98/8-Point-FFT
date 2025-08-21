package scoreboard_pkg;
  import transaction_pkg::*;
    import coverage_pkg::*;

  class fft_scoreboard;
  // Parameters
  parameter WIDTH = 12;
  parameter WI_INT   = 6;
  parameter WI_FRAC  = WIDTH - WI_INT;
  parameter WO_INT   = 8;
  parameter WO_FRAC  = WIDTH - WO_INT;

    // Mailboxes: from generator and monitor
    mailbox #(fft_transaction) gen2scb;
    mailbox #(fft_transaction) mon2scb;
    fft_coverage cov;
    // Constructor
    function new(mailbox #(fft_transaction) gen2scb,
                 mailbox #(fft_transaction) mon2scb);
      this.gen2scb = gen2scb;
      this.mon2scb = mon2scb;
    endfunction

    function void set_cov(fft_coverage c);
      cov = c;
    endfunction

    // Run loop
    task run();
      fft_transaction gen_tr, mon_tr;
      forever begin
        // Get input+golden transaction from generator
        gen2scb.get(gen_tr);
        // Get DUT output transaction from monitor
        mon2scb.get(mon_tr);
        // Compare DUT vs golden
        compare(gen_tr, mon_tr);
      end
    endtask

// Comparison task
task compare(fft_transaction gen_tr, fft_transaction mon_tr);
  $display("\n[SCB] Comparing transaction %0d", gen_tr.id);
  // Table header
  $display("Idx |           Input            |           DUT(out)           |          Golden(out)");
  $display("----------------------------------------------------------------------------------------");
  for (int i = 0; i < fft_transaction::VEC_LEN; i++) begin
    $display("%2d  | (%10.6f + j%10.6f) | (%10.4f + j%10.4f) | (%10.4f + j%10.4f)",
             i,
             // Input
             gen_tr.in_r[i]/(1.0 * (1 << WI_FRAC)),
             gen_tr.in_i[i]/(1.0 * (1 << WI_FRAC)),

             // DUT output
             mon_tr.dut_r[i]/(1.0 * (1 << WO_FRAC)),
             mon_tr.dut_i[i]/(1.0 * (1 << WO_FRAC)),

             // Golden output
             gen_tr.golden_r[i]/(1.0 * (1 << WO_FRAC)),
             gen_tr.golden_i[i]/(1.0 * (1 << WO_FRAC)));
  end
  // Sample coverage if enabled
  if (cov) begin
    cov.sample_inputs(gen_tr);
    cov.sample_outputs(mon_tr);
    cov.sample_compare(gen_tr, mon_tr);
  end
  $display("----------------------------------------------------------------------------------------");
  $display("[SCB] Transaction %0d complete.\n", gen_tr.id);
endtask
  endclass
endpackage
