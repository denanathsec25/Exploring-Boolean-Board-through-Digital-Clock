# Digital Clock - V4

> The final version of the **Digital Clock** project introduces **Audio Playback** for the alarm system, providing an audible alert in addition to the visual display. This version combines all the features developed throughout the project into a complete FPGA-based digital clock application.

![Version](https://img.shields.io/badge/Version-V4-blue)
![Verilog](https://img.shields.io/badge/Language-Verilog-red)
![Vivado](https://img.shields.io/badge/Tool-Xilinx%20Vivado-green)
![Status](https://img.shields.io/badge/Project-Final-success)

---

# Overview

Version 4 represents the final stage of the project. Along with the Digital Clock, Calendar, Stopwatch, and Alarm, it introduces **PWM-based Audio Playback** to generate an alarm tone through a speaker.

This version demonstrates the integration of digital logic with audio generation on an FPGA.

---

# New Features

- PWM Audio Playback
- Alarm Sound Output
- Audio Sample Memory
- Speaker Interface
- Complete Digital Clock System

---

# Project Structure

```text
Digital_Clock-V4/
│
├── Digital_clock.v
├── Alarm.v
├── Stopwatch.v
├── Audio.v
├── PWM_Generator.v
├── Display_Controller.v
├── BCD_to_7Segment.v
├── Constraints.xdc
├── Digital_Clock_tb.v
├── Working Video - V4.mp4
└── README.md
```

---

# Complete Feature Set

✅ 24-Hour Digital Clock

✅ Calendar

✅ Day Counter

✅ Stopwatch

✅ Alarm

✅ Audio Playback

✅ Seven Segment Display

✅ FSM-based Configuration

---

# Display Modes

| Decision | Mode |
|-----------|------|
| 00 | Digital Clock |
| 01 | Calendar |
| 10 | Stopwatch |
| 11 | Alarm Configuration |

---

# Audio System

The alarm now generates an audible notification using a PWM output connected to a speaker.

The audio system consists of three major blocks.

```
Alarm Trigger
      │
      ▼
 Audio Controller
      │
      ▼
 Audio Sample Memory
      │
      ▼
 PWM Generator
      │
      ▼
 Speaker
```

---

# Audio Playback Flow

```
Alarm Time Match
        │
        ▼
Alarm Activated
        │
        ▼
Read Audio Samples
        │
        ▼
Generate PWM Signal
        │
        ▼
Speaker Output
```

---

# PWM Generator

The PWM Generator converts the digital audio samples into a PWM waveform suitable for driving a speaker.

### Features

- 8-bit PWM Resolution
- Real-Time Audio Output
- FPGA Implementation
- Low Hardware Resource Usage

---

# Audio Module

Responsible for

- Reading Audio Samples
- Managing Playback
- Controlling Sample Address
- Sending Samples to PWM Generator

---

# Source Files

| File | Description |
|------|-------------|
| Digital_clock.v | Top-Level Module |
| Alarm.v | Alarm Logic |
| Stopwatch.v | Stopwatch Logic |
| Audio.v | Audio Playback Module |
| PWM_Generator.v | PWM Audio Generator |
| Display_Controller.v | Display Multiplexing |
| Constraints.xdc | FPGA Pin Constraints |

> **Note:** `BCD_to_7Segment.v` and `Display_Controller.v` are common modules shared across all project versions. Refer to the main repository README for their documentation.

---

# Inputs

| Signal | Description |
|---------|-------------|
| clk | 100 MHz Clock |
| rst | System Reset |
| decision | Display Mode Selection |
| choose | FSM State Selection |
| set | Increment Selected Value |
| play | Stopwatch Control |
| alarm_activation | Enable / Disable Alarm |

---

# Outputs

| Signal | Description |
|---------|-------------|
| seg | Seven Segment Output |
| seg1 | Decimal Point Output |
| AN | Active-Low Digit Selection |
| left_audio_out | Left Audio Channel |
| right_audio_out | Right Audio Channel |

---

# System Architecture

```
                 100 MHz Clock
                        │
                 Clock Divider
                        │
      ┌─────────────────┼─────────────────┐
      │                 │                 │
 Digital Clock     Stopwatch         Alarm
      │                 │                 │
      └─────────────────┼─────────────────┘
                        │
               Audio Controller
                        │
                Audio Sample ROM
                        │
                 PWM Generator
                        │
                     Speaker
                        │
              Display Controller
                        │
             Seven Segment Display
```
---

## Demonstration Video

🔗Link :  https://drive.google.com/file/d/135SWOK2-Uh2TsjnOeSXkuPC6J1dP7fZ0/view?usp=sharing


---

## Top Module

```verilog
`timescale 1ns / 1ps
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
```

##  Stopwatch

```verilog
`timescale 1ns / 1ps
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
```
## Alarm
```Alarm
`timescale 1ns / 1ps
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
```
## Audio
```Audio
`timescale 1ns / 1ps
module audio(
    input  wire clk,          // 100 MHz clock
    input  wire rst, 
    input wire audio_out,         // Active-high reset
    output wire left_audio_out,
    output wire right_audio_out
);
    //==========================================================
    // Parameters
    //==========================================================
    localparam integer SAMPLE_COUNT   = 220000;
    localparam integer SAMPLE_DIVIDER = 12500;
    localparam [17:0] LAST_SAMPLE     = 18'd219999;
    //==========================================================
    // Audio ROM
    //==========================================================
    reg [7:0] audio_rom [0:SAMPLE_COUNT-1];
    initial
    begin
        $readmemh("audio.mem", audio_rom);
    end
    //==========================================================
    // Generate 8 kHz sample tick
    //==========================================================
    reg [13:0] sample_counter;   // only counts to SAMPLE_DIVIDER-1 (12499)
    reg sample_tick;
    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            sample_counter <= 14'd0;
            sample_tick    <= 1'b0;
        end
        else if(!audio_out)
        begin
            sample_counter <= 14'd0;
            sample_tick    <= 1'b0;
        end
        else if(audio_out)
        begin
            if(sample_counter == SAMPLE_DIVIDER-1)
            begin
                sample_counter <= 14'd0;
                sample_tick    <= 1'b1;
            end
            else
            begin
                sample_counter <= sample_counter + 14'd1;
                sample_tick    <= 1'b0;
            end
        end
    end
    //==========================================================
    // Read Audio Samples
    //==========================================================
    reg [17:0] audio_address;
    reg [7:0] current_sample;
    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            audio_address  <= 18'd0;
            current_sample <= 8'd128;
        end
        else if(sample_tick)
        begin
            current_sample <= audio_rom[audio_address];
            if(audio_address == LAST_SAMPLE)
                audio_address <= 18'd0;
            else
                audio_address <= audio_address + 18'd1;
        end
    end
    //==========================================================
    // PWM Generator
    //==========================================================
    reg [7:0] pwm_counter;
    always @(posedge clk or posedge rst)
    begin
        if(rst)
            pwm_counter <= 8'd0;
        else
            pwm_counter <= pwm_counter + 8'd1;
    end
    //==========================================================
    // Audio Output
    //==========================================================
    wire audio_pwm;
    assign audio_pwm = (pwm_counter < current_sample);
    assign left_audio_out  = audio_pwm;
    assign right_audio_out = audio_pwm;
endmodule
```
## Display Controller
```Display_Controller
`timescale 1ns / 1ps
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
```
## Constraints
```Constraints
create_clock -period 10.000 -name sys_clk [get_ports clk]

set_property IOSTANDARD LVCMOS33 [get_ports {AN[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports {decision[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {decision[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN H3 [get_ports {AN[0]}]
set_property PACKAGE_PIN J4 [get_ports {AN[1]}]
set_property PACKAGE_PIN F3 [get_ports {AN[2]}]
set_property PACKAGE_PIN E4 [get_ports {AN[3]}]
set_property PACKAGE_PIN D5 [get_ports {AN[4]}]
set_property PACKAGE_PIN C4 [get_ports {AN[5]}]
set_property PACKAGE_PIN C7 [get_ports {AN[6]}]
set_property PACKAGE_PIN A8 [get_ports {AN[7]}]
set_property PACKAGE_PIN F4 [get_ports {seg[0]}]
set_property PACKAGE_PIN J3 [get_ports {seg[1]}]
set_property PACKAGE_PIN D2 [get_ports {seg[2]}]
set_property PACKAGE_PIN C2 [get_ports {seg[3]}]
set_property PACKAGE_PIN B1 [get_ports {seg[4]}]
set_property PACKAGE_PIN H4 [get_ports {seg[5]}]
set_property PACKAGE_PIN D1 [get_ports {seg[6]}]
set_property PACKAGE_PIN C1 [get_ports {seg[7]}]
set_property PACKAGE_PIN D7 [get_ports {seg1[0]}]
set_property PACKAGE_PIN C5 [get_ports {seg1[1]}]
set_property PACKAGE_PIN A5 [get_ports {seg1[2]}]
set_property PACKAGE_PIN B7 [get_ports {seg1[3]}]
set_property PACKAGE_PIN A7 [get_ports {seg1[4]}]
set_property PACKAGE_PIN D6 [get_ports {seg1[5]}]
set_property PACKAGE_PIN B5 [get_ports {seg1[6]}]
set_property PACKAGE_PIN A6 [get_ports {seg1[7]}]
set_property PACKAGE_PIN F14 [get_ports clk]
set_property PACKAGE_PIN J1 [get_ports rst]

set_property PACKAGE_PIN J2 [get_ports choose]
set_property IOSTANDARD LVCMOS33 [get_ports choose]
set_property PACKAGE_PIN J5 [get_ports set]
set_property IOSTANDARD LVCMOS33 [get_ports set]


set_property PACKAGE_PIN V2 [get_ports {decision[0]}]
set_property PACKAGE_PIN U2 [get_ports {decision[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports alarm_out]
set_property IOSTANDARD LVCMOS33 [get_ports s1_out]
set_property IOSTANDARD LVCMOS33 [get_ports s2_out]
set_property IOSTANDARD LVCMOS33 [get_ports alarm_activation]
set_property PACKAGE_PIN K1 [get_ports alarm_activation]
set_property PACKAGE_PIN A4 [get_ports alarm_out]
set_property PACKAGE_PIN G1 [get_ports s1_out]
set_property PACKAGE_PIN G2 [get_ports s2_out]

set_property IOSTANDARD LVCMOS33 [get_ports play]
set_property PACKAGE_PIN U1 [get_ports play]

set_property IOSTANDARD LVCMOS33 [get_ports left_audio_out]
set_property IOSTANDARD LVCMOS33 [get_ports right_audio_out]
set_property PACKAGE_PIN N13 [get_ports left_audio_out]
set_property PACKAGE_PIN N14 [get_ports right_audio_out]

```

---

# Hardware Requirements

- Boolean Board FPGA
- Seven Segment Display
- Push Buttons
- Speaker / Audio Jack
- 100 MHz On-board Clock

---

# Build Instructions

1. Open the Vivado project.
2. Run **Synthesis**.
3. Run **Implementation**.
4. Generate the **Bitstream**.
5. Program the FPGA.

---

# Improvements over V3

| V3 | V4 |
|----|----|
| Visual Alarm | Audio + Visual Alarm |
| Alarm Trigger | Alarm with Sound Playback |
| Digital Display | Digital Display + Speaker |
| Clock, Calendar, Stopwatch, Alarm | Complete Digital Clock System |

---

# Learning Outcomes

Version 4 demonstrates practical implementation of:

- Verilog HDL
- Modular RTL Design
- Finite State Machines
- Stopwatch Design
- Alarm Design
- PWM Signal Generation
- Audio Playback
- Memory Initialization (`$readmemh`)
- Seven Segment Multiplexing
- FPGA Hardware Design

---

# Future Improvements

- SD Card Audio Playback
- WAV File Support
- RTC Integration
- OLED Display
- Bluetooth Time Synchronization
- Volume Control

---

# Common Modules

The following modules are shared across all versions of the project.

- `BCD_to_7Segment.v`

Refer to the **main repository README** for their complete documentation.

---

# Project Completion

Version 4 marks the successful completion of the **"Exploring Boolean Board through Digital Clock"** project.

Starting from a simple digital clock in **V1**, the project evolved into a complete FPGA application featuring a **Calendar, Stopwatch, Alarm, and Audio Playback**, demonstrating a progressive learning approach to digital system design using **Verilog HDL**.

⭐ If you found this project helpful, consider giving the repository a **Star** on GitHub!
