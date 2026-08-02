# Digital Clock — V2

## Overview
V2 builds on V1 by adding a **calendar/date counter** and an **FSM-based mode selector**, so the same display can now show either the current Time or the current Date, switched with a `choose` input. It also reworks how the "set" buttons work, using a state machine instead of separate `min_set`/`hr_set`/`day_set` inputs.

The 7-segment driving technique (BCD decoding + time-multiplexed digit scanning) still follows the seven-segment display reference from Real Digital's boolean board documentation:
https://www.realdigital.org/doc/02013cd17602c8af749f00561f88ae21#seven-segment-display

## Files

| File | Description |
|---|---|
| `Digital_clock.v` | Top-level module. Adds `date_ones`/`date_tens` counters, a 3-state FSM (`s0`, `s1`, `s2`) to select what is being "set" (idle / minute+day / hour+date), and a `decision` input to choose Time vs Date display. |
| `Display_Controller.v` | Extended to multiplex between two full 4-digit groups: Time (sec/min/hr) and Date (day/date), selected by the `decision` signal. |
| `BCD_to_7Segment.v` | Unchanged from V1 — active-low BCD-to-7-segment decoder. |
| `Digital_Clock_tb.v` | Testbench for simulating clock and date counters. |
| `Digital_Clock.srcs/Constraint/new/Constraints.xdc` | Updated pin constraints — adds `decision` and `date_set` pins, reorganizes IOSTANDARD assignments. |
| `Working Video - V2.mp4` | Demo of V2 running on hardware. |

## Top-Level Ports (`Digital_clock`)

```verilog
module Digital_clock(
    input  clk, decision,
    input  rst, set, choose,
    output [7:0] seg, seg1, AN,
    output s1_out, s2_out
);
```

- `clk`, `rst` — system clock and reset
- `decision` — selects whether the display shows Time or Date
- `choose` — cycles the FSM state (`s0` → `s1` → `s2` → `s0`), selecting which field is being set
- `set` — increments the field currently selected by the FSM state
- `s1_out`, `s2_out` — status outputs indicating current FSM state (e.g. to drive LEDs)
- `seg`, `seg1`, `AN` — 7-segment display outputs (same as V1)

## What's New vs V1

- **Date counter**: `date_ones`/`date_tens` roll over at day 31, in sync with the day-of-week counter.
- **FSM-based setting**: instead of three separate set buttons, a single `set` button now adjusts whichever field the FSM (`state`/`next_state`, states `s0`/`s1`/`s2`) currently points to — minutes/day in `s1`, hours/date in `s2` — split further by the `decision` input (time-set mode vs date-set mode).
- **Two display modes**: `decision` toggles the entire display between showing Time (sec/min/hr) and Date (day/date).

## Build / Simulate

1. Open `Digital_Clock.xpr` in Vivado.
2. Confirm `Digital_clock` is set as top module.
3. Run Synthesis → Implementation → Generate Bitstream.
4. Program the board using `Digital_Clock.runs/impl_1/Digital_clock.bit`.
5. Simulate with `Digital_Clock_tb.v` to verify both Time and Date counting/rollover before testing on hardware.
