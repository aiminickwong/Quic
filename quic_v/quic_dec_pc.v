`include "timescale.v"
`include "defines.v"

module quic_dec_pc(
input clk,reset_n,
input full,
input [2:0] wewait_flag,
input [2:0] quic_dec_state,
input [2:0] header_state,
input [3:0] decode_state,
input [5:0] golomb_len,
input [4:0] run_len,

output [31:0] pc,
output reg [31:0] pc_delta,pc_reg
);


reg [31:0] wait_len; 
always@(reset_n or header_state or decode_state or golomb_len or run_len or full or wait_len or quic_dec_state)
	if(reset_n == 0)
		pc_delta = 0;
	else if(quic_dec_state == `quic_dec_set)
	  pc_delta = 0;	
	else if(header_state != `rst_header_state )
		pc_delta = full ? 32'd32 : 32'd0;
	else if(decode_state == `decode_golomb_r || 
		decode_state == `decode_golomb_g || 
		decode_state == `decode_golomb_b )
		pc_delta = full ? {26'd0,golomb_len} : 32'd0;
	else if(decode_state == `decode_run || decode_state == `decode_len)
		pc_delta = full ? {27'd0,run_len} : 32'd0;
	else if(decode_state == `decode_wewait && full )
		pc_delta = wait_len;
	else 
		pc_delta = 0;


always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		wait_len <= 0;
	else if(quic_dec_state == `quic_dec_set)
		wait_len <= 0;	
	else if((decode_state == `decode_golomb_r || 
		decode_state == `decode_golomb_g || 
		decode_state == `decode_golomb_b ) && full == 0)
		wait_len <= {26'd0,golomb_len};
	else if(decode_state == `decode_run || decode_state == `decode_len)
		wait_len <= {27'd0,run_len};
	
		
assign pc = full ? pc_reg + pc_delta : pc_reg; 	


always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		pc_reg <= 0;
	else if(quic_dec_state == `quic_dec_set)
		pc_reg <= 0;	
	else 	pc_reg <= pc;	

	
endmodule
