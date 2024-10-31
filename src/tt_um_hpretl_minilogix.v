/*
 * Copyright (c) 2024 Harald Pretl, IIC@JKU
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`include "minilogix1.v"

module tt_um_hpretl_minilogix (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  assign uio_oe = 8'b0000000;  // using IO for input
  
  minilogix1 #(.NIN(8), .NOUT(8)) logix (
    .clk(clk),
    .i_input(ui_in),
    .o_output(uo_out),
    .i_load_en(uio_in[0]),
    .i_load_clk(uio_in[1]),
    .i_load_dat(uio_in[2])
  );

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out[7:0] = 8'b000;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, rst_n, uio_in[7:3], 1'b0};

endmodule // tt_um_hpretl_minilogix
