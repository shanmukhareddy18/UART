`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2026 09:50:29 PM
// Design Name: 
// Module Name: RX
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

module RX #(parameter data_w=6)(b_clk,sys_rst,uart_REC_dataH,rec_readyH,rec_dataH,rec_busy,temp_data);
   input b_clk,sys_rst,uart_REC_dataH;
   output reg [data_w-1:0] rec_dataH;
   output reg rec_readyH,rec_busy;
   output reg [data_w-1:0] temp_data;
  reg [4:0]cnt_cycles; 
   reg [3:0]cnt_bits; 
   reg ff1,ff2;
   parameter idle =2'd0, start=2'd1, data=2'd2, stop=2'd3;
   reg [1:0]pst,nst;
   reg d1,d2;
   always@(posedge b_clk or sys_rst)
   begin
     if(sys_rst) begin
       ff1<=1;
       ff2<=1;  end
     else  begin
       ff1<=uart_REC_dataH;
       ff2<=ff1;  end
   end
      
   always@(posedge b_clk or sys_rst)
   begin
     if(sys_rst)
          begin
             rec_readyH<=1;
             rec_busy<=0;
             rec_dataH<=0; 
             cnt_cycles<=0;
             pst<=idle;
             temp_data<=0;
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
              rec_readyH=1;
              rec_busy=0;
              temp_data=0;
              if(rec_readyH==1 && rec_busy==0 && ff2==0) begin
                   nst=start;
                   rec_readyH=0;
                 rec_busy=1;
                     end
              else 
                nst=idle;
            end
          start:
             begin
               cnt_bits=0;
               if(cnt_cycles==5 && ff2==1 )
                  nst=idle;
               else if( cnt_cycles==5 && ff2==0)
                 d1=1;
               else if( cnt_cycles==15 && d1==1) begin
                   nst=data;
                   d1=0; end
                else
                  nst=start;
              end
          data:
                 if(cnt_bits==data_w && cnt_cycles==15)
                    nst=stop;
                 else
                   begin
                      nst=data;
                      if(cnt_cycles==5) begin
                         temp_data[cnt_bits]=ff2;
                         cnt_bits=cnt_bits+1;  end
                   end        
          stop:
               begin
                 if(cnt_cycles==5 && ff2==1) begin
                    nst=idle;
                    rec_dataH<=temp_data;
                  end
                
                  else begin
                     nst=stop;
                       end
                end
           default:nst=idle;
         endcase
       end
 always@(posedge b_clk)
 if(rec_busy)
   begin
     if(cnt_cycles==15)
         cnt_cycles<=0;
      else
         cnt_cycles<=cnt_cycles+1;
   end
endmodule
