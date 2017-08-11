`include "timescale.v"
`include "defines.v"

module quic_dec_ini(
input clk,reset_n,
input [2:0] bestcode,
input [2:0] quic_dec_state,
input [2:0] wmidx,


output [31:0] nGRcodewords_i, 
output [31:0] notGRcwlen_i, 
output [31:0] notGRprefixmask_i,
output [31:0] notGRsuffixlen_i,

output [31:0] nGRcodewords_0,nGRcodewords_1,nGRcodewords_2,nGRcodewords_3,
output [31:0] nGRcodewords_4,nGRcodewords_5,nGRcodewords_6,nGRcodewords_7,
output [31:0] notGRcwlen_0,notGRcwlen_1,notGRcwlen_2,notGRcwlen_3,
output [31:0] notGRcwlen_4,notGRcwlen_5,notGRcwlen_6,notGRcwlen_7,
output [15:0] wm_trigger


);

reg [31:0] nGRcodewords 	[7:0] ;
reg [31:0] notGRcwlen   	[7:0] ;
reg [31:0] notGRprefixmask [7:0] ;
reg [31:0] notGRsuffixlen  [7:0] ;

reg [15:0] wm_trigger_reg [7:0];
assign wm_trigger = wm_trigger_reg[wmidx];



assign nGRcodewords_i = nGRcodewords[bestcode];
assign notGRcwlen_i = notGRcwlen[bestcode];
assign notGRprefixmask_i = notGRprefixmask[bestcode];
assign notGRsuffixlen_i = notGRsuffixlen[bestcode];

assign nGRcodewords_0 = nGRcodewords[0];
assign nGRcodewords_1 = nGRcodewords[1];
assign nGRcodewords_2 = nGRcodewords[2];
assign nGRcodewords_3 = nGRcodewords[3];
assign nGRcodewords_4 = nGRcodewords[4];
assign nGRcodewords_5 = nGRcodewords[5];
assign nGRcodewords_6 = nGRcodewords[6];
assign nGRcodewords_7 = nGRcodewords[7];
assign notGRcwlen_0 = notGRcwlen[0];
assign notGRcwlen_1 = notGRcwlen[1];
assign notGRcwlen_2 = notGRcwlen[2];
assign notGRcwlen_3 = notGRcwlen[3];
assign notGRcwlen_4 = notGRcwlen[4];
assign notGRcwlen_5 = notGRcwlen[5];
assign notGRcwlen_6 = notGRcwlen[6];
assign notGRcwlen_7 = notGRcwlen[7];

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		nGRcodewords[0] <= 0;	nGRcodewords[1] <= 0;
		nGRcodewords[2] <= 0;	nGRcodewords[3] <= 0;
		nGRcodewords[4] <= 0;	nGRcodewords[5] <= 0;
		nGRcodewords[6] <= 0;	nGRcodewords[7] <= 0;
		notGRcwlen[0] <= 0;	notGRcwlen[1] <= 0;
		notGRcwlen[2] <= 0;	notGRcwlen[3] <= 0;
		notGRcwlen[4] <= 0;	notGRcwlen[5] <= 0;
		notGRcwlen[6] <= 0;	notGRcwlen[7] <= 0;
		notGRprefixmask[0] <= 0;	notGRprefixmask[1] <= 0;
		notGRprefixmask[2] <= 0;	notGRprefixmask[3] <= 0;
		notGRprefixmask[4] <= 0;	notGRprefixmask[5] <= 0;
		notGRprefixmask[6] <= 0;	notGRprefixmask[7] <= 0;
		notGRsuffixlen[0] <= 0;	notGRsuffixlen[1] <= 0;
		notGRsuffixlen[2] <= 0;	notGRsuffixlen[3] <= 0;
		notGRsuffixlen[4] <= 0;	notGRsuffixlen[5] <= 0;
		notGRsuffixlen[6] <= 0;	notGRsuffixlen[7] <= 0;
		wm_trigger_reg[0] <= 0;	wm_trigger_reg[1] <= 0;
		wm_trigger_reg[2] <= 0;	wm_trigger_reg[3] <= 0;
		wm_trigger_reg[4] <= 0; wm_trigger_reg[5] <= 0;
		wm_trigger_reg[6] <= 0; wm_trigger_reg[7] <= 0;end
	else if(quic_dec_state == `quic_dec_set)begin
		nGRcodewords[0] <= 0;	nGRcodewords[1] <= 0;
		nGRcodewords[2] <= 0;	nGRcodewords[3] <= 0;
		nGRcodewords[4] <= 0;	nGRcodewords[5] <= 0;
		nGRcodewords[6] <= 0;	nGRcodewords[7] <= 0;
		notGRcwlen[0] <= 0;	notGRcwlen[1] <= 0;
		notGRcwlen[2] <= 0;	notGRcwlen[3] <= 0;
		notGRcwlen[4] <= 0;	notGRcwlen[5] <= 0;
		notGRcwlen[6] <= 0;	notGRcwlen[7] <= 0;
		notGRprefixmask[0] <= 0;	notGRprefixmask[1] <= 0;
		notGRprefixmask[2] <= 0;	notGRprefixmask[3] <= 0;
		notGRprefixmask[4] <= 0;	notGRprefixmask[5] <= 0;
		notGRprefixmask[6] <= 0;	notGRprefixmask[7] <= 0;
		notGRsuffixlen[0] <= 0;	notGRsuffixlen[1] <= 0;
		notGRsuffixlen[2] <= 0;	notGRsuffixlen[3] <= 0;
		notGRsuffixlen[4] <= 0;	notGRsuffixlen[5] <= 0;
		notGRsuffixlen[6] <= 0;	notGRsuffixlen[7] <= 0;
		wm_trigger_reg[0] <= 0;	wm_trigger_reg[1] <= 0;
		wm_trigger_reg[2] <= 0;	wm_trigger_reg[3] <= 0;
		wm_trigger_reg[4] <= 0; wm_trigger_reg[5] <= 0;
		wm_trigger_reg[6] <= 0; wm_trigger_reg[7] <= 0;end	
	else if(quic_dec_state == `quic_dec_init)begin
		nGRcodewords[0] <= 32'h12;	nGRcodewords[1] <= 32'h24;
		nGRcodewords[2] <= 32'h48;	nGRcodewords[3] <= 32'h90;
		nGRcodewords[4] <= 32'hf0;	nGRcodewords[5] <= 32'he0;
		nGRcodewords[6] <= 32'hc0;	nGRcodewords[7] <= 32'h80;
		notGRcwlen[0] <= 32'h1a;	notGRcwlen[1] <= 32'h1a;
		notGRcwlen[2] <= 32'h1a;	notGRcwlen[3] <= 32'h19;
		notGRcwlen[4] <= 32'h13;	notGRcwlen[5] <= 32'hc;
		notGRcwlen[6] <= 32'h9;		notGRcwlen[7] <= 32'h8;
		notGRprefixmask[0] <= 32'h3fff;	notGRprefixmask[1] <= 32'h3fff;
		notGRprefixmask[2] <= 32'h3fff;	notGRprefixmask[3] <= 32'h3fff;
		notGRprefixmask[4] <= 32'h1ffff;	notGRprefixmask[5] <= 32'h1ffffff;
		notGRprefixmask[6] <= 32'h1fffffff;	notGRprefixmask[7] <= 32'h7fffffff;
		notGRsuffixlen[0] <= 32'h8;	notGRsuffixlen[1] <= 32'h8;
		notGRsuffixlen[2] <= 32'h8;	notGRsuffixlen[3] <= 32'h7;
		notGRsuffixlen[4] <= 32'h4;	notGRsuffixlen[5] <= 32'h5;
		notGRsuffixlen[6] <= 32'h6;	notGRsuffixlen[7] <= 32'h7;
		wm_trigger_reg[0] <= 16'd110;	wm_trigger_reg[1] <= 16'd550;
		wm_trigger_reg[2] <= 16'd900;	wm_trigger_reg[3] <= 16'd800;
		wm_trigger_reg[4] <= 16'd550; 	wm_trigger_reg[5] <= 16'd400;
		wm_trigger_reg[6] <= 16'd350; 	wm_trigger_reg[7] <= 16'd250;
		end
		




endmodule
