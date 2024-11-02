/*
* SPDX-FileCopyrightText: 2024 Harald Pretl
* Johannes Kepler University, Institute for Integrated Circuits
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
* SPDX-License-Identifier: Apache-2.0
*
* TB for freely programmable logic block with optional feedback
*/

`timescale 10ns/1ns
`include "minilogix1.v"

module minilogix1_tb;

	reg	CLK;
	reg [2:0] INP;
	wire [1:0] OUT;
	reg LD_EN, LD_DAT, LD_CLK; 
	wire [2:0] DBG;

	minilogix1 #(.NIN(3), .NOUT(2)) dut(
		.clk(CLK),
		.i_input(INP),
		.o_output(OUT),
		.i_load_en(LD_EN),
		.i_load_dat(LD_DAT),
		.i_load_clk(LD_CLK),
		.dbg_state(DBG)
	);

	initial begin
		INP = 3'b0;
		CLK = 1'b0;
	end

	//always #1 CLK = ~CLK;

	initial begin
     $dumpfile("minilogix1_tb.vcd");
     $dumpvars(0, minilogix1_tb);
	end

	integer i;
	localparam [17:0] LOAD_CFG = 18'b00_00_01_10_11_00_01_10_11; 

	initial begin
		// load the configuration
		LD_EN = 1'b1;
		for (i=0; i<18; i=i+1) begin
			LD_CLK = 0;
			LD_DAT = LOAD_CFG[17-i];
			#1 LD_CLK = 1;
			#1 LD_CLK = 0;
		end
		LD_EN = 1'b0;

		// test the output (inversion of input)
		#1 INP = 3'b000;
		#1 INP = 3'b001;
		#1 INP = 3'b010;
		#1 INP = 3'b111;
		#1 INP = 3'b100;
		#1 INP = 3'b101;
		#1 INP = 3'b110;
		#1 INP = 3'b111;
	end

endmodule // minilogix1_tb
