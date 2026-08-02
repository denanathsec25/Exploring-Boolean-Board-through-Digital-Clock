# Digital Clock — FPGA Project (Verilog / Vivado)


This repository contains an FPGA-based digital clock built in Verilog, developed incrementally across **four versions (V1–V4)**. Each version adds new functionality on top of the previous one, going from a simple HH:MM:SS clock to a full clock + calendar + stopwatch + alarm + audio system.

The seven-segment display driving technique used throughout this project (BCD to 7-segment decoding, multiplexed/time-division display scanning across multiple digits) is based on the reference design and explanation from Real Digital's boolean board documentation:
👉 https://www.realdigital.org/doc/02013cd17602c8af749f00561f88ae21#seven-segment-display

## Repository Structure

```
Digital Clock/
├── Digital_Clock - V1/     → Basic HH:MM:SS clock with day counter
├── Digital_Clock - V2/     → Adds calendar (date) display + FSM-based mode switching
├── Digital_Clock - V3/     → Adds Stopwatch and Alarm modules
├── Digital_Clock - V4/     → Adds Audio/sound output on top of V3
├── Audio_test/             → Standalone test project for the audio playback module
└── flatten_for_git.ps1     → Helper script used to flatten Vivado project folders for git
```

Each version folder is a self-contained Vivado project (`.xpr`) with its own `.srcs`, `.runs`, and `.cache` directories, so any version can be opened and built independently in Vivado.

## Common Hardware Concept

All versions share the same core display architecture:

1. **BCD_to_7Segment.v** — Converts a 4-bit BCD digit (0–9) into the active-low 7-segment pattern (segments a–g + decimal point), following the standard seven-segment encoding described in the boolean board reference above.
2. **Display_Controller.v** — Since the board has multiple 7-segment digits but only one shared segment bus, this module rapidly cycles through each digit (time-division multiplexing) using a clock divider, driving the correct anode (`AN`) and the correct BCD value for that instant. Because the switching is fast enough, the human eye perceives all digits as being lit simultaneously.
3. **Digital_clock.v** — The top-level module. Contains the main counters (seconds, minutes, hours, day/date) driven off a 100 MHz system clock divided down to a 1-second tick, and wires everything into the display controller.

## Version Summary

| Version | Key Additions |
|---|---|
| V1 | Basic clock: seconds, minutes, hours, day-of-week counter, manual hour/minute/day set inputs |
| V2 | Adds a full calendar (date) counter, an FSM (`state`/`decision`) to switch between viewing Time and Date on the display, and updated set-logic for date |
| V3 | Adds a **Stopwatch** module (start/stop, ms/sec/min/hr counting) and an **Alarm** module (settable alarm time + alarm trigger output), selectable via a 2-bit `decision` mode selector |
| V4 | Adds an **Audio** module that plays back a stored PCM sample (`audio.mem`) through left/right audio outputs, e.g. as an alarm tone |

See the individual README inside each version's folder for module-level details, port lists, and how to build/simulate that specific version.

## Tools Used

- **Xilinx Vivado** (project mode, `.xpr` projects) for synthesis, implementation, and bitstream generation.
- **Verilog HDL** for all RTL design and testbenches.
- Each version folder includes a working demo video (`Working Video - V*.mp4`) showing the design running on hardware.

## Notes

- `.gitignore` and `flatten_for_git.ps1` are used to keep the repository size manageable by excluding/flattening large Vivado-generated build artifacts (`.cache`, `.runs`, `.sim`, `.ip_user_files`, etc.) where possible.
- Bitstreams (`*.bit`) for each version are available under `Digital_Clock - V*/Digital_Clock - V*.runs/impl_1/` (or `impl_1/Digital_clock.bit`) after a successful implementation run.
