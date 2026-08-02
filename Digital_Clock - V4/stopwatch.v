`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2026 12:48:39
// Design Name: 
// Module Name: stopwatch
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


module stopwatch(
input play,
input clk,rst,
input [1:0]decision,
output reg [3:0]t_ms_ones,t_ms_tens,t_ms_hun,t_sec_ones,t_sec_tens,t_min_ones,t_min_tens,t_hr_ones,t_hr_tens
    );
reg [16:0] count;
reg ms;
always @(posedge clk or posedge rst) begin
   if(rst && decision == 2'b10)
     begin
         count <= 0;
         ms <= 0;
     end
     else if(decision == 2'b10) begin
       if (count == 100000-1) begin   // 1 ms
            count <= 0;
            ms <= 1;
        end
       else begin
            count <= count + 1;
            ms <= 0;
       end 
     end
    else
    begin
         count <= 0;
         ms <= 0;
     end
 end
 
 always @(posedge clk or posedge rst)
 begin
    if(rst)
    begin
        t_ms_ones <= 0;
        t_ms_tens <= 0;
        t_ms_hun <= 0;
        t_sec_ones <= 0;
        t_sec_tens <= 0;
        t_min_ones <= 0;
        t_min_tens <= 0;
        t_hr_tens <= 0;
        t_hr_ones <= 0;
    end
    
    else if(ms && play)
    begin
        t_ms_ones <= t_ms_ones + 1;
        if(t_ms_ones  == 9) 
        begin
            t_ms_tens <= t_ms_tens + 1;
            t_ms_ones <= 0;
            if(t_ms_tens == 9)
            begin
                t_ms_tens <= 0;
                t_ms_hun <= t_ms_hun + 1;
                if(t_ms_hun == 9)
                    begin
                    t_ms_hun <= 0;
                    t_sec_ones <= t_sec_ones + 1;
                    if(t_sec_ones == 9)
                    begin
                        t_sec_ones <= 0;
                        t_sec_tens <= t_sec_tens + 1;
                        if(t_sec_tens == 5)
                        begin
                            t_sec_tens <= 0;
                            t_min_ones <= t_min_ones + 1;
                            if(t_min_ones == 9)
                            begin
                                t_min_ones <= 0;
                                t_min_tens <= t_min_tens + 1;
                                if(t_min_tens == 5)
                                begin
                                    t_min_tens <= 0;
                                    t_hr_ones <= t_hr_ones + 1;
                                    if(t_hr_ones == 9)
                                    begin
                                        t_hr_ones <= 0;
                                        t_hr_tens <= t_hr_tens + 1;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
 end
 
endmodule
