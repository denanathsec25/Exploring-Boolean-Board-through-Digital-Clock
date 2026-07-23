`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2026 14:27:07
// Design Name: 
// Module Name: Digital_clk_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// while runnig stimulation thriugh test bench change localparam clk_freq=10;

module Digital_clock_tb;

reg clk;
reg rst;

wire [3:0] sec_ones;
wire [3:0] sec_tens;
wire [3:0] min_ones;
wire [3:0] min_tens;
wire [3:0] hr_ones;
wire [3:0] hr_tens;
wire [3:0] day;

Digital_clock uut (
    .sec_ones(sec_ones),
    .sec_tens(sec_tens),
    .min_ones(min_ones),
    .min_tens(min_tens),
    .hr_ones(hr_ones),
    .hr_tens(hr_tens),
    .day(day),
    .clk(clk),
    .rst(rst)
);


initial
begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial
begin
    rst = 1;

    #20;

    rst = 0;
    #700;

    $finish;
end


initial
begin
    $monitor(
        "Simulation Time = %0t ns | Day = %0d | Time = %0d%0d:%0d%0d:%0d%0d",
        $time,
        day,
        hr_tens,
        hr_ones,
        min_tens,
        min_ones,
        sec_tens,
        sec_ones
    );
end

endmodule