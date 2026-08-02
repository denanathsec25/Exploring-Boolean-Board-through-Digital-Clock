# Digital Clock — V4

## Overview
V4 builds on V3 by adding an **Audio playback module**, giving the clock a real sound output — most notably intended to drive an audible tone when the alarm goes off. Everything from V3 (Time, Date, Stopwatch, Alarm) is retained.

The 7-segment driving technique (BCD decoding + time-multiplexed digit scanning) still follows the seven-segment display reference from Real Digital's boolean board documentation:
https://www.realdigital.org/doc/02013cd17602c8af749f00561f88ae21#seven-segment-display

## Files

| File | Description |
|---|---|
| `digital_clock.v` | Top-level module. Instantiates the new `audio` module alongside the existing `stopwatch`, `alarm`, and display logic. Adds `left_audio_out`/`right_audio_out` outputs. |
| `audio.v` | New module. Reads 8-bit PCM samples from an internal ROM (`audio_rom`, loaded from `audio.mem` via `$readmemh`) and streams them out at an 8 kHz sample rate (derived from the 100 MHz clock) whenever playback is triggered. |
| `audio.mem` | Hex-encoded PCM audio sample data loaded into the audio ROM at synthesis/simulation time. |
| `stopwatch.v` | Unchanged from V3 — stopwatch timing logic. |
| `alarm.v` | Unchanged from V3 — alarm set/compare logic. |
| `display_controller.v` | Unchanged multiplexed display logic from V3. |
| `BCD_to_7Segment.v` | Unchanged active-low BCD-to-7-segment decoder. |
| `Constraints.xdc` | Pin constraints updated with audio output pins. |
| `Working Video - V4.mp4` | Demo of V4 running on hardware, including audio playback. |

## Top-Level Ports (`Digital_clock`)

```verilog
module Digital_clock(
    input  clk,
    input  [1:0] decision,
    input  rst, set, choose,
    output [7:0] seg, seg1, AN,
    output s1_out, s2_out,
    output left_audio_out, right_audio_out,
    // Stopwatch
    input  play,
    // Alarm
    input  alarm_activation,
    output alarm_out
);
```

## New Module: `audio.v`

```verilog
module audio(
    input  wire clk,             // 100 MHz clock
    input  wire rst,             // Active-high reset
    input  wire audio_out,       // Playback enable
    output wire left_audio_out,
    output wire right_audio_out
);
```

- Stores `SAMPLE_COUNT = 220000` 8-bit PCM samples in `audio_rom`, initialized from `audio.mem`.
- Derives an 8 kHz sample tick (`SAMPLE_DIVIDER = 12500` cycles of the 100 MHz clock) to advance through the ROM one sample at a time.
- Outputs the streamed audio on `left_audio_out` / `right_audio_out` while `audio_out` (playback enable, typically tied to the alarm trigger) is asserted; resets/holds at sample 0 otherwise.

> Note: There is also a separate standalone **`Audio_test/`** project at the repository root used purely to test/bring up the audio module and PCM playback in isolation from the rest of the clock design — see its own build files (`Audio_test.xpr`, `audio_test.v`) if you want to test audio playback independently.

## Build / Simulate

1. Open `Digital Clock - V4.xpr` in Vivado.
2. Confirm `Digital_clock` is set as the top module.
3. Run Synthesis → Implementation → Generate Bitstream.
4. Program the board using `Digital Clock - V4.runs/impl_1/Digital_clock.bit`.
5. Ensure `audio.mem` is present alongside the audio source (it's read via `$readmemh` at elaboration/simulation time — both in simulation and on real hardware during bitstream generation).
6. Connect an audio codec/speaker to `left_audio_out`/`right_audio_out` to hear playback when the alarm (or manually asserted `audio_out`) triggers.
