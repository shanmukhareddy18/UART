`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 05/19/2026 03:25:52 PM
// Design Name:
// Module Name: UART_RX_refer
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

module UART_RX_refer #(parameter data_w=5)(b_clk,sys_rst,uart_REC_dataH,rec_readyH,rec_dataH,rec_busy);
   input b_clk, sys_rst, uart_REC_dataH;
   output reg [data_w-1:0] rec_dataH;
   output reg rec_readyH, rec_busy;
   integer i;
   reg [data_w-1:0] temp_data;
  always@(posedge b_clk or !sys_rst)
   begin
      if(!sys_rst) begin
         rec_readyH = 1;
         rec_busy   = 0;
         rec_dataH  = 0;
         temp_data  = 0;
      end
    end
   always@(posedge b_clk or !sys_rst)
   begin
      if(!sys_rst) begin
         rec_readyH = 1;
         rec_busy   = 0;
         rec_dataH  = 0;
         temp_data  = 0;
      end
      else begin
         if(uart_REC_dataH == 0) begin
            rec_readyH = 0;
            rec_busy   = 1;


            repeat(8) @(posedge b_clk);
            if(uart_REC_dataH == 1) begin
               rec_readyH = 1;
               rec_busy   = 0;
            end
            else begin
               repeat(8) @(posedge b_clk);

               for(i = 0; i < data_w; i = i+1) begin
                  repeat(7) @(posedge b_clk);
                  temp_data[i] = uart_REC_dataH;
                  repeat(9) @(posedge b_clk);
               end

               if(uart_REC_dataH == 1) begin
                  repeat(7) @(posedge b_clk);
                  rec_readyH = 1;
                  rec_busy   = 0;
                  rec_dataH  = temp_data;
                  temp_data  = 0;
               end
               else begin
                  rec_readyH = 1;
                  rec_busy   = 0;
                  rec_dataH  = 0;
                  temp_data  = 0;
               end
            end
         end
      end
   end
endmodule

