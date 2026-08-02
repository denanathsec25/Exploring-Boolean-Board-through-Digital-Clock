# Exploring Boolean Board through Digital Clock

![Verilog](https://img.shields.io/badge/Language-Verilog-blue)
![Vivado](https://img.shields.io/badge/Tool-Xilinx%20Vivado-red)
![Boolean Board](https://img.shields.io/badge/Platform-Boolean%20Board-green)
![License](https://img.shields.io/badge/License-Educational-yellow)

## About

This repository documents my journey of exploring the **Boolean Board FPGA** by incrementally building a **Digital Clock** using **Verilog HDL** and **Xilinx Vivado**.

Each version introduces new digital design concepts while preserving the previous functionality, making the project suitable for students learning FPGA-based digital system design.

> **This project is developed purely for educational and learning purposes. Feel free to use, modify, and learn from it with appropriate attribution.**

---

## Project Evolution

| Version | Features |
|---------|----------|
| **V1** | Digital Clock (Time & Day) |
| **V2** | Calendar + FSM-based Setting |
| **V3** | Stopwatch + Alarm |
| **V4** | Audio Playback using PWM |

Each version includes its own detailed documentation inside its respective folder.

---

## Repository Structure

```text
Exploring-Boolean-Board-through-Digital-Clock/
│
├── README.md
├── Digital_Clock-V1/
├── Digital_Clock-V2/
├── Digital_Clock-V3/
├── Digital_Clock-V4/
└── Audio_Test/
```

---

## Tools & Technologies

- Verilog HDL
- Xilinx Vivado
- Boolean Board FPGA
- Git & GitHub

---


# 📦 Common Modules

The following modules are shared across all versions of the project.

---

## BCD_to_7Segment.v

Converts a **4-bit Binary-Coded Decimal (BCD)** input into the corresponding **7-segment display pattern**.

```verilog
`timescale 1ns / 1ps
module BCD_to_7Segment(seg,bcd,dp);
output reg [7:0]seg;
input [3:0]bcd;
input dp;
always @(*)
begin
    // Active-low: 0 = ON, 1 = OFF

    case(bcd)
        4'd0:
        begin
            seg[6:0] = 7'b1000000;
        end
        4'd1:
        begin
            seg[6:0] = 7'b1111001;
        end
        4'd2:
        begin
             seg[6:0] = 7'b0100100;
        end
        4'd3:
        begin
             seg[6:0] = 7'b0110000;
        end
        4'd4:
        begin
            seg[6:0] = 7'b0011001;
        end
        4'd5:
        begin
            seg[6:0] = 7'b0010010;
        end
        4'd6:
        begin
              seg[6:0] = 7'b0000010;
        end
        4'd7:
        begin
            seg[6:0] = 7'b1111000;
        end
        4'd8:
        begin
            seg[6:0] = 7'b0000000;
       end
        4'd9:
        begin
            seg[6:0] = 7'b0010000;
        end
        default:
        begin
            seg[6:0] = 7'b1111111;
        end
    endcase
    
    if(dp)
        seg[7] = 1'b0;
    else
        seg[7] = 1'b1;
    
end
endmodule

```

---

### Features


## Concepts Covered

- Verilog HDL
- Clock Divider
- Seven-Segment Display Multiplexing
- Counters
- Finite State Machines (FSM)
- Stopwatch
- Alarm
- PWM Audio Generation
- Modular RTL Design

---

## Reference

The seven-segment display implementation is inspired by the Real Digital Boolean Board documentation:

https://www.realdigital.org/doc/02013cd17602c8af749f00561f88ae21#seven-segment-display

---

## Author

**Denanath S**

Electronics and Communication Engineering

Bannari Amman Institute of Technology

GitHub: https://github.com/denanathsec25

LinkedIn: https://www.linkedin.com/in/denanaths-/

---

## License

This repository is released **free for educational and non-commercial use**.

If this project helps you in your learning, consider giving the repository a ⭐ on GitHub.
