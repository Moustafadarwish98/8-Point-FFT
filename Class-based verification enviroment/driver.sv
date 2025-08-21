package driver_pkg;
  import transaction_pkg::*;

  class fft_driver;
    // Handle to interface 
    virtual fft_if.DRV vif;
    // Mailbox from generator
    mailbox #(fft_transaction) gen2drv;
    // Constructor
    function new(virtual fft_if.DRV vif,
                 mailbox #(fft_transaction) gen2drv);
      this.vif     = vif;
      this.gen2drv = gen2drv;
    endfunction

    // Apply reset 
    task apply_reset();
      $display("[DRIVER] Applying reset...");
      vif.rst_n <= 0;
      repeat (2) @(negedge vif.clk);
      vif.rst_n <= 1;
      $display("[DRIVER] Reset deasserted.");
    endtask

    // Main run loop
    task run();
      fft_transaction tr;

      // Initialize
      vif.rst_n <= 1;
      vif.in0_r <= 0; vif.in0_imag <= 0;
      vif.in1_r <= 0; vif.in1_imag <= 0;
      vif.in2_r <= 0; vif.in2_imag <= 0;
      vif.in3_r <= 0; vif.in3_imag <= 0;
      vif.in4_r <= 0; vif.in4_imag <= 0;
      vif.in5_r <= 0; vif.in5_imag <= 0;
      vif.in6_r <= 0; vif.in6_imag <= 0;
      vif.in7_r <= 0; vif.in7_imag <= 0;

      // Apply reset
      apply_reset();

      // Forever loop until generator finishes
      forever begin
        // Get next transaction
        gen2drv.get(tr);
        $display("[DRIVER] Driving transaction %0d", tr.id);
        // Apply inputs 
        vif.in0_r    <= tr.in_r[0];  vif.in0_imag <= tr.in_i[0];
        vif.in1_r    <= tr.in_r[1];  vif.in1_imag <= tr.in_i[1];
        vif.in2_r    <= tr.in_r[2];  vif.in2_imag <= tr.in_i[2];
        vif.in3_r    <= tr.in_r[3];  vif.in3_imag <= tr.in_i[3];
        vif.in4_r    <= tr.in_r[4];  vif.in4_imag <= tr.in_i[4];
        vif.in5_r    <= tr.in_r[5];  vif.in5_imag <= tr.in_i[5];
        vif.in6_r    <= tr.in_r[6];  vif.in6_imag <= tr.in_i[6];
        vif.in7_r    <= tr.in_r[7];  vif.in7_imag <= tr.in_i[7];
    @(negedge vif.clk);
      end
    endtask

  endclass
endpackage