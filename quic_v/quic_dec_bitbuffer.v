`include "timescale.v"
`include "defines.v"

module quic_dec_bitbuffer(
input clk,reset_n,
input last_word,
input [2:0] quic_dec_state,
input [31:0] bitstream_input,
input we,
input [31:0] pc,pc_delta,pc_reg,

output reg [31:0] bitstream_output,
output next,full

);
reg [127:0] buffer;
reg [1:0] rst_cnt,cnt;

reg last_word_reg;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		last_word_reg <= 0;
	else if(quic_dec_state == `quic_dec_set)
		last_word_reg <= 0;
	else if(last_word)
		last_word_reg <= 1;
	
	
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		rst_cnt <= 2'd0;
	else if(quic_dec_state == `quic_dec_set)
		rst_cnt <= 2'd0;
	else if(rst_cnt < 2'd3 && we && next)
		rst_cnt <= rst_cnt + 2'd1;
		
		

		
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		cnt <= 2'd0;
	else if(quic_dec_state == `quic_dec_set)
		cnt <= 2'd0;	
	else if((we || last_word_reg) && next)
		cnt <= cnt + 2'd1;

assign full = rst_cnt == 2'd3 && ((pc_reg[6:5] == 2'b00 && (cnt == 3)) ||
				(pc_reg[6:5] == 2'b01 && (cnt == 0)) ||
				(pc_reg[6:5] == 2'b10 && (cnt == 1)) ||
				(pc_reg[6:5] == 2'b11 && (cnt == 2)) 
);

assign next = (rst_cnt < 2'd3) ||
				(pc[6:5] == 2'b00 && cnt == 2'd2) ||
				  (pc[6:5] == 2'b01 && cnt == 2'd3) ||
				  (pc[6:5] == 2'b10 && cnt == 2'd0) ||
				  (pc[6:5] == 2'b11 && cnt == 2'd1);
				  
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		buffer <= 0;
	else if(quic_dec_state == `quic_dec_set)
		buffer <= 0;
	else if(we && next)
		case(cnt)
		0:	buffer[127:96] <= {bitstream_input[7:0],bitstream_input[15:8],bitstream_input[23:16],bitstream_input[31:24]};
		1:	buffer[95:64]  <= {bitstream_input[7:0],bitstream_input[15:8],bitstream_input[23:16],bitstream_input[31:24]};
		2:	buffer[63:32]  <= {bitstream_input[7:0],bitstream_input[15:8],bitstream_input[23:16],bitstream_input[31:24]};
		3:	buffer[31:0]   <= {bitstream_input[7:0],bitstream_input[15:8],bitstream_input[23:16],bitstream_input[31:24]};
		default:;
		endcase
	else if(last_word_reg && next)
		case(cnt)
		0:	buffer[127:96] <= 32'd0;
		1:	buffer[95:64]  <= 32'd0;
		2:	buffer[63:32]  <= 32'd0;
		3:	buffer[31:0]   <= 32'd0;
		default:;
		endcase

wire [159:0] buff;
assign buff = {buffer,buffer[127:96]};

always@(posedge clk or negedge reset_n)
	if (reset_n == 0)
		bitstream_output <= 0;
	else if(quic_dec_state == `quic_dec_set)
		bitstream_output <= 0;	
	else
		bitstream_output <= buff[(159 - pc[6:0])  -: 32];
		
endmodule
