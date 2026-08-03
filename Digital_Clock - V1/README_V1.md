# Digital Clock - V1

> The first version of the Digital Clock project developed on the **Boolean Board FPGA** using **Verilog HDL**.

![Version](https://img.shields.io/badge/Version-V1-blue)
![Verilog](https://img.shields.io/badge/Language-Verilog-red)
![Vivado](https://img.shields.io/badge/Tool-Xilinx%20Vivado-green)

---

# Overview

V1 implements a basic **24-hour Digital Clock** with a **Day Counter** displayed on an 8-digit seven-segment display.

### Features

- 24-Hour Digital Clock
- Hours, Minutes and Seconds Counter
- Day Counter (0–6)
- Manual Hour/Minute/Day Setting
- Seven-Segment Display Multiplexing
- 100 MHz Clock Divider

---

# Project Structure

```
Digital_Clock-V1/
│
├── Digital_clock.v
├── Display_Controller.v
├── BCD_to_7Segment.v
├── Digital_Clock_tb.v
├── Constraints.xdc
├── Working Video - V1.mp4
└── README.md
```

---

---

# Module Description

## 1. Digital_clock.v

Main module responsible for

- Clock Divider
- Time Counter
- Day Counter
- Manual Time Setting
- Display Data Generation

---

## 2. Display_Controller.v

Responsible for

- Seven-Segment Multiplexing
- Digit Selection
- Sending BCD values to the decoder

---

## 3. BCD_to_7Segment.v

Converts a 4-bit BCD value into the corresponding Seven-Segment display output.

---

# Module Instantiation

Copy and paste directly into your project.

## Top Module
```verilog
`timescale 1ns / 1ps
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

```
---

## Display Controller

```verilog
`timescale 1ns / 1ps
module Display_controller(
    input clk,rst,
    input [3:0]sec_ones,sec_tens,min_ones,min_tens,hr_ones,hr_tens,day,
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
            clk_div <= 3'd0;
        else
            clk_div <= clk_div + 1'b1;
    end
    assign display_selection = clk_div[15:13];
 
    always @(*)
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
        3'd6:
        begin
            display_bcd = day;
            dp = 1'b1;
            AN = 8'b01111111;
        end
        default : AN = 8'b11111111;
        endcase
    end
    
    BCD_to_7Segment decoder(
    .seg(seg),
    .bcd(display_bcd),
    .dp(dp)
    );
endmodule

```

## Constraints

```Constraint
create_clock -period 10.000 -name sys_clk [get_ports clk]


set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports hr_set]
set_property IOSTANDARD LVCMOS33 [get_ports min_set]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN J2 [get_ports hr_set]
set_property PACKAGE_PIN J5 [get_ports min_set]
set_property PACKAGE_PIN J1 [get_ports rst]
set_property PACKAGE_PIN F14 [get_ports clk]

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

set_property IOSTANDARD LVCMOS33 [get_ports {seg1[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg1[0]}]
set_property PACKAGE_PIN D7 [get_ports {seg1[0]}]
set_property PACKAGE_PIN C5 [get_ports {seg1[1]}]
set_property PACKAGE_PIN A5 [get_ports {seg1[2]}]
set_property PACKAGE_PIN B7 [get_ports {seg1[3]}]
set_property PACKAGE_PIN A7 [get_ports {seg1[4]}]
set_property PACKAGE_PIN D6 [get_ports {seg1[5]}]
set_property PACKAGE_PIN B5 [get_ports {seg1[6]}]
set_property PACKAGE_PIN A6 [get_ports {seg1[7]}]

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]


set_property CONFIG_MODE SPIx4 [current_design]

set_property IOSTANDARD LVCMOS33 [get_ports day_set]
set_property PACKAGE_PIN H2 [get_ports day_set]

```

---

# Clock Operation

```
100 MHz Clock
      │
      ▼
Clock Divider
      │
      ▼
1 Second Tick
      │
      ▼
Seconds Counter
      │
      ▼
Minutes Counter
      │
      ▼
Hours Counter
      │
      ▼
Day Counter
```

---

# Inputs

| Signal | Description |
|---------|-------------|
| clk | 100 MHz System Clock |
| rst | Reset Clock |
| min_set | Increment Minutes |
| hr_set | Increment Hours |
| day_set | Increment Day |

---

# Outputs

| Signal | Description |
|---------|-------------|
| seg | Seven Segment Output |
| seg1 | Decimal Point Output |
| AN | Active-Low Digit Enable |

---

# Simulation

Run the provided testbench.

```
Digital_Clock_tb.v
```

---

# Build Instructions

1. Open **Digital_Clock.xpr**
2. Run **Synthesis**
3. Run **Implementation**
4. Generate **Bitstream**
5. Program the FPGA

---

# Hardware Demonstration

```
Working Video - V1.mp4
```

---

# Reference

The Seven-Segment Display implementation is based on the **Real Digital Boolean Board** documentation.

https://www.realdigital.org/doc/02013cd17602c8af749f00561f88ae21#seven-segment-display

---

# What's Next?

Version 2 introduces:

- Date Counter
- Calendar
- Finite State Machine (FSM)
- Time/Date Switching

➡️ See **Digital_Clock-V2** for the next stage of the project.
