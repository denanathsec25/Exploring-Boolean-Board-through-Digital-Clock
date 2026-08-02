`timescale 1ns / 1ps
module audio(
    input  wire clk,          // 100 MHz clock
    input  wire rst, 
    input wire audio_out,         // Active-high reset
    output wire left_audio_out,
    output wire right_audio_out
);
    //==========================================================
    // Parameters
    //==========================================================
    localparam integer SAMPLE_COUNT   = 220000;
    localparam integer SAMPLE_DIVIDER = 12500;
    localparam [17:0] LAST_SAMPLE     = 18'd219999;
    //==========================================================
    // Audio ROM
    //==========================================================
    reg [7:0] audio_rom [0:SAMPLE_COUNT-1];
    initial
    begin
        $readmemh("audio.mem", audio_rom);
    end
    //==========================================================
    // Generate 8 kHz sample tick
    //==========================================================
    reg [13:0] sample_counter;   // only counts to SAMPLE_DIVIDER-1 (12499)
    reg sample_tick;
    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            sample_counter <= 14'd0;
            sample_tick    <= 1'b0;
        end
        else if(!audio_out)
        begin
            sample_counter <= 14'd0;
            sample_tick    <= 1'b0;
        end
        else if(audio_out)
        begin
            if(sample_counter == SAMPLE_DIVIDER-1)
            begin
                sample_counter <= 14'd0;
                sample_tick    <= 1'b1;
            end
            else
            begin
                sample_counter <= sample_counter + 14'd1;
                sample_tick    <= 1'b0;
            end
        end
    end
    //==========================================================
    // Read Audio Samples
    //==========================================================
    reg [17:0] audio_address;
    reg [7:0] current_sample;
    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            audio_address  <= 18'd0;
            current_sample <= 8'd128;
        end
        else if(sample_tick)
        begin
            current_sample <= audio_rom[audio_address];
            if(audio_address == LAST_SAMPLE)
                audio_address <= 18'd0;
            else
                audio_address <= audio_address + 18'd1;
        end
    end
    //==========================================================
    // PWM Generator
    //==========================================================
    reg [7:0] pwm_counter;
    always @(posedge clk or posedge rst)
    begin
        if(rst)
            pwm_counter <= 8'd0;
        else
            pwm_counter <= pwm_counter + 8'd1;
    end
    //==========================================================
    // Audio Output
    //==========================================================
    wire audio_pwm;
    assign audio_pwm = (pwm_counter < current_sample);
    assign left_audio_out  = audio_pwm;
    assign right_audio_out = audio_pwm;
endmodule