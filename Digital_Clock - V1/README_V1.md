# Digital Clock — V1

## Overview
V1 is the base version of the FPGA digital clock. It implements a real-time clock (seconds, minutes, hours) plus a simple day-of-week counter, displayed on a multiplexed 7-segment display driven from a 100 MHz system clock.

The 7-segment driving technique (BCD decoding + time-multiplexed digit scanning) follows the seven-segment display reference from Real Digital's boolean board documentation:
https://www.realdigital.org/doc/02013cd17602c8af749f00561f88ae21#seven-segment-display

## Files

| File | Description |
|---|---|
| `Digital_clock.v` | Top-level module. Divides the 100 MHz clock down to a 1-second tick and increments seconds → minutes → hours → day. Handles manual set inputs for hours, minutes, and day. |
| `Display_Controller.v` | Cycles through the 8 display digits (`AN[7:0]`) using a clock-divider-based scan counter, feeding the correct BCD digit to the decoder each cycle. |
| `BCD_to_7Segment.v` | Combinational BCD-to-7-segment decoder (active-low segments) with decimal point control. |
| `Digital_Clock_tb.v` | Testbench for simulating the clock counters. |
| `Constraints.xdc` | Pin mapping (clock, reset, set buttons, segment/anode outputs) and clock constraint (100 MHz / 10 ns period). |
| `Working Video - V1.mp4` | Demo of V1 running on hardware. |

## Top-Level Ports (`Digital_clock`)

```verilog
module Digital_clock(seg, seg1, AN, clk, rst, min_set, hr_set, day_set);
```

- `clk` — 100 MHz system clock
- `rst` — synchronous/async reset
- `min_set`, `hr_set`, `day_set` — manual increment buttons for minutes, hours, and day
- `seg`, `seg1` — 7-segment cathode outputs (tied together, active-low)
- `AN` — 8-bit active-low anode/digit-select output

## Functionality

- Counts seconds → minutes → hours (12/24-hour rollover logic implemented via BCD digit comparisons, e.g. `hr_tens == 2 && hr_ones == 3` for 23:59:59 rollover).
- Increments a 7-value day counter (0–6) once per day, with a `day_set` button to manually adjust it.
- `min_set` / `hr_set` allow manually incrementing minutes/hours for setting the time, with correct BCD carry logic (ones → tens rollover).
- Display is refreshed digit-by-digit via `Display_Controller`, showing: seconds, minutes, hours, and day across the available digit positions.

## Build / Simulate

1. Open `Digital_Clock.xpr` in Vivado.
2. Set `Digital_clock` as the top module (already configured in the project).
3. Run Synthesis → Implementation → Generate Bitstream.
4. Program the board using the generated `.bit` file at `Digital_Clock.runs/impl_1/Digital_clock.bit`.
5. Use `Digital_Clock_tb.v` under the simulation sources to verify counter behavior in the simulator before deploying to hardware.
