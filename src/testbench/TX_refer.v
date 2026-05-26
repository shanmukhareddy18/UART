`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 05/19/2026 02:24:48 PM
// Design Name:
// Module Name: UART_refer
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


module UART_refer_TX #(parameter data_w=5)(b_clk,sys_rst,xmitH,xmit_dataH,uart_xmit_dataH,xmit_doneH,xmit_active);
   input b_clk,sys_rst,xmitH;
   input [data_w-1:0] xmit_dataH;
   output reg uart_xmit_dataH,xmit_doneH,xmit_active;
   reg [3:0] i;
   always@(posedge b_clk or !sys_rst)
      begin
            if(!sys_rst)
              begin
                uart_xmit_dataH<=1;
                xmit_active<=0;
                xmit_doneH<=1;
              end
       end
   always@(posedge b_clk or !sys_rst)
   begin
            if(!sys_rst)
              begin
                uart_xmit_dataH<=1;
                xmit_active<=0;
                xmit_doneH<=1;
              end
            else
             begin
               if(xmitH)
                begin
                    uart_xmit_dataH=0;
                    xmit_doneH=0;
                    xmit_active=1;
                    repeat(16) @(posedge b_clk);
                    for(i=0;i<data_w;i=i+1)
                        begin
                            uart_xmit_dataH=xmit_dataH[i];
                            repeat(16) @(posedge b_clk);
                        end
                    uart_xmit_dataH=1;
                    repeat(16) @(posedge b_clk);
                    xmit_doneH=1;
                    xmit_active=0;
                end
             end

    end
endmodule
