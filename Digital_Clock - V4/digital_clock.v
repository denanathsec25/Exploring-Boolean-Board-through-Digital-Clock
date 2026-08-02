`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 05:20:02
// Design Name: 
// Module Name: Digital_clock
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


module Digital_clock(
        input clk,
        input [1:0]decision, //decision decides whether date or time should display
        input rst,set,choose, //whether sec or hours or minutes should display
        output [7:0]seg,seg1,AN,
        output s1_out,s2_out,
        output left_audio_out,right_audio_out,
        //Stopwatch
        input play,
        //alarm
        input alarm_activation,
        output alarm_out
    );
    
    /*decision to display time is 00 and to display date is 01 and to display stopwatch is 10
    and to display alarm is 11*/
    
reg [3:0]sec_ones,sec_tens,min_ones,min_tens,hr_ones,hr_tens,day,date_ones,date_tens;
localparam clk_freq = 100000000;

reg [31:0] clock_count;
reg one_second_enable;

reg [1:0]state,next_state;
localparam s0 = 2'b00,
           s1 = 2'b01,//min, day
           s2 = 2'b10;//hr, date
//Stopwatch
wire [3:0]t_ms_ones,t_ms_tens,t_ms_hun,t_sec_ones,t_sec_tens,t_min_ones,t_min_tens,t_hr_ones,t_hr_tens;    
//Alarm
wire [3:0]alarm_min_ones,alarm_min_tens,alarm_hr_ones,alarm_hr_tens;

always @(posedge clk or posedge rst)
begin
    if(rst)
        state <= s0;
    else
        state <= next_state;
end

always @(*)
begin
        case(state)
            s0: next_state = (choose) ? s1 : s0;
            s1: next_state = (choose) ? s2 : s1;
            s2: next_state = (choose) ? s0 : s2;
            default: next_state = s0;
        endcase
end

assign s1_out = (state == s1) ? 1:0;
assign s2_out = (state == s2) ? 1:0;

assign seg1 = seg;

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
    if(rst && decision == 2'b00)
    begin
        sec_ones<=0;
        sec_tens<=0;
        min_ones<=0;
        min_tens<=0;
        hr_ones<=0;
        hr_tens<=0;
    end
    
    if(rst && decision == 2'b01)
    begin
        day <= 1;
        date_ones <= 1;
        date_tens <= 0;
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
            date_ones <= date_ones + 1;
        end
        
        if(min_tens == 5 && min_ones == 9 && sec_tens == 5 && sec_ones == 9 && hr_tens == 2 && hr_ones == 3 && day == 7)
        begin
            day <= 1;
        end 
        
         if(min_tens == 5 && min_ones == 9 && sec_tens == 5 && sec_ones == 9 && hr_tens == 2 && hr_ones == 3 && date_ones == 1 && date_tens == 3)
        begin
            date_ones <= 1;
            date_tens <= 0;
        end
        
        else if(min_tens == 5 && min_ones == 9 && sec_tens == 5 && sec_ones == 9 && hr_tens == 2 && hr_ones == 3 && date_ones == 9)
        begin
        
            date_ones <= 0;
            date_tens <= date_tens + 1;
        end
         
        if(state == s1 && set == 1 && decision == 2'b00)
        begin
            min_ones <= min_ones + 1;
            
            if(min_tens == 5 && min_ones == 9)
            begin
                min_tens <= 0;
                min_ones <= 0;
                
            end
            
            else if( min_ones == 9)
        begin
            min_ones <= 0;
            min_tens <= min_tens + 1;
        end
            
        end
        if(state == s2 &&  set == 1 && decision == 2'b00)
        begin
            hr_ones <= hr_ones + 1;
            
            if(hr_tens == 2 && hr_ones == 3)
            begin
                hr_tens <= 0;
                hr_ones <= 0;
            end
            
            else if(hr_ones == 9 )
            begin
                hr_ones <= 0;
                hr_tens <= hr_tens + 1;
            end
            
       end
       
        if(state == s1 && set == 1 && decision == 2'b01)
        begin
        if(day == 7)
            day <= 1;
            else
                day <= day + 1;
        end
        
       if(state == s2 && set == 1 && decision == 2'b01)
        begin
            date_ones <= date_ones + 1;
            
            if(date_tens == 3 && date_ones == 1)
            begin
                date_tens <= 0;
                date_ones <= 1;
                
            end
            
            else if( date_ones == 9)
        begin
            date_ones <= 0;
            date_tens <= date_tens + 1;
        end 
       end
    end
end
   
  // Stopwatch  
  stopwatch stopwatch_module(play,clk,rst,decision,t_ms_ones,t_ms_tens,t_ms_hun,t_sec_ones,t_sec_tens,t_min_ones,t_min_tens,t_hr_ones,t_hr_tens); 

 //Alarm
 alarm alarm_module(alarm_min_ones,alarm_min_tens,alarm_hr_ones,alarm_hr_tens,alarm_out,left_audio_out,right_audio_out,clk,rst,state,set,decision,one_second_enable,alarm_activation,min_ones,min_tens,hr_ones,hr_tens);

 
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
        .date_ones(date_ones),
        .date_tens(date_tens),
        
        //Stopwatch
        .t_ms_tens(t_ms_tens),
        .t_ms_hun(t_ms_hun),
        .t_sec_ones(t_sec_ones),
        .t_sec_tens(t_sec_tens),
        .t_min_ones(t_min_ones),
        .t_min_tens(t_min_tens),
        .t_hr_ones(t_hr_ones),
        .t_hr_tens(t_hr_tens),
        
        //Alarm
        .alarm_min_ones(alarm_min_ones),
        .alarm_min_tens(alarm_min_tens),
        .alarm_hr_ones(alarm_hr_ones),
        .alarm_hr_tens(alarm_hr_tens),
        
        .decision(decision),

        .AN(AN),
        .seg(seg)
        );

endmodule
