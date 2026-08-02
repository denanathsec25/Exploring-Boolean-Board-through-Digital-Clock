`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2026 12:48:19
// Design Name: 
// Module Name: alarm
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


module alarm(
    output reg [3:0]alarm_min_ones,alarm_min_tens,alarm_hr_ones,alarm_hr_tens,
    output reg alarm_out,
    output left_audio_out,right_audio_out,
    input clk,rst,
    input [1:0]state,
    input set,
    input [1:0]decision,
    input one_second_enable,alarm_activation,
    input [3:0]min_ones,min_tens,hr_ones,hr_tens
    );
    
localparam s0 = 2'b00,
           s1 = 2'b01,
           s2 = 2'b10;

always @(posedge clk or posedge rst)
begin

    if(rst && decision == 2'b11)
    begin
        alarm_min_ones<=0;
        alarm_min_tens<=0;
        alarm_hr_ones<=0;
        alarm_hr_tens<=0;
     end
     
    else if(one_second_enable)
    
     begin
        if(decision == 2'b11)
        begin
        if(state == s1 && set == 1)
        begin
            alarm_min_ones <= alarm_min_ones + 1;
        end
        if(state == s2 && set == 1)
        begin
            alarm_hr_ones <= alarm_hr_ones + 1;
        end
        end
         
        if( alarm_min_ones == 9) 
        begin
            alarm_min_ones <= 0;
            alarm_min_tens <= alarm_min_tens + 1; 
         end
        
         if(alarm_min_tens == 5 && alarm_min_ones == 9 )
         begin
            alarm_min_tens <= 0;
            alarm_min_ones <= 0;
        end
        
        if(alarm_hr_ones == 9)
        begin
            alarm_hr_ones <= 0;
            alarm_hr_tens <= alarm_hr_tens+1;
        end
        
        if(alarm_hr_tens == 2 && alarm_hr_ones == 3)
        begin
            alarm_hr_tens <= 0;
            alarm_hr_ones <= 0;
        end
        
    
     alarm_out <= (alarm_activation && (alarm_min_ones == min_ones) && (alarm_min_tens == min_tens)) && (alarm_hr_ones == hr_ones) && (alarm_hr_tens == hr_tens) ? 1: 0;
    end
 end
 audio audio_module(clk,rst,alarm_out,left_audio_out,right_audio_out);
endmodule
