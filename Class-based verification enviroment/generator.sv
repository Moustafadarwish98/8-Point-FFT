package generator_pkg;
  import transaction_pkg::*;

  class fft_generator;

    // Mailboxes
    mailbox #(fft_transaction) gen2drv;
    mailbox #(fft_transaction) gen2scb;

    // Parameters 
    localparam int VEC_LEN   = 8;
    localparam int IP_WIDTH  = 12;   // Q6.6
    localparam int OP_WIDTH  = 12;   // Q8.4
    localparam int MAX_LINES = 816;
    localparam int NUM_VECS  = MAX_LINES / VEC_LEN; 

    // Memories for file contents
    bit signed [IP_WIDTH-1:0] input_mem_r [0:MAX_LINES-1];
    bit signed [IP_WIDTH-1:0] input_mem_i [0:MAX_LINES-1];
    bit signed [OP_WIDTH-1:0] golden_mem_r[0:MAX_LINES-1];
    bit signed [OP_WIDTH-1:0] golden_mem_i[0:MAX_LINES-1];

    // constructor
    function new(mailbox #(fft_transaction) gen2drv,
                 mailbox #(fft_transaction) gen2scb);
      this.gen2drv = gen2drv;
      this.gen2scb = gen2scb;
    endfunction

    // Load memory files
    task load_mem();
      $readmemh("fft_inputs_real.mem",   input_mem_r);
      $readmemh("fft_inputs_imag.mem",   input_mem_i);
      $readmemh("fft_outputs_real.mem",  golden_mem_r);
      $readmemh("fft_outputs_imag.mem",  golden_mem_i);
      $display("[GENERATOR] Memory files loaded successfully.");
    endtask

    // Main run task
    task run();
      fft_transaction tr;
      int mem_ptr = 0;

      // Load files before running
      load_mem();

      for (int vec = 0; vec < NUM_VECS; vec++) begin
        tr = new(vec); 
        $display("[GENERATOR] Generating transaction %0d", vec);
        for (int i = 0; i < VEC_LEN; i++) begin
          tr.in_r[i]     = input_mem_r[mem_ptr + i];
          tr.in_i[i]     = input_mem_i[mem_ptr + i];
          tr.golden_r[i] = golden_mem_r[mem_ptr + i];
          tr.golden_i[i] = golden_mem_i[mem_ptr + i];
        end
        mem_ptr += VEC_LEN;
        // Send to driver and scoreboard
        gen2drv.put(tr);
        gen2scb.put(tr);
        $display("[GENERATOR] Transaction %0d sent", vec);
      end
    endtask

  endclass
endpackage
