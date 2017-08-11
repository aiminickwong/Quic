`include "timescale.v"
`include "defines.v"

module quic_dec_head(
input clk,reset_n,
input [31:0] bitstream_output,
input [2:0] quic_dec_state,
input [2:0] header_state,

output [31:0] quic,
output [31:0] version,
output [7:0] type_4,
output [15:0] width,height

);


reg [31:0] quic_reg;
assign quic = header_state == `header_quic ? bitstream_output: quic_reg;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		quic_reg <= 0;
	else if(quic_dec_state == `quic_dec_set)
		quic_reg <= 0;
	else if(header_state == `header_quic)
		quic_reg <= quic;

reg [31:0] version_reg;
assign version = header_state == `header_version ? bitstream_output : version_reg;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		version_reg <= 0;
	else if(quic_dec_state == `quic_dec_set)
		version_reg <= 0;	
	else if(header_state == `header_version)
		version_reg <= version;

reg [7:0] type_reg;
assign type_4 = header_state == `header_type ? bitstream_output[7:0] : type_reg;


always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		type_reg <= 0;
	else if(quic_dec_state == `quic_dec_set)
		type_reg <= 0;	
	else if(header_state == `header_type)
		type_reg <= type_4;

		
		
reg [15:0] width_reg,height_reg;
assign width = header_state == `header_width ? bitstream_output[15:0] : width_reg;
assign height = header_state == `header_height ? bitstream_output[15:0] : height_reg;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		width_reg <= 0;	height_reg <= 0;end
	else if(quic_dec_state == `quic_dec_set)begin
		width_reg <= 0;	height_reg <= 0;end
	else if(header_state == `header_width)
		width_reg <= width;	
	else if(header_state == `header_height)
		height_reg <= height;
		

endmodule
