/**
 * @file dev_gpo.sv
 * @brief GPO HDL module
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 *
 * rd_data는 합성시 0으로 연결�?�
 */
`begin_keywords "1800-2017"
`timescale 1ns/1ps

`include "io_map.svh"

module dev_adc
  import vanilla_pkg::*;
   (
    // WISHBONE interface
    input logic                       CLK_I,
    input logic                       RST_I,
    input logic [`REG_ADDR_WIDTH-1:0] ADDR_I,
    input logic [`DATA_WIDTH-1:0]     DAT_I,
    output logic [`DATA_WIDTH-1:0]    DAT_O,
    input logic                       CYC_I,
    input logic                       STB_I,
    input logic                       WE_I,
    output logic                      ACK_O,
    
    // ADC
    input logic                        vp_in,
    input logic                        vn_in
    );

   // signal
   logic [15:0]             adc_reg;
   logic                    ack_reg;
   
   logic                    enable;
   logic                    drdy;
   logic [6:0]              channel = 7'b0000000;
   
   // Tie this to the ADC code created by the wizard
    xadc_wiz_0 xadc_wiz_0
          (.daddr_in(channel),
          .dclk_in(CLK_I),              // Clock input for the dynamic reconfiguration port
          .den_in(enable),              // Data enable
          .di_in(0),
          .dwe_in(0),                   // Write enable
          .busy_out(),                  // ADC Busy signal
          .channel_out(),               // Channel Selection Outputs
          .do_out(adc_reg),             // Data out
          .drdy_out(drdy),              // Data ready
          .eoc_out(enable),             // End of Conversion Signal
          .eos_out(),                   // End of Sequence Signal
          .alarm_out(),                 // OR'ed output of all the Alarms    
          .vp_in(vp_in),                // Dedicated Analog Input Pair
          .vn_in(vn_in));   

   
   /////////////////////////////////////////////////////////////////////////////
   // adc
         
   assign enable = 1'b1;
   
   // body
   // output buffer
   always_ff @(posedge CLK_I, posedge RST_I)
     if (RST_I)
       begin
          ack_reg <= 0;
       end
     else
       begin
          ack_reg <= CYC_I && STB_I;
       end
   
   assign rd_en = CYC_I && STB_I && !WE_I;
   
   // slot read interface
   assign DAT_O = rd_en ?
      {16'h0000, adc_reg} : 
      32'b0;
    
   assign ACK_O = ack_reg;

endmodule // dev_adc

`end_keywords
