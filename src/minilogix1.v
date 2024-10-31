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
* Freely programmable logic block with optional feedback
*/

`default_nettype none
`ifndef __MINILOGIX1__
`define __MINILOGIX1__

module minilogix1 #(parameter NIN=8, NOUT=8) (
	input wire						clk,
	input wire [NIN-1:0]			i_input,
	output wire [NOUT-1:0]			o_output,
	input wire						i_load_en,
	input wire						i_load_clk,
	input wire						i_load_dat,
	output wire	[2:0]				dbg_state
);

	localparam NCFG = (NIN<NOUT) ? NIN : NOUT;

	reg [NOUT*(2**NIN)+NCFG-1:0]	ram_r;
	wire [NCFG-1:0]					input_sel_cfg_w;
	wire [NIN-1:0]					ram_sel_w;
	reg [NCFG-1:0]					feedback_r;

	// last word in RAM is the input configuration for controlling the input mux
	assign input_sel_cfg_w = ram_r[NOUT*(2**NIN)+NCFG-1 -: NCFG];

	// if the input selection bit is 0, then the input is taken; otherwise the
	// respective output is feed back
	genvar j;
	generate for(j=0; j<NCFG; j=j+1)
		begin: input_selection
			assign ram_sel_w[j] = input_sel_cfg_w[j] ? feedback_r[j] : i_input[j];
		end
	endgenerate

	assign o_output = ram_r[ram_sel_w*NOUT +: NOUT];

	// the feedback path is clocked, so that we can implement a state machine
	always @(posedge clk) begin
		feedback_r <= o_output[NCFG-1:0];
	end

	genvar k;
	generate for(k=0; k<NOUT*(2**NIN)+NCFG-1; k=k+1)
	begin: load_ram
		always @(posedge i_load_clk) begin
			if (i_load_en) begin
				ram_r[0] <= i_load_dat;
				ram_r[k+1] <= ram_r[k];
			end
		end
	end
	endgenerate

	// we can somewhat monitor the feedback register here
	assign dbg_state[0] = |feedback_r;
	assign dbg_state[1] = &feedback_r;
	assign dbg_state[2] = ^feedback_r;

endmodule // minilogix1

`endif
`default_nettype wire
