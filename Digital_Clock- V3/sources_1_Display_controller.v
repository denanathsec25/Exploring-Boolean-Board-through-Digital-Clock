`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 14:42:20
// Design Name: 
// Module Name: Display_controller
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


module Display_controller(
    input clk,rst,
    input [1:0]decision, //decision decides whether date or time should display
    input [3:0]sec_ones,sec_tens,min_ones,min_tens,hr_ones,hr_tens,day,date_ones,date_tens,
    input [3:0]t_ms_tens,t_ms_hun,t_sec_ones,t_sec_tens,t_min_ones,t_min_tens,t_hr_ones,t_hr_tens,//Stopwatch
    input [3:0]alarm_min_ones,alarm_min_tens,alarm_hr_ones,alarm_hr_tens,//Alarm
    output reg [7:0]AN, //activation of display
    output wire [7:0]seg
     );
     
    wire [2:0]display_selection;
    reg [15:0]clk_div;
    reg [3:0]display_bcd;
    reg dp;
    
    always @(posedge clk or posedge rst)
    begin
        if(rst)
            clk_div <= 16'd0;
            
        else
            clk_div <= clk_div + 1'b1;
    end
    
    assign display_selection = clk_div[15:13];
 
    always @(*)
    begin
        if(decision == 2'b00)
        begin
        case (display_selection)
        3'd0:
        begin
            display_bcd = sec_ones;
            dp = 1'b0;
            AN = 8'b11111110;
        end
        3'd1:
        begin
            display_bcd = sec_tens;
            dp = 1'b0;
            AN = 8'b11111101;
        end
        3'd2:
        begin
            display_bcd = min_ones;
            dp = 1'b1;
            AN = 8'b11111011;
        end
        
        3'd3:
        begin
            display_bcd = min_tens;
            dp = 1'b0;
            AN = 8'b11110111;
        end
        3'd4:
        begin
            display_bcd = hr_ones;
            dp = 1'b1;
            AN = 8'b11101111;
        end
        3'd5:
        begin
            display_bcd = hr_tens;
            dp = 1'b0;
            AN = 8'b11011111;
        end
        default : begin
        AN = 8'b11111111;
        dp = 1'b0;
        end
        endcase
        end
        
        if(decision == 2'b01)
        begin
        case (display_selection)
        
        3'd0:
        begin
            display_bcd =  date_ones;
            dp = 1'b0;
            AN = 8'b11111110;
         end
         3'd1:
         begin
            display_bcd = date_tens;
            dp = 1'b0;
            AN = 8'b11111101;
        end
        3'd2:
        begin
            display_bcd = day;
            dp = 1'b0;
            AN = 8'b11110111;
        end
        default : AN = 8'b11111111;
        endcase
        end
        
        //Stopwatch
        if(decision == 2'b10)
        begin
        case (display_selection)
        
        3'd0:
        begin
            display_bcd = t_ms_tens;
            dp = 1'b0;
            AN = 8'b11111110;
        end
        
        3'd1:
        begin
               display_bcd = t_ms_hun;
               dp = 1'b0;
               AN = 8'b11111101;
        end   
        
        3'd2:
        begin
                display_bcd = t_sec_ones;
                dp = 1'b1;
                AN = 8'b11111011;
        end 
        3'd3:
        begin
            display_bcd = t_sec_tens;
            dp = 1'b0;
            AN = 8'b11110111;
        end
        3'd4:
        begin
            display_bcd = t_min_ones;
            dp = 1'b1;
            AN = 8'b11101111;
        end
        
        3'd5:
        begin
            display_bcd = t_min_tens;
            dp = 1'b0;
            AN = 8'b11011111;
        end
        3'd6:
        begin
            display_bcd = t_hr_ones;
            dp = 1'b1;
            AN = 8'b10111111;
        end
        3'd7:
        begin
            display_bcd = t_hr_tens;
            dp = 1'b0;
            AN = 8'b01111111;
        end
        default : begin
        AN = 8'b11111111;
        dp = 1'b0;
        end   
        endcase
        end
        if(decision == 2'b11)
        begin
            case(display_selection)
            
                3'd0:
                begin
                   display_bcd = alarm_min_ones;
                   dp = 1'b0;
                   AN = 8'b11111110; 
                end
                3'd1:
                begin
                    display_bcd = alarm_min_tens;
                    dp = 1'b0;
                    AN = 8'b11111101;
                end
                3'd2:
                begin
                    display_bcd = alarm_hr_ones;
                    dp = 1'b1;
                    AN = 8'b11111011;
                end
                3'd3:
                begin
                    display_bcd = alarm_hr_tens;
                    dp = 1'b0;
                    AN = 8'b11110111;
                end
                default:
                begin
                    dp = 1'b0;
                    AN = 8'b11111111;
                end
            endcase
        end
    end
    
    
    BCD_to_7Segment decoder(
    .seg(seg),
    .bcd(display_bcd),
    .dp(dp)
    );
endmodule