# Digital Clock — V3

## Overview
V3 extends V2 by adding two brand-new features: a **Stopwatch** and an **Alarm**. The display's mode selector (`decision`) is widened from 1 bit to 2 bits so the device can now switch between four modes: Time, Date, Stopwatch, and Alarm.

The 7-segment driving technique (BCD decoding + time-multiplexed digit scanning) still follows the seven-segment display reference from Real Digital's boolean board documentation:
https://www.realdigital.org/doc/02013cd17602c8af749f00561f88ae21#seven-segment-display

## Files

| File | Description |
|---|---|
| `digital_clock.v` | Top-level module. Now instantiates `stopwatch` and `alarm` alongside the existing clock/date counters and display controller. `decision` is 2 bits: `00` = Time, `01` = Date, `10` = Stopwatch, `11` = Alarm. |
| `stopwatch.v` | New module. Counts milliseconds/seconds/minutes/hours while `play` is active and `decision == 2'b10`, with a dedicated ms-tick generator off the 100 MHz clock. |
| `alarm.v` | New module. Lets the user set an alarm hour/minute (via `set`/FSM `state` when `decision == 2'b11`), and raises `alarm_out` when the current time matches the alarm time (armed via `alarm_activation`). |
| `Display_controller.v` | Extended again to also multiplex the Stopwatch and Alarm digit groups depending on `decision`. |
| `BCD_to_7Segment.v` | Unchanged — active-low BCD-to-7-segment decoder. |
| `Display_clock_tb.v` | Testbench covering the extended top-level design. |
| `Constraints.xdc` | Pin constraints updated for the new `play` and `alarm_activation` inputs and `alarm_out` output. |
| `Working Video - V3.mp4` | Demo of V3 running on hardware. |

## Top-Level Ports (`Digital_clock`)

```verilog
module Digital_clock(
    input  clk,
    input  [1:0] decision,   // 00: time, 01: date, 10: stopwatch, 11: alarm
    input  rst, set, choose,
    output [7:0] seg, seg1, AN,
    output s1_out, s2_out,
    // Stopwatch
    input  play,
    // Alarm
    input  alarm_activation,
    output alarm_out
);
```

## New Modules

### `stopwatch.v`
```verilog
module stopwatch(
    input play,
    input clk, rst,
    input [1:0] decision,
    output reg [3:0] t_ms_ones, t_ms_tens, t_ms_hun,
                      t_sec_ones, t_sec_tens,
                      t_min_ones, t_min_tens,
                      t_hr_ones, t_hr_tens
);
```
- Generates a 1 ms tick from the 100 MHz clock and increments a full hh:mm:ss:ms counter chain while `play` is held and the display is in stopwatch mode (`decision == 2'b10`).

### `alarm.v`
```verilog
module alarm(
    output reg [3:0] alarm_min_ones, alarm_min_tens,
                      alarm_hr_ones, alarm_hr_tens,
    output reg alarm_out,
    input clk, rst,
    input [1:0] state,
    input set,
    input [1:0] decision,
    input one_second_enable, alarm_activation,
    input [3:0] min_ones, min_tens, hr_ones, hr_tens
);
```
- In alarm-set mode (`decision == 2'b11`), the FSM `state` selects whether `set` increments the alarm minutes or alarm hours.
- When `alarm_activation` is enabled, `alarm_out` is asserted once the live clock time matches the stored alarm time.

## Build / Simulate

1. Open `Digital Clock V3.xpr` in Vivado.
2. Confirm `Digital_clock` is set as the top module.
3. Run Synthesis → Implementation → Generate Bitstream.
4. Program the board using `Digital Clock V3.runs/impl_1/Digital_clock.bit`.
5. Use `Display_clock_tb.v` to simulate all four modes (Time/Date/Stopwatch/Alarm) before testing on hardware.
