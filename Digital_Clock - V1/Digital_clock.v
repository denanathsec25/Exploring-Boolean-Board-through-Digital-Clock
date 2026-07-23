`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2026 05:20:02
// Design Name: 
// Module Name: Digital_clk
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


module Digital_clock(seg,seg1,AN,clk,rst,min_set,hr_set,day_set);
reg [3:0]sec_ones,sec_tens,min_ones,min_tens,hr_ones,hr_tens,day;
input clk;
input rst,min_set,hr_set,day_set;
output [7:0]seg,seg1,AN;

localparam clk_freq = 100000000;

reg [31:0] clock_count;
reg one_second_enable;

assign seg = seg1;

always @(posedge clk or posedge rst)
begin
if(rst)
begin
    clock_count<=0;
    one_second_enable<=0;
 end
 
 else
 begin
    if (clock_count == clk_freq - 1)
    begin
        clock_count<= 0;
        one_second_enable<=1;
     end
     else
     begin
        clock_count <= clock_count + 1;
        one_second_enable<=0;
     end
 end
 end 
 
always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        sec_ones<=0;
        sec_tens<=0;
        min_ones<=0;
        min_tens<=0;
        hr_ones<=0;
        hr_tens<=0;
        day <= 0;
     end
     
    else if(one_second_enable)
    
     begin
        sec_ones <= sec_ones + 1;
        if(sec_ones == 9)
        begin
            sec_ones <= 0;
            sec_tens <= sec_tens +1;
        end
        if(sec_tens == 5 && sec_ones == 9)
        begin
            sec_tens <= 0;
            min_ones <= min_ones + 1;
         end
        if(sec_tens == 5 && sec_ones == 9 && min_ones == 9) 
        begin
            min_ones <= 0;
            min_tens <= min_tens + 1; 
         end
        
         if(min_tens == 5 && min_ones == 9 && sec_tens == 5 && sec_ones == 9)
         begin
            min_tens <= 0;
            hr_ones <= hr_ones + 1;
        end
        if(min_tens == 5 && min_ones == 9 && sec_tens == 5 && sec_ones == 9 && hr_ones == 9)
        begin
            hr_ones <= 0;
            hr_tens <= hr_tens+1;
        end
        if(min_tens == 5 && min_ones == 9 && sec_tens == 5 && sec_ones == 9 && hr_tens == 2 && hr_ones == 3)
        begin
            hr_tens <= 0;
            hr_ones <= 0;
            day <= day +1;
        end
        if(min_tens == 5 && min_ones == 9 && sec_tens == 5 && sec_ones == 9 && hr_tens == 2 && hr_ones == 3 && day == 6)
        begin
            day <= 0;
        end 
        if(day_set)
        begin
        if(day == 6)
            day <=0;
            else
                day <= day + 1;
        end
        if(min_set == 1)
        begin
            min_ones <= min_ones + 1;
            if(min_tens == 5 && min_ones == 9)
            begin
                hr_ones <= hr_ones + 1;
                min_tens <= 0;
                min_ones <= 0;
                
            end
            else if( min_ones == 9)
        begin
            min_ones <= 0;
            min_tens <= min_tens + 1;
        end
            
        end
        if(hr_set == 1)
        begin
            hr_ones <= hr_ones + 1;
            if(hr_tens == 2 && hr_ones == 3)
            begin
                hr_tens <= 0;
                hr_ones <= 0;
                day <= day +1;
            end
            else if(hr_ones == 9 )
            begin
                hr_ones <= 0;
                hr_tens <= hr_tens + 1;
            end
       end 
    end
end

Display_controller display_unit (
        .clk(clk),
        .rst(rst),

        .sec_ones(sec_ones),
        .sec_tens(sec_tens),
        .min_ones(min_ones),
        .min_tens(min_tens),
        .hr_ones(hr_ones),
        .hr_tens(hr_tens),
        .day(day),

        .AN(AN),
        .seg(seg)
        );

endmodule
