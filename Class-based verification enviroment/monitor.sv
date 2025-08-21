package monitor_pkg;
  import transaction_pkg::*;

  class fft_monitor;
    // Handle to interface 
    virtual fft_if.MON vif;
    // Mailbox to send completed transactions to scoreboard
    mailbox #(fft_transaction) mon2scb;
    // Pipeline latency 
    int PIPELINE_LATENCY;
    // Internal cycle counter
    int cycle_count;
    // Constructor
    function new(virtual fft_if.MON vif,
                 mailbox #(fft_transaction) mon2scb,
                 int PIPELINE_LATENCY = 6);
      this.vif              = vif;
      this.mon2scb          = mon2scb;
      this.PIPELINE_LATENCY = PIPELINE_LATENCY;
      cycle_count           = 0;
    endfunction
    // Main run task
    task run();
      fft_transaction tr;
      forever begin
        if (!vif.rst_n) begin
          cycle_count = 0;
        end else begin
          cycle_count++;
        end
        @(negedge vif.clk);
        // Wait until pipeline latency has passed
        if (cycle_count >= PIPELINE_LATENCY ) begin
          // Create new transaction container
          tr = new(cycle_count);
          // Capture DUT outputs 
          tr.dut_r[0] = vif.out0_r;  tr.dut_i[0] = vif.out0_imag;
          tr.dut_r[1] = vif.out1_r;  tr.dut_i[1] = vif.out1_imag;
          tr.dut_r[2] = vif.out2_r;  tr.dut_i[2] = vif.out2_imag;
          tr.dut_r[3] = vif.out3_r;  tr.dut_i[3] = vif.out3_imag;
          tr.dut_r[4] = vif.out4_r;  tr.dut_i[4] = vif.out4_imag;
          tr.dut_r[5] = vif.out5_r;  tr.dut_i[5] = vif.out5_imag;
          tr.dut_r[6] = vif.out6_r;  tr.dut_i[6] = vif.out6_imag;
          tr.dut_r[7] = vif.out7_r;  tr.dut_i[7] = vif.out7_imag;
          // Send transaction to scoreboard
          mon2scb.put(tr);
          $display("[MONITOR] Captured DUT outputs at cycle %0d", cycle_count);
        end
      end
    endtask

  endclass
endpackage