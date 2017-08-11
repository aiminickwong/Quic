`include "timescale.v"
`include "defines.v"

module quic_dec_golomb(
input clk,reset_n,
input [31:0] bitstream_output,
input [3:0] decode_state,
input [2:0] bestcode,

input [31:0] nGRcodewords_i, 
input [31:0] notGRcwlen_i, 
input [31:0] notGRprefixmask_i,
input [31:0] notGRsuffixlen_i,

output [7:0] golomb_output,
output reg [5:0] golomb_len

);

reg [4:0] cntlzeroes;
reg [31:0] golomb_output_gr,golomb_output_ngr;

assign golomb_output = (decode_state == `decode_golomb_r || decode_state == `decode_golomb_g ||
								decode_state == `decode_golomb_b) ? 
				((bitstream_output > notGRprefixmask_i) ? golomb_output_gr[7:0] : golomb_output_ngr[7:0])  : 8'd0;

		
always@(reset_n or decode_state or bitstream_output or notGRprefixmask_i or notGRcwlen_i or bestcode or cntlzeroes)
	if(reset_n == 0)
		golomb_len = 0;
	else if(decode_state == `decode_golomb_r || decode_state == `decode_golomb_g ||
			  decode_state == `decode_golomb_b)begin
		if(bitstream_output > notGRprefixmask_i)
			golomb_len = {1'd0,cntlzeroes} + {3'd0,bestcode} + 6'd1;
		else 
			golomb_len = notGRcwlen_i[5:0];
	end
	else 
		golomb_len = 0;



wire [8:0] bppmask_gr,bppmask_ngr;
assign bppmask_gr = (9'd1 << bestcode) - 9'd1;
assign bppmask_ngr = (9'd1 << notGRsuffixlen_i[3:0]) - 9'd1;


always@(reset_n or cntlzeroes or bestcode or bitstream_output or golomb_len or bppmask_gr)
	if(reset_n == 0)
		golomb_output_gr = 0;
	else 
		golomb_output_gr = ({27'd0,cntlzeroes} << bestcode) | 
				((bitstream_output >> (6'd32 - golomb_len)) & {24'd0,bppmask_gr[7:0]});
				
always@(reset_n or nGRcodewords_i or bitstream_output or notGRcwlen_i or bppmask_ngr)
	if(reset_n == 0)
		golomb_output_ngr = 0;
	else 
		golomb_output_ngr = nGRcodewords_i + 
				((bitstream_output) >> (6'd32-notGRcwlen_i[5:0]) & {23'd0,bppmask_ngr});






always@(bitstream_output)
	if(bitstream_output[31] == 1)
		cntlzeroes = 0;
	else if(bitstream_output[30] == 1)
		cntlzeroes = 5'd1;
	else if(bitstream_output[29] == 1)
		cntlzeroes = 5'd2;
	else if(bitstream_output[28] == 1)
		cntlzeroes = 5'd3;
	else if(bitstream_output[27] == 1)
		cntlzeroes = 5'd4;
	else if(bitstream_output[26] == 1)
		cntlzeroes = 5'd5;
	else if(bitstream_output[25] == 1)
		cntlzeroes = 5'd6;
	else if(bitstream_output[24] == 1)
		cntlzeroes = 5'd7;
	else if(bitstream_output[23] == 1)
		cntlzeroes = 5'd8;
	else if(bitstream_output[22] == 1)
		cntlzeroes = 5'd9;
	else if(bitstream_output[21] == 1)
		cntlzeroes = 5'd10;
	else if(bitstream_output[20] == 1)
		cntlzeroes = 5'd11;
	else if(bitstream_output[19] == 1)
		cntlzeroes = 5'd12;
	else if(bitstream_output[18] == 1)
		cntlzeroes = 5'd13;
	else if(bitstream_output[17] == 1)
		cntlzeroes = 5'd14;
	else if(bitstream_output[16] == 1)
		cntlzeroes = 5'd15;
	else if(bitstream_output[15] == 1)
		cntlzeroes = 5'd16;
	else if(bitstream_output[14] == 1)
		cntlzeroes = 5'd17;
	else 
		cntlzeroes = 0;
		


endmodule

