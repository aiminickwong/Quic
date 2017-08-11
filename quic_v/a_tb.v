`include "timescale.v"
`include "defines.v"

module a_tb();

reg clk,reset_n; 
wire [31:0] bitstream_input;
wire [31:0] pc;
wire [7:0] pix_r,pix_g,pix_b;
wire [15:0] row_o,column_o;
wire [15:0] width,height;
wire quic_dec_header_end;
wire pix_end,decode_end;
wire next;
reg [31:0] pc_count;
wire last_word;
reg [0:127] mem [0:200000];
reg [0:25600000] BS_buffer;
integer i;


initial begin

  $readmemh("dat/file6.dat",mem);
  for(i=0;i<32'd200000;i=i+1)
    BS_buffer[128*i +: 128] <= mem[i];
 
end 

wire we;
reg [7:0] wait_cnt;

`define we_n 4
`define rd_n 10

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		wait_cnt <= 8'd0;
	else if(wait_cnt < `we_n)
		wait_cnt <= wait_cnt + 8'd1;
	else if(we && next)
		wait_cnt <= 8'd0;

reg [15:0] again_cnt;
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		again_cnt <= 16'd100;
	else if(decode_end)	
		again_cnt <= 16'd0;
	else if(again_cnt != 16'd100)
		again_cnt <= again_cnt + 16'd1;	


assign we = pc_count != 32'h00030042 && again_cnt == 16'd100;//wait_cnt == `we_n;

wire rd;
reg [7:0] rd_cnt;
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		rd_cnt <= 0;
	else if(rd_cnt < `rd_n)
		rd_cnt <= rd_cnt + 8'd1;
	else if(pix_end && rd)
		rd_cnt <= 8'd0;
	
assign rd = 1;//rd_cnt == `rd_n;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		pc_count <= 32'h0;
	else if(again_cnt == 16'd90)
		pc_count <= 0;	
	else if(next && we)
		pc_count <= pc_count + 1;

 
assign		bitstream_input = BS_buffer[(pc_count*32) +: 32];

initial begin
	clk = 1'b1;
	reset_n = 1'b1;
	
	#100 reset_n = 1'b0;
	#100 reset_n = 1'b1;
	
	end

	
always begin
	#50 clk = ~clk;
       end	
       

	   

assign last_word = pc_count== 32'h00030041;
 
		 
integer file;
wire [15:0] bpp;
assign bpp = 16'd255;


reg decode_end_reg;
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		decode_end_reg <= 0;
	else if(quic_dec_header_end)
		decode_end_reg <= 0;
	else if(decode_end)
		decode_end_reg <= 1;
		
reg bbb;
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		bbb <= 0;
	else if(again_cnt == 16'd90)	
		bbb <= 1;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		file = $fopen("aaa.pgm","w");
		$fdisplay (file,"%s","P3");
	end
	else if(quic_dec_header_end)begin
		$fdisplay (file,"%d%d",width,height);	
		$fdisplay (file,"%s","#spicec dump");
		$fdisplay (file,"%d",bpp);end
	else if(pix_end && rd)begin
		$fdisplay (file,"%d",pix_r);		
		$fdisplay (file,"%d",pix_g);	
		$fdisplay (file,"%d",pix_b);	
		if(decode_end || decode_end_reg)
			$fclose(file);
	end
	else if(again_cnt == 16'd90 && bbb == 0)begin
		file = $fopen("bbb.pgm","w");
		$fdisplay (file,"%s","P3");
	end
		



quic_dec quic_dec(
	.clk(clk),.reset_n(reset_n),
	.bitstream_input(bitstream_input),
	.last_word(last_word),
	.pix_r(pix_r),.pix_g(pix_g),
	.pix_b(pix_b),
	.we(we),.next(next),.rd(rd),
	.row_o(row_o),.column_o(column_o),
	.width(width),.height(height),
	.quic_dec_header_end(quic_dec_header_end),
	.pix_end(pix_end),.decode_end(decode_end)
);		
	
	
endmodule
