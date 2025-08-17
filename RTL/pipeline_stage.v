`timescale 1ns / 1ps

module pipeline_stage #
  (
    parameter WIDTH = 12,
    WI_INT   = 6,
    WI_FRAC  = WIDTH - WI_INT,
    WO_INT   = 8,
    WO_FRAC  = WIDTH - WO_INT,
    OP_WIDTH = WO_FRAC + WO_INT,
    TW_FRAC = 10,
    TW_IN = 2,
    IP_WIDTH = WI_FRAC + WI_INT

  )
  (
    input  wire                 clk,
    input  wire                 rst,
    input  wire     [IP_WIDTH-1:0]     in0_r,
    input  wire     [IP_WIDTH-1:0]     in0_i,
    input  wire     [IP_WIDTH-1:0]     in1_r,
    input  wire     [IP_WIDTH-1:0]     in1_i,
    input  wire     [IP_WIDTH-1:0]     in2_r,
    input  wire     [IP_WIDTH-1:0]     in2_i,
    input  wire     [IP_WIDTH-1:0]     in3_r,
    input  wire     [IP_WIDTH-1:0]     in3_i,
    input  wire     [IP_WIDTH-1:0]     in4_r,
    input  wire     [IP_WIDTH-1:0]     in4_i,
    input  wire     [IP_WIDTH-1:0]     in5_r,
    input  wire     [IP_WIDTH-1:0]     in5_i,
    input  wire     [IP_WIDTH-1:0]     in6_r,
    input  wire     [IP_WIDTH-1:0]     in6_i,
    input  wire     [IP_WIDTH-1:0]     in7_r,
    input  wire     [IP_WIDTH-1:0]     in7_i,

    output reg  [OP_WIDTH-1:0]     out0_r,
    output reg  [OP_WIDTH-1:0]     out0_i,

    output reg  [OP_WIDTH-1:0]     out1_r,
    output reg  [OP_WIDTH-1:0]     out1_i,
    output reg  [OP_WIDTH-1:0]     out2_r,
    output reg  [OP_WIDTH-1:0]     out2_i,
    output reg  [OP_WIDTH-1:0]     out3_r,
    output reg  [OP_WIDTH-1:0]     out3_i,
    output reg  [OP_WIDTH-1:0]     out4_r,
    output reg  [OP_WIDTH-1:0]     out4_i,
    output reg  [OP_WIDTH-1:0]     out5_r,
    output reg  [OP_WIDTH-1:0]     out5_i,
    output reg  [OP_WIDTH-1:0]     out6_r,
    output reg  [OP_WIDTH-1:0]     out6_i,
    output reg  [OP_WIDTH-1:0]     out7_r,
    output reg  [OP_WIDTH-1:0]     out7_i

  );
  /*
    parameter STAGE_1_OUT_INT = 7 ;
    parameter STAGE_1_OUT_FRAC = WIDTH - STAGE_1_OUT_INT;
    parameter STAGE_2_OUT_INT = 7;
    parameter STAGE_2_OUT_FRAC = WIDTH - STAGE_2_OUT_INT;
    parameter STAGE_3_OUT_INT = 8;
    parameter STAGE_3_OUT_FRAC = WIDTH - STAGE_3_OUT_INT;
  */
  always @ (posedge clk or negedge rst)
  begin
    if(!rst)
    begin
      out0_r  <= 0;
      out0_i  <= 0;
      out1_r  <= 0;
      out1_i  <= 0;
      out2_r  <= 0;
      out2_i  <= 0;
      out3_r  <= 0;
      out3_i  <= 0;
      out4_r  <= 0;
      out4_i  <= 0;
      out5_r  <= 0;
      out5_i  <= 0;
      out6_r  <= 0;
      out6_i  <= 0;
      out7_r  <= 0;
      out7_i  <= 0;
    end
    else
    begin
      out0_r  <= in0_r;
      out0_i  <= in0_i;
      out1_r  <= in1_r;
      out1_i  <= in1_i;
      out2_r  <= in2_r;
      out2_i  <= in2_i;
      out3_r  <= in3_r;
      out3_i  <= in3_i;
      out4_r  <= in4_r;
      out4_i  <= in4_i;
      out5_r  <= in5_r;
      out5_i  <= in5_i;
      out6_r  <= in6_r;
      out6_i  <= in6_i;
      out7_r  <= in7_r;
      out7_i  <= in7_i;

    end
  end //always

endmodule

    /*
        #20;
        // Apply test vector (Q7.5 format)
        in0_tb_r = $rtoi(0.0 * (1 << WI_FRAC));
        in0_tb_i = 0;
        in1_tb_r = 1 << WI_FRAC;
        in1_tb_i = 0;
        in2_tb_r = 2 << WI_FRAC;
        in2_tb_i = 0;
        in3_tb_r = 3 << WI_FRAC;
        in3_tb_i = 0;
        in4_tb_r = 4 << WI_FRAC;
        in4_tb_i = 0;
        in5_tb_r = 5 << WI_FRAC;
        in5_tb_i = 0;
        in6_tb_r = 6 << WI_FRAC;
        in6_tb_i = 0;
        in7_tb_r = 7 << WI_FRAC;
        in7_tb_i = 0;
        #40;
        display_twiddle_factors();
        display_test_inputs();
        display_stages_outputs();
     
        #20;
     
        /* From Matlab
            
        ================ Test Input 964 ================
        Input x(n):
          Columns 1 through 5
           1.4688 + 5.4688i -19.9062 - 1.9531i   7.6719 - 7.3750i  -5.3125 + 9.7812i  -1.5312 -21.4531i
          Columns 6 through 8
          11.4375 -16.5000i  -6.1250 + 6.0000i  -2.6875 -19.5156i
         
                  DataTypeMode: Fixed-point: binary point scaling
                    Signedness: Signed
                    WordLength: 12
                FractionLength: 6
        Bit-reversed order:
          Columns 1 through 5
           1.4688 + 5.4688i  -1.5312 -21.4531i   7.6719 - 7.3750i  -6.1250 + 6.0000i -19.9062 - 1.9531i
          Columns 6 through 8
          11.4375 -16.5000i  -5.3125 + 9.7812i  -2.6875 -19.5156i
         
                  DataTypeMode: Fixed-point: binary point scaling
                    Signedness: Signed
                    WordLength: 12
                FractionLength: 6
        After Stage 1:
          Columns 1 through 5
          -0.0625 -15.9688i   3.0000 +26.9375i   1.5625 - 1.3750i  13.8125 -13.3750i  -8.4688 -18.4375i
          Columns 6 through 8
         -31.3438 +14.5625i  -8.0000 - 9.7188i  -2.6250 +29.3125i
         
                  DataTypeMode: Fixed-point: binary point scaling
                    Signedness: Signed
                    WordLength: 12
                FractionLength: 5
        After Stage 2:
          Columns 1 through 5
           1.5000 -17.3438i -10.3750 +13.1250i  -1.6250 -14.5938i  16.3750 +40.7500i -16.4688 -28.1562i
          Columns 6 through 8
          -2.0312 +17.1875i  -0.4688 - 8.7188i -60.6562 +11.9375i
         
                  DataTypeMode: Fixed-point: binary point scaling
                    Signedness: Signed
                    WordLength: 12
                FractionLength: 5
        Final FFT Output (Stage 3):
          Columns 1 through 5
         -14.9375 -45.5000i   0.3125 +26.6875i -10.3125 -14.1250i  67.6875 +75.1875i  17.9375 +10.8125i
          Columns 6 through 8
         -21.0625 - 0.4375i   7.1250 -15.0625i -34.9375 + 6.3125i
         
                  DataTypeMode: Fixed-point: binary point scaling
                    Signedness: Signed
                    WordLength: 12
                FractionLength: 4
        MATLAB fft(x) Output:
          Columns 1 through 5
         
         -14.9844 -45.5469i   0.3200 +26.7147i -10.3281 -14.1406i  67.6844 +75.1681i  17.9531 +10.8281i
         
          Columns 6 through 8
         
         -21.0700 - 0.4647i   7.1094 -15.0781i -34.9344 + 6.2694i
        in0_tb_r = $rtoi(1.4688 * (1 << WI_FRAC));
        in0_tb_i = $rtoi(5.4688 * (1 << WI_FRAC));
        in1_tb_r = $rtoi(-19.9062 * (1 << WI_FRAC));
        in1_tb_i = $rtoi(- 1.9531 * (1 << WI_FRAC));
        in2_tb_r = $rtoi(7.6719 * (1 << WI_FRAC));
        in2_tb_i = $rtoi(- 7.3750* (1 << WI_FRAC));
        in3_tb_r = $rtoi(-5.3125 * (1 << WI_FRAC));
        in3_tb_i = $rtoi(9.7812 * (1 << WI_FRAC));
        in4_tb_r = $rtoi(-1.5312 * (1 << WI_FRAC));
        in4_tb_i = $rtoi(-21.4531 * (1 << WI_FRAC));
        in5_tb_r = $rtoi(11.4375 * (1 << WI_FRAC));
        in5_tb_i = $rtoi(-16.5000 * (1 << WI_FRAC));
        in6_tb_r = $rtoi(-6.1250 * (1 << WI_FRAC));
        in6_tb_i = $rtoi(6.0000* (1 << WI_FRAC));
        in7_tb_r = $rtoi(-2.6875 * (1 << WI_FRAC));
        in7_tb_i = $rtoi(-19.5156 * (1 << WI_FRAC));
        #40;
        display_twiddle_factors();
        display_test_inputs();
        display_stages_outputs();
    */
    //#40;