# Digital Clock - V2

> Version 2 extends the basic digital clock by introducing a **Calendar**, **Finite State Machine (FSM)**, and **Time/Date display switching**.

![Version](https://img.shields.io/badge/Version-V2-blue)
![Verilog](https://img.shields.io/badge/Language-Verilog-red)
![Vivado](https://img.shields.io/badge/Tool-Xilinx%20Vivado-green)

---

# Overview

Version 2 builds upon **V1** by adding a **Date Counter** and an **FSM-based setting mechanism**. The user can now switch between displaying the current **Time** and **Date** using a single control input.

---

# New Features

- Calendar (Date Counter)
- Time / Date Display Switching
- Finite State Machine (FSM)
- Single Button Configuration
- Improved User Interface

---

# Project Structure

```text
Digital_Clock-V2/
│
├── Digital_clock.v
├── Display_Controller.v
├── BCD_to_7Segment.v
├── Digital_Clock_tb.v
├── Constraints.xdc
├── Working Video - V2.mp4
└── README.md
```

---

# What's New in V2?

## Date Counter

The clock now maintains the current **date** in addition to time.

Supported Range

```
01 → 31
```

---

## Time / Date Switching

The `decision` input selects the display mode.

| decision | Display |
|----------|----------|
| 0 | Time |
| 1 | Date |

---

## FSM-Based Setting

Instead of having separate buttons for each field, Version 2 introduces a **Finite State Machine (FSM)** to determine which value is modified.

The `choose` button changes the current state, while the `set` button increments the selected value.

### FSM States

| State | Function |
|--------|----------|
| S0 | Normal Operation |
| S1 | Minute / Day Setting |
| S2 | Hour / Date Setting |

---

# Signal Description

## Inputs

| Signal | Description |
|---------|-------------|
| clk | 100 MHz System Clock |
| rst | System Reset |
| decision | Select Time or Date Display |
| choose | Change FSM State |
| set | Increment Selected Field |

---

## Outputs

| Signal | Description |
|---------|-------------|
| seg | Seven Segment Output |
| seg1 | Decimal Point Output |
| AN | Active-Low Digit Select |
| s1_out | FSM State Indicator |
| s2_out | FSM State Indicator |

---

# Clock Architecture

```
                 100 MHz Clock
                        │
                 Clock Divider
                        │
        ┌───────────────┴───────────────┐
        │                               │
   Time Counter                  Date Counter
        │                               │
        └───────────────┬───────────────┘
                        │
                  Finite State Machine
                        │
                 Display Controller
                        │
                Seven Segment Display
```

---

## Top Module

```verilog
`timescale 1ns / 1ps
module Digital_clock(
input clk,decision,
input rst,set,choose,
output [7:0]seg,seg1,AN,
output s1_out,s2_out
);

reg [3:0]sec_ones,sec_tens,min_ones,min_tens,hr_ones,hr_tens,day,date_ones,date_tens;
localparam clk_freq = 100000000;

reg [31:0] clock_count;
reg one_second_enable;

reg [1:0]state,next_state;
localparam s0 = 2'b00,
           s1 = 2'b01,//min, day
           s2 = 2'b10;//hr, date

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

assign s1_out = (state == s1) ? 1 : 0;
assign s2_out = (state == s2) ? 1 : 0;

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
    if(rst)
    begin
        sec_ones<=0;
        sec_tens<=0;
        min_ones<=0;
        min_tens<=0;
        hr_ones<=0;
        hr_tens<=0;
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
         
        if(state == s1 && set == 1 && decision == 0)
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
        if(state == s2 &&  set == 1 && decision == 0)
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
       
        if(state == s1 && set == 1 && decision == 1)
        begin
        if(day == 7)
            day <=1;
            else
                day <= day + 1;
        end
        
       if(state == s2 && set == 1 && decision == 1)
        begin
            date_ones <=date_ones + 1;
            
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
        
        .decision(decision),

        .AN(AN),
        .seg(seg)
        );

endmodule
```

## Display_Controller
```verilog
`timescale 1ns / 1ps
module Display_controller(
    input clk,rst,decision,
    input [3:0]sec_ones,sec_tens,min_ones,min_tens,hr_ones,hr_tens,day,date_ones,date_tens,
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
        if(!decision)
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
        
        if(decision)
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
    end
    
    BCD_to_7Segment decoder(
    .seg(seg),
    .bcd(display_bcd),
    .dp(dp)
    );
endmodule

```

## Constraintd

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
set_property IOSTANDARD LVCMOS33 [get_ports decision]
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
set_property PACKAGE_PIN V2 [get_ports decision]
set_property PACKAGE_PIN J1 [get_ports rst]

set_property PACKAGE_PIN J2 [get_ports choose]
set_property IOSTANDARD LVCMOS33 [get_ports choose]
set_property PACKAGE_PIN J5 [get_ports set]
set_property IOSTANDARD LVCMOS33 [get_ports set]


set_property IOSTANDARD LVCMOS33 [get_ports s1_out]
set_property IOSTANDARD LVCMOS33 [get_ports s2_out]
set_property PACKAGE_PIN G1 [get_ports s1_out]
set_property PACKAGE_PIN G2 [get_ports s2_out]

```
---

        
# Build Instructions

1. Open **Digital_Clock.xpr**
2. Run **Synthesis**
3. Run **Implementation**
4. Generate **Bitstream**
5. Program the FPGA

---

Working

# Common Modules

The following modules are common across all project versions.

- `BCD_to_7Segment.v`

Refer to the **main repository README** for their documentation.

---

# Improvements over V1

| V1 | V2 |
|----|----|
| Time Display | Time + Date Display |
| Manual Setting | FSM-Based Setting |
| Clock Only | Clock + Calendar |
| Separate Controls | Single Configuration Interface |

---

# Next Version

Version 3 introduces:

- Stopwatch
- Alarm
- Four Operating Modes

➡️ Continue to **Digital_Clock-V3**.
