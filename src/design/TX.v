`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2026 02:37:16 PM
// Design Name: 
// Module Name: TX
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

module TX #(parameter data_w=5)(b_clk,sys_rst,xmitH,xmit_dataH,uart_xmit_dataH,xmit_doneH,xmit_active);
   input b_clk,sys_rst,xmitH;
   input [data_w-1:0] xmit_dataH;
   output reg uart_xmit_dataH,xmit_doneH,xmit_active;
    reg [4:0] cnt_cycles=0;

   reg [3:0]cnt_bits; 
   parameter idle =2'd0, start=2'd1, data=2'd2, stop=2'd3;
   reg [1:0]pst,nst;
   always@(posedge b_clk)
   begin
     if(sys_rst)
          begin
             uart_xmit_dataH<=1;
             cnt_bits<=0;
             xmit_active<=0; 
             xmit_doneH<=1;
             cnt_cycles<=0;
             pst<=idle;
          end
       else
         pst<=nst;
   end
   always@(*)
   begin 
     case(pst)
          idle:
            begin
             cnt_cycles=0;
              uart_xmit_dataH=1;
              xmit_doneH=1;
              xmit_active=0;
              if(xmitH==1 && xmit_active==0 )
                   nst=start;
              else 
                nst=idle;
            end
          start:
             begin
               uart_xmit_dataH=0;
               xmit_active=1;
               xmit_doneH=0;
               cnt_bits=0;
               if(cnt_cycles==15)
                  nst=data;
               else
                   nst=start;
              end
          data:
                 if(cnt_bits==data_w && cnt_cycles==15)
                    nst=stop;
                 else
                   begin
                      nst=data;
                      if(cnt_cycles==0) begin
                         uart_xmit_dataH=xmit_dataH[cnt_bits];
                         cnt_bits=cnt_bits+1;  end
                   end        
          stop:
               begin
                 uart_xmit_dataH=1;
                 if(cnt_cycles==15) begin
                    nst=idle;
                  end
                  else
                     nst=stop;
                 end
           default:nst=idle;
         endcase
       end
 always@(posedge b_clk)
 if(xmit_active)
   begin
     if(cnt_cycles==15)
         cnt_cycles<=0;
      else
         cnt_cycles<=cnt_cycles+1;
   end
endmodule
