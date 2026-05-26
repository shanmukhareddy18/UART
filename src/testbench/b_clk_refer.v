`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2026 10:46:12 AM
// Design Name: 
// Module Name: b_clk_gen_refer
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

module baudclk_gen_refer#(parameter freq=100,b_rate=2)(clk,rst,b_clk);
  input clk,rst;
  output reg b_clk=0;
localparam b_cnt = freq/(b_rate*16*2); 
localparam CW = $clog2(b_cnt);
reg [CW-1:0] cnt=0;
  always@(posedge clk)
      begin
        if(cnt==b_cnt-1)
          begin
            b_clk<=~b_clk;
            cnt<=0;
           end
          else cnt<=cnt+1;
      end
endmodule
