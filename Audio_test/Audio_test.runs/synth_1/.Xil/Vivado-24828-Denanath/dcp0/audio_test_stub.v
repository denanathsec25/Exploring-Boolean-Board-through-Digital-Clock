// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* LAST_SAMPLE = "18'b111000001001101111" *) (* SAMPLE_COUNT = "235000" *) (* SAMPLE_DIVIDER = "12500" *) 
module audio_test(clk, rst, left_audio_out, right_audio_out, led);
  input clk;
  input rst;
  output left_audio_out;
  output right_audio_out;
  output [1:0]led;
endmodule
