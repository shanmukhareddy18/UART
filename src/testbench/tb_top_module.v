`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2026 10:00:47 AM
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_top_module;

// Parameters
parameter DATA_W = 5;
parameter freq = 100; 
parameter b_rate= 2;
// ────────────────────────────────────────────────
// Common signals
// ────────────────────────────────────────────────

reg  sys_rst;
reg sys_clk;
reg   xmitH;
reg uart_REC_dataH;
reg  [DATA_W-1:0] xmit_dataH;
wire   refer_uart_xmit_dataH;   
wire    refer_xmit_doneH;
wire   refer_xmit_active;

wire [DATA_W-1:0] refer_rec_dataH;        
wire   refer_rec_readyH;
wire   refer_rec_busy;
wire b_clk;
wire uart_clk;

wire   dut_uart_xmit_dataH;   
wire   dut_xmit_doneH;
wire   dut_xmit_active;

wire [DATA_W-1:0] dut_rec_dataH;        
wire   dut_rec_readyH;
wire   dut_rec_busy;
top_refer #(.data_w(DATA_W), .freq(freq),.b_rate(b_rate)) INST_A (
    .sys_clk(sys_clk),
    .b_clk            (b_clk),
    .sys_rst          (sys_rst),
    .xmitH            (xmitH),
    .xmit_dataH       (xmit_dataH),
    .uart_xmit_dataH  (refer_uart_xmit_dataH),
    .xmit_doneH       (refer_xmit_doneH),
    .xmit_active      (refer_xmit_active),

    .uart_REC_dataH   (uart_REC_dataH),
    .rec_readyH       (refer_rec_readyH),
    .rec_dataH        (refer_rec_dataH),
    .rec_busy         (refer_rec_busy)
);

 uart
	#(.XTAL_CLK(freq),
		.BAUD(b_rate),
		.WORD_LEN(DATA_W)) INST_B(
    .sys_clk(sys_clk),
    .sys_rst_l         (sys_rst),
    .xmitH            (xmitH),
    .xmit_dataH       (xmit_dataH),               
    .uart_XMIT_dataH  (dut_uart_xmit_dataH),
    .xmit_doneH       (dut_xmit_doneH),
    .xmit_active      (dut_xmit_active),

    .uart_REC_dataH   (uart_REC_dataH),
    .rec_readyH       (dut_rec_readyH),
    .rec_dataH        (dut_rec_dataH),
    .rec_busy         (dut_rec_busy),
    .uart_clk(uart_clk)
	);
always #5 sys_clk=~sys_clk;
reg [DATA_W-1:0]temp;
task send_data;
  input [DATA_W-1:0]data;
  integer j;
   begin
     uart_REC_dataH=0; //start
     repeat(16)@(posedge b_clk);
     for(j=0;j<DATA_W;j=j+1)
       begin 
          uart_REC_dataH=data[j];
          repeat(16)@(posedge b_clk);
       end
      uart_REC_dataH=1; //stop
      repeat(16)@(posedge b_clk);
     end
endtask
task send_inv_start;
  input [DATA_W-1:0]dat;
  integer b;
   begin
     uart_REC_dataH=0; //start
     repeat(4)@(posedge b_clk);
     uart_REC_dataH=1;
     repeat(13)@(posedge b_clk);
     for(b=0;b<DATA_W;b=b+1)
       begin
          uart_REC_dataH=dat[b];
          repeat(16)@(posedge b_clk);
       end
      uart_REC_dataH=1; //stop
      repeat(16)@(posedge b_clk);
     end
endtask
task send_inv_stop;
  input [DATA_W-1:0]da;
  integer a;
   begin
     uart_REC_dataH=0; //start
     repeat(16)@(posedge b_clk);
     for(a=0;a<DATA_W;a=a+1)
       begin
          uart_REC_dataH=da[a];
          repeat(16)@(posedge b_clk);
       end
      uart_REC_dataH=0; //stop
      repeat(18)@(posedge b_clk);
      uart_REC_dataH=1;
     end
endtask

task rx_reset_btn;
  begin
   uart_REC_dataH=0;
   repeat(16)@(posedge b_clk);
   uart_REC_dataH=1;
  repeat(16)@(posedge b_clk);
  sys_rst=0;
  repeat(16)@(posedge b_clk);
  sys_rst=1;
 end
endtask

task trans;
 integer i;
 begin
   temp=0;
   repeat(8)@(posedge b_clk);
   for(i=0;i<DATA_W;i=i+1)
       begin 
          repeat(16)@(posedge b_clk);
           temp[i]=dut_uart_xmit_dataH;
       end
    repeat(24) @(posedge b_clk);
  end 
endtask
task compare;
  begin
     if(temp===xmit_dataH  &&  refer_xmit_doneH=== dut_xmit_doneH && refer_xmit_active===dut_xmit_active
        && refer_rec_dataH===dut_rec_dataH && refer_rec_readyH===dut_rec_readyH  && refer_rec_busy===dut_rec_busy)  
        $display("PASS");
     else
       $display("FAIL. %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",temp ,xmit_dataH,  refer_xmit_doneH, dut_xmit_doneH ,refer_xmit_active,dut_xmit_active,
         refer_rec_dataH,dut_rec_dataH, refer_rec_readyH,dut_rec_readyH , refer_rec_busy , dut_rec_busy);
  end
endtask
task tx_reset_btn;
 begin
  xmitH=1;
  @(posedge b_clk);
  xmitH=0;
  repeat(16)@(posedge b_clk);
  sys_rst=0;
  repeat(16)@(posedge b_clk);
  sys_rst=1;
 end
endtask
task tx_reset_btn2;
 begin
  xmitH=1;
  @(posedge b_clk);
  xmitH=0;
  repeat(5)@(posedge b_clk);
  sys_rst=0;
  repeat(5)@(posedge b_clk);
  sys_rst=1;
 end
endtask

initial begin
   sys_rst=0;
   sys_clk=1;
   repeat(5)@(posedge b_clk);
   compare;
   sys_rst=1;
   @(posedge b_clk);
   xmitH=1;
   xmit_dataH =8'b11001010;
   @(posedge b_clk);
   xmitH=0;
   trans;
   compare;

   xmitH=1;
   xmit_dataH =0;
   @(posedge b_clk);
   xmitH=0;
   trans;
   compare;

   xmitH=1;
   xmit_dataH =8'b11111111;
   @(posedge b_clk);
   xmitH=0;
   trans;
   compare;

   repeat(16)@(posedge b_clk);
send_data(8'b10111010);
   compare;
   send_data(8'b01001010);
   compare;
   send_data(8'b00110101);
   compare;
   send_data(8'b11111111);
   compare;
   send_data(8'b10100000);
   compare;
   send_inv_stop(8'b00101100);
   compare;
   send_inv_start(8'b00101100);
   compare;
   rx_reset_btn;
   compare;
   tx_reset_btn;
   compare;
   tx_reset_btn2;
   compare;
  #100; $finish;
 end

  endmodule

       
       
       
       
       
