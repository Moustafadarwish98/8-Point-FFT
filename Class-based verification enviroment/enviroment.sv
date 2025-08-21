package enviroment_pkg;
  import transaction_pkg::*;
  import driver_pkg::*;
  import generator_pkg::*;
  import monitor_pkg::*;
  import scoreboard_pkg::*;
    import coverage_pkg::*;

  class fft_env;
    // Virtual interface handle
    virtual fft_if vif;
    // Components
    fft_generator  gen;
    fft_driver     drv;
    fft_monitor    mon;
    fft_scoreboard scb;
     fft_coverage   cov; 
    // Mailboxes
    mailbox #(fft_transaction) gen2drv;
    mailbox #(fft_transaction) gen2scb;
    mailbox #(fft_transaction) mon2scb;
    // Constructor
    function new(virtual fft_if vif);
      this.vif = vif;
      // Mailbox construction
      gen2drv = new();
      gen2scb = new();
      mon2scb = new();
        cov = new();               
      // Component construction
      gen = new(gen2drv, gen2scb);
      drv = new(vif.DRV, gen2drv);
      mon = new(vif.MON, mon2scb,fft_transaction::PIPELINE_LATENCY);
      scb = new(gen2scb, mon2scb);
      scb.set_cov(cov);          
    endfunction
    // Run everything in parallel
    task run();
      fork
        gen.run();
        drv.run();
        mon.run();
        scb.run();
      join_none
    endtask

  endclass
endpackage
