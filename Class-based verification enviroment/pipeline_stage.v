module pipeline_stage #(
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
    input  wire clk,
    input  wire rst,
    input  wire [IP_WIDTH-1:0] in0_r,
    input  wire [IP_WIDTH-1:0] in0_i,
    input  wire [IP_WIDTH-1:0] in1_r,
    input  wire [IP_WIDTH-1:0] in1_i,
    input  wire [IP_WIDTH-1:0] in2_r,
    input  wire [IP_WIDTH-1:0] in2_i,
    input  wire [IP_WIDTH-1:0] in3_r,
    input  wire [IP_WIDTH-1:0] in3_i,
    input  wire [IP_WIDTH-1:0] in4_r,
    input  wire [IP_WIDTH-1:0] in4_i,
    input  wire [IP_WIDTH-1:0] in5_r,
    input  wire [IP_WIDTH-1:0] in5_i,
    input  wire [IP_WIDTH-1:0] in6_r,
    input  wire [IP_WIDTH-1:0] in6_i,
    input  wire [IP_WIDTH-1:0] in7_r,
    input  wire [IP_WIDTH-1:0] in7_i,

    output reg  [OP_WIDTH-1:0] out0_r,
    output reg  [OP_WIDTH-1:0] out0_i,

    output reg  [OP_WIDTH-1:0] out1_r,
    output reg  [OP_WIDTH-1:0] out1_i,
    output reg  [OP_WIDTH-1:0] out2_r,
    output reg  [OP_WIDTH-1:0] out2_i,
    output reg  [OP_WIDTH-1:0] out3_r,
    output reg  [OP_WIDTH-1:0] out3_i,
    output reg  [OP_WIDTH-1:0] out4_r,
    output reg  [OP_WIDTH-1:0] out4_i,
    output reg  [OP_WIDTH-1:0] out5_r,
    output reg  [OP_WIDTH-1:0] out5_i,
    output reg  [OP_WIDTH-1:0] out6_r,
    output reg  [OP_WIDTH-1:0] out6_i,
    output reg  [OP_WIDTH-1:0] out7_r,
    output reg  [OP_WIDTH-1:0] out7_i
  );
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
