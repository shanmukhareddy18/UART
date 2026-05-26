`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2026 06:22:38 PM
// Design Name: 
// Module Name: top_module
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
module uart_top #(
    parameter DATA_W = 5,    
    parameter FREQ   = 100,  
    parameter B_RATE = 2     
)(
    input  wire              sys_clk,           
    input  wire              sys_rst,         
    input  wire              xmitH,         
    input  wire [DATA_W-1:0] xmit_dataH,  
    output wire              xmit_doneH,    
    output wire              xmit_active,   
    output wire [DATA_W-1:0] rec_dataH,  
    output wire [DATA_W-1:0] temp_data,  
    output wire              rec_readyH,    
    output wire              rec_busy,     
    output wire              uart_tx_line,  
    input  wire              uart_rx_line,
    output wire              b_clk  
);

 baudclk_gen #(.freq(FREQ),.b_rate(B_RATE)) u_baud (.clk(sys_clk),.rst(sys_rst),.b_clk(b_clk)
 );
 TX #( .data_w (DATA_W)) u_tx (
     .b_clk           (b_clk),
     .sys_rst         (sys_rst),
     .xmitH           (xmitH),
     .xmit_dataH      (xmit_dataH),
     .uart_xmit_dataH (uart_tx_line),
     .xmit_doneH      (xmit_doneH),
     .xmit_active     (xmit_active)
 );

RX #(.data_w (DATA_W)) u_rx (
    .b_clk           (b_clk),
    .sys_rst         (sys_rst),
    .uart_REC_dataH  (uart_rx_line),
    .rec_readyH      (rec_readyH),
    .rec_dataH       (rec_dataH),
    .rec_busy        (rec_busy),
    .temp_data(temp_data)
);

endmodule
