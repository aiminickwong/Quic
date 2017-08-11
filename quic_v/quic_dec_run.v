`include "timescale.v"
`include "defines.v"

module quic_dec_run(
input clk,reset_n,
input [3:0] decode_state,
input [2:0] quic_dec_state,
input [31:0] bitstream_output,


output [4:0] hit_temp,
output [4:0] run_len,

output reg [15:0] run_i,
output [15:0] run_i_tmp
);

wire [15:0] melcorder;
reg [4:0] melstate;
reg [3:0] melclen;
reg [4:0] cntlones;
wire [31:0] run_clen;

assign run_len = decode_state == `decode_run ? cntlones + 5'd1 : 
					  decode_state == `decode_len && melclen != 0 ? {1'd0,melclen} : 5'd0;
					  
assign hit_temp = decode_state == `decode_run ? cntlones : 5'd0;

assign run_i_tmp = decode_state == `decode_len && melclen != 0 ? run_i + run_clen[15:0] : 
			decode_state == `decode_len ? run_i : 16'd0;
	
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		melstate <= 0;
	else if(quic_dec_state == `quic_dec_set)
		melstate <= 0;	
	else if(quic_dec_state == `quic_dec_init)
		melstate <= 0;
	else if(decode_state == `decode_hit && melstate < 5'd31)
		melstate <= melstate + 5'd1;
	else if(decode_state == `decode_len && melstate != 0)
		melstate <= melstate - 5'd1;

wire [4:0] melstate_m16;
assign melstate_m16 = melstate - 5'd16;
		
always@(melstate or melstate_m16)
	case(melstate)
	0,1,2,3:			melclen = 0;
	4,5,6,7:			melclen = 1;
	8,9,10,11:		melclen = 2;
	12,13,14,15:	melclen = 3;
	16,17:			melclen = 4;
	18,19:			melclen = 5;
	20,21:			melclen = 6;
	22,23:			melclen = 7;
	default:			melclen = melstate_m16[3:0];
	endcase

assign melcorder = 16'd1 << melclen;


assign run_clen = (bitstream_output >> (6'd32 - {2'b0,melclen} ) );
	
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		run_i <= 0;
	else if(quic_dec_state == `quic_dec_set)
		run_i <= 0;	
	else if(decode_state == `decode_run)
		run_i <= 0;
	else if(decode_state == `decode_hit)
		run_i <= run_i + melcorder;
	else if(decode_state == `decode_len && melclen != 0)
		run_i <= run_i + run_clen[15:0];


always@(bitstream_output)
	if(bitstream_output[31] == 0)
		cntlones = 0;
	else if(bitstream_output[30] == 0)
		cntlones = 5'd1;
	else if(bitstream_output[29] == 0)
		cntlones = 5'd2;
	else if(bitstream_output[28] == 0)
		cntlones = 5'd3;
	else if(bitstream_output[27] == 0)
		cntlones = 5'd4;
	else if(bitstream_output[26] == 0)
		cntlones = 5'd5;
	else if(bitstream_output[25] == 0)
		cntlones = 5'd6;
	else if(bitstream_output[24] == 0)
		cntlones = 5'd7;
	else if(bitstream_output[23] == 0)
		cntlones = 5'd8;
	else if(bitstream_output[22] == 0)
		cntlones = 5'd9;
	else if(bitstream_output[21] == 0)
		cntlones = 5'd10;
	else if(bitstream_output[20] == 0)
		cntlones = 5'd11;
	else if(bitstream_output[19] == 0)
		cntlones = 5'd12;
	else if(bitstream_output[18] == 0)
		cntlones = 5'd13;
	else if(bitstream_output[17] == 0)
		cntlones = 5'd14;
	else if(bitstream_output[16] == 0)
		cntlones = 5'd15;
	else if(bitstream_output[15] == 0)
		cntlones = 5'd16;
	else if(bitstream_output[14] == 0)
		cntlones = 5'd17;
	else if(bitstream_output[13] == 0)
		cntlones = 5'd18;
	else if(bitstream_output[12] == 0)
		cntlones = 5'd19;
	else if(bitstream_output[11] == 0)
		cntlones = 5'd20;
	else if(bitstream_output[10] == 0)
		cntlones = 5'd21;
	else if(bitstream_output[9] == 0)
		cntlones = 5'd22;
	else if(bitstream_output[8] == 0)
		cntlones = 5'd23;
	else if(bitstream_output[7] == 0)
		cntlones = 5'd24;
	else if(bitstream_output[6] == 0)
		cntlones = 5'd25;
	else if(bitstream_output[5] == 0)
		cntlones = 5'd26;
	else if(bitstream_output[4] == 0)
		cntlones = 5'd27;
	else if(bitstream_output[3] == 0)
		cntlones = 5'd28;
	else if(bitstream_output[2] == 0)
		cntlones = 5'd29;
	else if(bitstream_output[1] == 0)
		cntlones = 5'd30;
	else 
		cntlones = 5'd31;




	
endmodule
