`include "timescale.v"
`include "defines.v"

module quic_dec_updat(
input clk,reset_n,
input [2:0] quic_dec_state,
input [3:0] decode_state,
input [2:0] updat_state,
input [7:0] golomb_output,
input [31:0] nGRcodewords_0,nGRcodewords_1,nGRcodewords_2,nGRcodewords_3,
input [31:0] nGRcodewords_4,nGRcodewords_5,nGRcodewords_6,nGRcodewords_7,
input [31:0] notGRcwlen_0,notGRcwlen_1,notGRcwlen_2,notGRcwlen_3,
input [31:0] notGRcwlen_4,notGRcwlen_5,notGRcwlen_6,notGRcwlen_7,
input [15:0] row,column,
input [15:0] column_pred,row_pred,
input [15:0] width,height,
input [15:0] wm_trigger,

output reg [7:0] context_cur_r,context_cur_g,
output reg [7:0] context_cur_b,
output reg [2:0] bestcode,wmidx,
output reg [7:0] jump_count
);


reg [2:0] bestcode_r_ram [7:0];
reg [15:0] pcounters_r_0 [7:0];
reg [15:0] pcounters_r_1 [7:0];
reg [15:0] pcounters_r_2 [7:0];
reg [15:0] pcounters_r_3 [7:0];
reg [15:0] pcounters_r_4 [7:0];
reg [15:0] pcounters_r_5 [7:0];
reg [15:0] pcounters_r_6 [7:0];
reg [15:0] pcounters_r_7 [7:0];


reg [2:0] bestcode_g_ram [7:0];
reg [15:0] pcounters_g_0 [7:0];
reg [15:0] pcounters_g_1 [7:0];
reg [15:0] pcounters_g_2 [7:0];
reg [15:0] pcounters_g_3 [7:0];
reg [15:0] pcounters_g_4 [7:0];
reg [15:0] pcounters_g_5 [7:0];
reg [15:0] pcounters_g_6 [7:0];
reg [15:0] pcounters_g_7 [7:0];


reg [2:0] bestcode_b_ram [7:0];
reg [15:0] pcounters_b_0 [7:0];
reg [15:0] pcounters_b_1 [7:0];
reg [15:0] pcounters_b_2 [7:0];
reg [15:0] pcounters_b_3 [7:0];
reg [15:0] pcounters_b_4 [7:0];
reg [15:0] pcounters_b_5 [7:0];
reg [15:0] pcounters_b_6 [7:0];
reg [15:0] pcounters_b_7 [7:0];


reg [7:0] context_above_r;
reg [7:0] context_above_g;
reg [7:0] context_above_b;


reg [2:0] pbidx_cur_r,pbidx_last_r,pbidx_above_r;
reg [2:0] pbidx_cur_g,pbidx_last_g,pbidx_above_g;
reg [2:0] pbidx_cur_b,pbidx_last_b,pbidx_above_b;


reg [2:0] bestcode_r;
reg [2:0] bestcode_g;
reg [2:0] bestcode_b;

wire [7:0] context_cur_r_tmp,context_cur_g_tmp,context_cur_b_tmp;

always@(reset_n or decode_state or bestcode_r or bestcode_g or bestcode_b or bestcode_r or quic_dec_state)
	if(reset_n == 0)
		bestcode = 0;
	else if(quic_dec_state == `quic_dec_set)
		bestcode = 0;	
	else if(decode_state == `decode_golomb_r)
		bestcode = bestcode_r;
	else if(decode_state == `decode_golomb_g)
		bestcode = bestcode_g;
	else if(decode_state == `decode_golomb_b)
		bestcode = bestcode_b;
	else
		bestcode = 0;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		bestcode_r <= 0;
	else if(quic_dec_state == `quic_dec_set)
		bestcode_r <= 0;	
	else if(decode_state == `rst_decode_state && column == 0)
		bestcode_r <= bestcode_r_ram[pbidx_above_r];
	else if(decode_state == `rst_decode_state)	
		bestcode_r <= bestcode_r_ram[pbidx_cur_r];
		
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		bestcode_g <= 0;
	else if(quic_dec_state == `quic_dec_set)
		bestcode_g <= 0;		
	else if(decode_state == `rst_decode_state && column == 0)
		bestcode_g <= bestcode_g_ram[pbidx_above_g];
	else if(decode_state == `rst_decode_state)	
		bestcode_g <= bestcode_g_ram[pbidx_cur_g];

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		bestcode_b <= 0;
	else if(quic_dec_state == `quic_dec_set)
		bestcode_b <= 0;
	else if(decode_state == `rst_decode_state && column == 0)
		bestcode_b <= bestcode_b_ram[pbidx_above_b];
	else if(decode_state == `rst_decode_state)	
		bestcode_b <= bestcode_b_ram[pbidx_cur_b];




always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		context_above_r <= 0;
	else if(quic_dec_state == `quic_dec_set)
		context_above_r <= 0;	
	else if(decode_state == `decode_golomb_r && column == 0)
		context_above_r <= golomb_output;
		
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		context_above_g <= 0;
	else if(quic_dec_state == `quic_dec_set)
		context_above_g <= 0;			
	else if(decode_state == `decode_golomb_g && column == 0)
		context_above_g <= golomb_output;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		context_above_b <= 0;
	else if(quic_dec_state == `quic_dec_set)
		context_above_b <= 0;		
	else if(decode_state == `decode_golomb_b && column == 0)
		context_above_b <= golomb_output;
	
	

	
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		context_cur_r <= 0;
	else if(quic_dec_state == `quic_dec_set)
		context_cur_r <= 0;	
	else if(decode_state == `rst_decode_state && column == 0)
		context_cur_r <= context_above_r;
	else if(decode_state == `rst_decode_state)
		context_cur_r <= context_cur_r_tmp;
	else if(decode_state == `decode_golomb_r)
		context_cur_r <= golomb_output;
		
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		context_cur_g <= 0;
	else if(quic_dec_state == `quic_dec_set)
		context_cur_g <= 0;	
	else if(decode_state == `rst_decode_state && column == 0)
		context_cur_g <= context_above_g;
	else if(decode_state == `rst_decode_state)
		context_cur_g <= context_cur_g_tmp;
	else if(decode_state == `decode_golomb_g)
		context_cur_g <= golomb_output;		
		
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		context_cur_b <= 0;
	else if(quic_dec_state == `quic_dec_set)
		context_cur_b <= 0;		
	else if(decode_state == `rst_decode_state && column == 0)
		context_cur_b <= context_above_b;
	else if(decode_state == `rst_decode_state)
		context_cur_b <= context_cur_b_tmp;
	else if(decode_state == `decode_golomb_b)
		context_cur_b <= golomb_output;		


reg [11:0] context_wr_addr;
reg [11:0] context_r_addr_w,context_g_addr_w,context_b_addr_w;
reg [7:0] context_r_datain,context_g_datain,context_b_datain;
reg context_r_we,context_g_we,context_b_we;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		context_wr_addr <= 0;
	else if(quic_dec_state == `quic_dec_set)
		context_wr_addr <= 0;	
	else 
		context_wr_addr <= column[11:0];
		

		
    
   
always@(decode_state or context_wr_addr or golomb_output)
	if(decode_state == `decode_golomb_r)  begin
			context_r_we = 1;
		 	context_r_addr_w = context_wr_addr;
			context_r_datain = golomb_output;end
	else begin
			context_r_we = 0;
		 	context_r_addr_w = 0;
			context_r_datain = 0;	end
			
always@(decode_state or context_wr_addr or golomb_output)
	if(decode_state == `decode_golomb_g)  begin
			context_g_we = 1;
		 	context_g_addr_w = context_wr_addr;
			context_g_datain = golomb_output;end
	else begin
			context_g_we = 0;
		 	context_g_addr_w = 0;
			context_g_datain = 0;	end	
			
always@(decode_state or context_wr_addr or golomb_output)
	if(decode_state == `decode_golomb_b)  begin
			context_b_we = 1;
		 	context_b_addr_w = context_wr_addr;
			context_b_datain = golomb_output;end
	else begin
			context_b_we = 0;
		 	context_b_addr_w = 0;
			context_b_datain = 0;	end			
					
			
			
		
reg [7:0] context_last_r;
reg [7:0] context_last_g;
reg [7:0] context_last_b;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		context_last_r <= 0;
	else if(quic_dec_state == `quic_dec_set)
		context_last_r <= 0;	
	else if(decode_state == `decode_golomb_r)begin
		if(column == 0)
			context_last_r <= context_above_r;
		else	
			context_last_r <= context_cur_r;
	end

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		context_last_g <= 0;
	else if(quic_dec_state == `quic_dec_set)
		context_last_g <= 0;		
	else if(decode_state == `decode_golomb_g)begin
		if(column == 0)
			context_last_g <= context_above_g;
		else	
			context_last_g <= context_cur_g;
	end
	
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		context_last_b <= 0;
	else if(quic_dec_state == `quic_dec_set)
		context_last_b <= 0;
	else if(decode_state == `decode_golomb_b)begin
		if(column == 0)
			context_last_b <= context_above_b;
		else	
			context_last_b <= context_cur_b;
	end

wire [7:0] context_cur_r_t,context_cur_g_t,context_cur_b_t;
wire [11:0] context_rd_addr;
reg [11:0] context_rd_addr_reg;


dpram #(12,8)
	context_r_reg(
	// Generic synchronous double-port RAM interface
	.clk_a(clk), .rst_a(~reset_n), .ce_a(1'b1), .oe_a(1'b1), 
	.addr_a(context_rd_addr), .do_a(context_cur_r_tmp),
	.clk_b(clk), .rst_b(~reset_n), .ce_b(1'b1), .we_b(context_r_we), 
	.addr_b(context_r_addr_w), .di_b(context_r_datain)
);

dpram #(12,8)
	context_g_reg(
	// Generic synchronous double-port RAM interface
	.clk_a(clk), .rst_a(~reset_n), .ce_a(1'b1), .oe_a(1'b1), 
	.addr_a(context_rd_addr), .do_a(context_cur_g_tmp),
	.clk_b(clk), .rst_b(~reset_n), .ce_b(1'b1), .we_b(context_g_we), 
	.addr_b(context_g_addr_w), .di_b(context_g_datain)
);


dpram #(12,8)
	context_b_reg(
	// Generic synchronous double-port RAM interface
	.clk_a(clk), .rst_a(~reset_n), .ce_a(1'b1), .oe_a(1'b1), 
	.addr_a(context_rd_addr), .do_a(context_cur_b_tmp),
	.clk_b(clk), .rst_b(~reset_n), .ce_b(1'b1), .we_b(context_b_we), 
	.addr_b(context_b_addr_w), .di_b(context_b_datain)
);




always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		context_rd_addr_reg <= 0;
	/*else if(quic_dec_state == `quic_dec_set)	
		context_rd_addr_reg <= 0;*/
	else 
		context_rd_addr_reg <= context_rd_addr;


assign context_rd_addr = quic_dec_state == `quic_dec_set ? 0 : 
		(updat_state == `updat_updat  || decode_state == `decode_noupdat || decode_state == `decode_runupdat) ?
		column_pred[11:0] - 12'd1 : context_rd_addr_reg;



always@(context_cur_r_tmp)
	if(context_cur_r_tmp == 0)
		pbidx_cur_r = 0;
	else if(context_cur_r_tmp < 8'd3)
		pbidx_cur_r = 3'd1;
	else if(context_cur_r_tmp < 8'd7)
		pbidx_cur_r = 3'd2;
	else if(context_cur_r_tmp < 8'd15)
		pbidx_cur_r = 3'd3;
	else if(context_cur_r_tmp < 8'd31)
		pbidx_cur_r = 3'd4;
	else if(context_cur_r_tmp < 8'd63)
		pbidx_cur_r = 3'd5;
	else if(context_cur_r_tmp < 8'd127)
		pbidx_cur_r = 3'd6;
	else	pbidx_cur_r = 3'd7;
	
always@(context_cur_g_tmp)
	if(context_cur_g_tmp == 0)
		pbidx_cur_g = 0;
	else if(context_cur_g_tmp < 8'd3)
		pbidx_cur_g = 3'd1;
	else if(context_cur_g_tmp < 8'd7)
		pbidx_cur_g = 3'd2;
	else if(context_cur_g_tmp < 8'd15)
		pbidx_cur_g = 3'd3;
	else if(context_cur_g_tmp < 8'd31)
		pbidx_cur_g = 3'd4;
	else if(context_cur_g_tmp < 8'd63)
		pbidx_cur_g = 3'd5;
	else if(context_cur_g_tmp < 8'd127)
		pbidx_cur_g = 3'd6;
	else	pbidx_cur_g = 3'd7;
	
always@(context_cur_b_tmp)
	if(context_cur_b_tmp == 0)
		pbidx_cur_b = 0;
	else if(context_cur_b_tmp < 8'd3)
		pbidx_cur_b = 3'd1;
	else if(context_cur_b_tmp < 8'd7)
		pbidx_cur_b = 3'd2;
	else if(context_cur_b_tmp < 8'd15)
		pbidx_cur_b = 3'd3;
	else if(context_cur_b_tmp < 8'd31)
		pbidx_cur_b = 3'd4;
	else if(context_cur_b_tmp < 8'd63)
		pbidx_cur_b = 3'd5;
	else if(context_cur_b_tmp < 8'd127)
		pbidx_cur_b = 3'd6;
	else	pbidx_cur_b = 3'd7;	
	


	
	
always@(context_last_r)
	if(context_last_r == 0)
		pbidx_last_r = 0;
	else if(context_last_r < 8'd3)
		pbidx_last_r = 3'd1;
	else if(context_last_r < 8'd7)
		pbidx_last_r = 3'd2;
	else if(context_last_r < 8'd15)
		pbidx_last_r = 3'd3;
	else if(context_last_r < 8'd31)
		pbidx_last_r = 3'd4;
	else if(context_last_r < 8'd63)
		pbidx_last_r = 3'd5;
	else if(context_last_r < 8'd127)
		pbidx_last_r = 3'd6;
	else	pbidx_last_r = 3'd7;
	
always@(context_last_g)
	if(context_last_g == 0)
		pbidx_last_g = 0;
	else if(context_last_g < 8'd3)
		pbidx_last_g = 3'd1;
	else if(context_last_g < 8'd7)
		pbidx_last_g = 3'd2;
	else if(context_last_g < 8'd15)
		pbidx_last_g = 3'd3;
	else if(context_last_g < 8'd31)
		pbidx_last_g = 3'd4;
	else if(context_last_g < 8'd63)
		pbidx_last_g = 3'd5;
	else if(context_last_g < 8'd127)
		pbidx_last_g = 3'd6;
	else	pbidx_last_g = 3'd7;	
	
always@(context_last_b)
	if(context_last_b == 0)
		pbidx_last_b = 0;
	else if(context_last_b < 8'd3)
		pbidx_last_b = 3'd1;
	else if(context_last_b < 8'd7)
		pbidx_last_b = 3'd2;
	else if(context_last_b < 8'd15)
		pbidx_last_b = 3'd3;
	else if(context_last_b < 8'd31)
		pbidx_last_b = 3'd4;
	else if(context_last_b < 8'd63)
		pbidx_last_b = 3'd5;
	else if(context_last_b < 8'd127)
		pbidx_last_b = 3'd6;
	else	pbidx_last_b = 3'd7;	
	
	
	
	
	
	
always@(context_above_r)
	if(context_above_r == 0)
		pbidx_above_r = 0;
	else if(context_above_r < 8'd3)
		pbidx_above_r = 3'd1;
	else if(context_above_r < 8'd7)
		pbidx_above_r = 3'd2;
	else if(context_above_r < 8'd15)
		pbidx_above_r = 3'd3;
	else if(context_above_r < 8'd31)
		pbidx_above_r = 3'd4;
	else if(context_above_r < 8'd63)
		pbidx_above_r = 3'd5;
	else if(context_above_r < 8'd127)
		pbidx_above_r = 3'd6;
	else	pbidx_above_r = 3'd7;
	
always@(context_above_g)
	if(context_above_g == 0)
		pbidx_above_g = 0;
	else if(context_above_g < 8'd3)
		pbidx_above_g = 3'd1;
	else if(context_above_g < 8'd7)
		pbidx_above_g = 3'd2;
	else if(context_above_g < 8'd15)
		pbidx_above_g = 3'd3;
	else if(context_above_g < 8'd31)
		pbidx_above_g = 3'd4;
	else if(context_above_g < 8'd63)
		pbidx_above_g = 3'd5;
	else if(context_above_g < 8'd127)
		pbidx_above_g = 3'd6;
	else	pbidx_above_g = 3'd7;	

always@(context_above_b)
	if(context_above_b == 0)
		pbidx_above_b = 0;
	else if(context_above_b < 8'd3)
		pbidx_above_b = 3'd1;
	else if(context_above_b < 8'd7)
		pbidx_above_b = 3'd2;
	else if(context_above_b < 8'd15)
		pbidx_above_b = 3'd3;
	else if(context_above_b < 8'd31)
		pbidx_above_b = 3'd4;
	else if(context_above_b < 8'd63)
		pbidx_above_b = 3'd5;
	else if(context_above_b < 8'd127)
		pbidx_above_b = 3'd6;
	else	pbidx_above_b = 3'd7;
	


reg [2:0] pcounters_r_addr;
reg [2:0] pcounters_g_addr;
reg [2:0] pcounters_b_addr;


always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		pcounters_r_addr <= 0;	pcounters_g_addr <= 0;	
		pcounters_b_addr <= 0;	end
	else if(quic_dec_state == `quic_dec_set)begin
		pcounters_r_addr <= 0;	pcounters_g_addr <= 0;	
		pcounters_b_addr <= 0;	end
		
	else begin
		pcounters_r_addr <= pbidx_last_r;
		pcounters_g_addr <= pbidx_last_g;	
		pcounters_b_addr <= pbidx_last_b;	
		end
		
reg [15:0] ithcodelen_r_0,ithcodelen_r_1,ithcodelen_r_2,ithcodelen_r_3;
reg [15:0] ithcodelen_r_4,ithcodelen_r_5,ithcodelen_r_6,ithcodelen_r_7;
reg [15:0] ithcodelen_g_0,ithcodelen_g_1,ithcodelen_g_2,ithcodelen_g_3;
reg [15:0] ithcodelen_g_4,ithcodelen_g_5,ithcodelen_g_6,ithcodelen_g_7;
reg [15:0] ithcodelen_b_0,ithcodelen_b_1,ithcodelen_b_2,ithcodelen_b_3;
reg [15:0] ithcodelen_b_4,ithcodelen_b_5,ithcodelen_b_6,ithcodelen_b_7;

reg [15:0] GolombCodeLen_r_0,GolombCodeLen_r_1,GolombCodeLen_r_2,GolombCodeLen_r_3;
reg [15:0] GolombCodeLen_r_4,GolombCodeLen_r_5,GolombCodeLen_r_6,GolombCodeLen_r_7;
reg [15:0] GolombCodeLen_g_0,GolombCodeLen_g_1,GolombCodeLen_g_2,GolombCodeLen_g_3;
reg [15:0] GolombCodeLen_g_4,GolombCodeLen_g_5,GolombCodeLen_g_6,GolombCodeLen_g_7;
reg [15:0] GolombCodeLen_b_0,GolombCodeLen_b_1,GolombCodeLen_b_2,GolombCodeLen_b_3;
reg [15:0] GolombCodeLen_b_4,GolombCodeLen_b_5,GolombCodeLen_b_6,GolombCodeLen_b_7;


	
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		ithcodelen_r_0 <= 0;		ithcodelen_r_1 <= 0;	
		ithcodelen_r_2 <= 0;		ithcodelen_r_3 <= 0;	
		ithcodelen_r_4 <= 0;		ithcodelen_r_5 <= 0;	
		ithcodelen_r_6 <= 0;		ithcodelen_r_7 <= 0;		end
	else if(quic_dec_state == `quic_dec_set)begin
		ithcodelen_r_0 <= 0;		ithcodelen_r_1 <= 0;	
		ithcodelen_r_2 <= 0;		ithcodelen_r_3 <= 0;	
		ithcodelen_r_4 <= 0;		ithcodelen_r_5 <= 0;	
		ithcodelen_r_6 <= 0;		ithcodelen_r_7 <= 0;		end
		
	else if(updat_state == `rst_updat_state && decode_state == `decode_updat)begin
		ithcodelen_r_0 <= pcounters_r_0[pbidx_last_r] + GolombCodeLen_r_0;
		ithcodelen_r_1 <= pcounters_r_1[pbidx_last_r] + GolombCodeLen_r_1;
		ithcodelen_r_2 <= pcounters_r_2[pbidx_last_r] + GolombCodeLen_r_2;
		ithcodelen_r_3 <= pcounters_r_3[pbidx_last_r] + GolombCodeLen_r_3;
		ithcodelen_r_4 <= pcounters_r_4[pbidx_last_r] + GolombCodeLen_r_4;
		ithcodelen_r_5 <= pcounters_r_5[pbidx_last_r] + GolombCodeLen_r_5;
		ithcodelen_r_6 <= pcounters_r_6[pbidx_last_r] + GolombCodeLen_r_6;
		ithcodelen_r_7 <= pcounters_r_7[pbidx_last_r] + GolombCodeLen_r_7;	end
	
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		ithcodelen_g_0 <= 0;		ithcodelen_g_1 <= 0;	
		ithcodelen_g_2 <= 0;		ithcodelen_g_3 <= 0;	
		ithcodelen_g_4 <= 0;		ithcodelen_g_5 <= 0;	
		ithcodelen_g_6 <= 0;		ithcodelen_g_7 <= 0;		end
	else if(quic_dec_state == `quic_dec_set)begin	
		ithcodelen_g_0 <= 0;		ithcodelen_g_1 <= 0;	
		ithcodelen_g_2 <= 0;		ithcodelen_g_3 <= 0;	
		ithcodelen_g_4 <= 0;		ithcodelen_g_5 <= 0;	
		ithcodelen_g_6 <= 0;		ithcodelen_g_7 <= 0;		end
	else if(updat_state == `rst_updat_state && decode_state == `decode_updat)begin
		ithcodelen_g_0 <= pcounters_g_0[pbidx_last_g] + GolombCodeLen_g_0;
		ithcodelen_g_1 <= pcounters_g_1[pbidx_last_g] + GolombCodeLen_g_1;
		ithcodelen_g_2 <= pcounters_g_2[pbidx_last_g] + GolombCodeLen_g_2;
		ithcodelen_g_3 <= pcounters_g_3[pbidx_last_g] + GolombCodeLen_g_3;
		ithcodelen_g_4 <= pcounters_g_4[pbidx_last_g] + GolombCodeLen_g_4;
		ithcodelen_g_5 <= pcounters_g_5[pbidx_last_g] + GolombCodeLen_g_5;
		ithcodelen_g_6 <= pcounters_g_6[pbidx_last_g] + GolombCodeLen_g_6;
		ithcodelen_g_7 <= pcounters_g_7[pbidx_last_g] + GolombCodeLen_g_7;	end
		
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		ithcodelen_b_0 <= 0;		ithcodelen_b_1 <= 0;	
		ithcodelen_b_2 <= 0;		ithcodelen_b_3 <= 0;	
		ithcodelen_b_4 <= 0;		ithcodelen_b_5 <= 0;	
		ithcodelen_b_6 <= 0;		ithcodelen_b_7 <= 0;		end
	else if(quic_dec_state == `quic_dec_set)begin	
		ithcodelen_b_0 <= 0;		ithcodelen_b_1 <= 0;	
		ithcodelen_b_2 <= 0;		ithcodelen_b_3 <= 0;	
		ithcodelen_b_4 <= 0;		ithcodelen_b_5 <= 0;	
		ithcodelen_b_6 <= 0;		ithcodelen_b_7 <= 0;		end		
	else if(updat_state == `rst_updat_state && decode_state == `decode_updat)begin
		ithcodelen_b_0 <= pcounters_b_0[pbidx_last_b] + GolombCodeLen_b_0;
		ithcodelen_b_1 <= pcounters_b_1[pbidx_last_b] + GolombCodeLen_b_1;
		ithcodelen_b_2 <= pcounters_b_2[pbidx_last_b] + GolombCodeLen_b_2;
		ithcodelen_b_3 <= pcounters_b_3[pbidx_last_b] + GolombCodeLen_b_3;
		ithcodelen_b_4 <= pcounters_b_4[pbidx_last_b] + GolombCodeLen_b_4;
		ithcodelen_b_5 <= pcounters_b_5[pbidx_last_b] + GolombCodeLen_b_5;
		ithcodelen_b_6 <= pcounters_b_6[pbidx_last_b] + GolombCodeLen_b_6;
		ithcodelen_b_7 <= pcounters_b_7[pbidx_last_b] + GolombCodeLen_b_7;	end
		
		
	

reg [2:0] bestcode_updat_r;
reg [2:0] bestcode_updat_g;
reg [2:0] bestcode_updat_b;


wire [15:0] min_r,min_g,min_b;
wire [2:0] minidx_r,minidx_g,minidx_b;

min_8 min_8_r(
	.i0(ithcodelen_r_0),.i1(ithcodelen_r_1),.i2(ithcodelen_r_2),.i3(ithcodelen_r_3),
	.i4(ithcodelen_r_4),.i5(ithcodelen_r_5),.i6(ithcodelen_r_6),.i7(ithcodelen_r_7),
	.min(min_r),.minidx(minidx_r));

min_8 min_8_g(
	.i0(ithcodelen_g_0),.i1(ithcodelen_g_1),.i2(ithcodelen_g_2),.i3(ithcodelen_g_3),
	.i4(ithcodelen_g_4),.i5(ithcodelen_g_5),.i6(ithcodelen_g_6),.i7(ithcodelen_g_7),
	.min(min_g),.minidx(minidx_g));

min_8 min_8_b(
	.i0(ithcodelen_b_0),.i1(ithcodelen_b_1),.i2(ithcodelen_b_2),.i3(ithcodelen_b_3),
	.i4(ithcodelen_b_4),.i5(ithcodelen_b_5),.i6(ithcodelen_b_6),.i7(ithcodelen_b_7),
	.min(min_b),.minidx(minidx_b));

	
	
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		bestcode_updat_r <= 0;
		bestcode_updat_g <= 0;
		bestcode_updat_b <= 0;end
	else if(quic_dec_state == `quic_dec_set)begin
		bestcode_updat_r <= 0;
		bestcode_updat_g <= 0;
		bestcode_updat_b <= 0;end	
	else if(updat_state == `updat_bestcode)begin
		bestcode_updat_r <= minidx_r;
		bestcode_updat_g <= minidx_g;
		bestcode_updat_b <= minidx_b;end
		
	
	
reg [15:0] min_r_reg,min_g_reg,min_b_reg;
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		min_r_reg <= 0;
		min_g_reg <= 0;
		min_b_reg <= 0;end
	else if(quic_dec_state == `quic_dec_set)begin
		min_r_reg <= 0;
		min_g_reg <= 0;
		min_b_reg <= 0;end	
	else begin
		min_r_reg <= min_r;
		min_g_reg <= min_g;
		min_b_reg <= min_b;end
			
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		pcounters_r_0[0] <= 0;
		pcounters_r_1[0] <= 0;
		pcounters_r_2[0] <= 0;
		pcounters_r_3[0] <= 0;
		pcounters_r_4[0] <= 0;
		pcounters_r_5[0] <= 0;
		pcounters_r_6[0] <= 0;
		pcounters_r_7[0] <= 0;end
	else if(quic_dec_state == `quic_dec_set)begin
		pcounters_r_0[0] <= 0;
		pcounters_r_1[0] <= 0;
		pcounters_r_2[0] <= 0;
		pcounters_r_3[0] <= 0;
		pcounters_r_4[0] <= 0;
		pcounters_r_5[0] <= 0;
		pcounters_r_6[0] <= 0;
		pcounters_r_7[0] <= 0;end	
	else if(quic_dec_state == `quic_dec_init)begin
		pcounters_r_0[0] <= 0;	pcounters_r_1[0] <= 0;	pcounters_r_2[0] <= 0;	pcounters_r_3[0] <= 0;
		pcounters_r_4[0] <= 0;	pcounters_r_5[0] <= 0;	pcounters_r_6[0] <= 0;	pcounters_r_7[0] <= 0;
		pcounters_r_0[1] <= 0;	pcounters_r_1[1] <= 0;	pcounters_r_2[1] <= 0;	pcounters_r_3[1] <= 0;
		pcounters_r_4[1] <= 0;	pcounters_r_5[1] <= 0;	pcounters_r_6[1] <= 0;	pcounters_r_7[1] <= 0;
		pcounters_r_0[2] <= 0;	pcounters_r_1[2] <= 0;	pcounters_r_2[2] <= 0;	pcounters_r_3[2] <= 0;
		pcounters_r_4[2] <= 0;	pcounters_r_5[2] <= 0;	pcounters_r_6[2] <= 0;	pcounters_r_7[2] <= 0;
		pcounters_r_0[3] <= 0;	pcounters_r_1[3] <= 0;	pcounters_r_2[3] <= 0;	pcounters_r_3[3] <= 0;
		pcounters_r_4[3] <= 0;	pcounters_r_5[3] <= 0;	pcounters_r_6[3] <= 0;	pcounters_r_7[3] <= 0;
		pcounters_r_0[4] <= 0;	pcounters_r_1[4] <= 0;	pcounters_r_2[4] <= 0;	pcounters_r_3[4] <= 0;
		pcounters_r_4[4] <= 0;	pcounters_r_5[4] <= 0;	pcounters_r_6[4] <= 0;	pcounters_r_7[4] <= 0;
		pcounters_r_0[5] <= 0;	pcounters_r_1[5] <= 0;	pcounters_r_2[5] <= 0;	pcounters_r_3[5] <= 0;
		pcounters_r_4[5] <= 0;	pcounters_r_5[5] <= 0;	pcounters_r_6[5] <= 0;	pcounters_r_7[5] <= 0;
		pcounters_r_0[6] <= 0;	pcounters_r_1[6] <= 0;	pcounters_r_2[6] <= 0;	pcounters_r_3[6] <= 0;
		pcounters_r_4[6] <= 0;	pcounters_r_5[6] <= 0;	pcounters_r_6[6] <= 0;	pcounters_r_7[6] <= 0;
		pcounters_r_0[7] <= 0;	pcounters_r_1[7] <= 0;	pcounters_r_2[7] <= 0;	pcounters_r_3[7] <= 0;
		pcounters_r_4[7] <= 0;	pcounters_r_5[7] <= 0;	pcounters_r_6[7] <= 0;	pcounters_r_7[7] <= 0;
	end	
	else if(updat_state == `updat_updat)begin
		if(min_r_reg > wm_trigger)begin
			pcounters_r_0[pcounters_r_addr] <= ithcodelen_r_0 >> 1;
			pcounters_r_1[pcounters_r_addr] <= ithcodelen_r_1 >> 1;
			pcounters_r_2[pcounters_r_addr] <= ithcodelen_r_2 >> 1;
			pcounters_r_3[pcounters_r_addr] <= ithcodelen_r_3 >> 1;
			pcounters_r_4[pcounters_r_addr] <= ithcodelen_r_4 >> 1;
			pcounters_r_5[pcounters_r_addr] <= ithcodelen_r_5 >> 1;
			pcounters_r_6[pcounters_r_addr] <= ithcodelen_r_6 >> 1;
			pcounters_r_7[pcounters_r_addr] <= ithcodelen_r_7 >> 1;end
		else begin
			pcounters_r_0[pcounters_r_addr] <= ithcodelen_r_0;
			pcounters_r_1[pcounters_r_addr] <= ithcodelen_r_1;
			pcounters_r_2[pcounters_r_addr] <= ithcodelen_r_2;
			pcounters_r_3[pcounters_r_addr] <= ithcodelen_r_3;
			pcounters_r_4[pcounters_r_addr] <= ithcodelen_r_4;
			pcounters_r_5[pcounters_r_addr] <= ithcodelen_r_5;
			pcounters_r_6[pcounters_r_addr] <= ithcodelen_r_6;
			pcounters_r_7[pcounters_r_addr] <= ithcodelen_r_7;end		
	end

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		pcounters_g_0[0] <= 0;
		pcounters_g_1[0] <= 0;
		pcounters_g_2[0] <= 0;
		pcounters_g_3[0] <= 0;
		pcounters_g_4[0] <= 0;
		pcounters_g_5[0] <= 0;
		pcounters_g_6[0] <= 0;
		pcounters_g_7[0] <= 0;end
	else if(quic_dec_state == `quic_dec_set)begin
		pcounters_g_0[0] <= 0;
		pcounters_g_1[0] <= 0;
		pcounters_g_2[0] <= 0;
		pcounters_g_3[0] <= 0;
		pcounters_g_4[0] <= 0;
		pcounters_g_5[0] <= 0;
		pcounters_g_6[0] <= 0;
		pcounters_g_7[0] <= 0;end
			
	else if(quic_dec_state == `quic_dec_init)begin
		pcounters_g_0[0] <= 0;	pcounters_g_1[0] <= 0;	pcounters_g_2[0] <= 0;	pcounters_g_3[0] <= 0;
		pcounters_g_4[0] <= 0;	pcounters_g_5[0] <= 0;	pcounters_g_6[0] <= 0;	pcounters_g_7[0] <= 0;
		pcounters_g_0[1] <= 0;	pcounters_g_1[1] <= 0;	pcounters_g_2[1] <= 0;	pcounters_g_3[1] <= 0;
		pcounters_g_4[1] <= 0;	pcounters_g_5[1] <= 0;	pcounters_g_6[1] <= 0;	pcounters_g_7[1] <= 0;
		pcounters_g_0[2] <= 0;	pcounters_g_1[2] <= 0;	pcounters_g_2[2] <= 0;	pcounters_g_3[2] <= 0;
		pcounters_g_4[2] <= 0;	pcounters_g_5[2] <= 0;	pcounters_g_6[2] <= 0;	pcounters_g_7[2] <= 0;
		pcounters_g_0[3] <= 0;	pcounters_g_1[3] <= 0;	pcounters_g_2[3] <= 0;	pcounters_g_3[3] <= 0;
		pcounters_g_4[3] <= 0;	pcounters_g_5[3] <= 0;	pcounters_g_6[3] <= 0;	pcounters_g_7[3] <= 0;
		pcounters_g_0[4] <= 0;	pcounters_g_1[4] <= 0;	pcounters_g_2[4] <= 0;	pcounters_g_3[4] <= 0;
		pcounters_g_4[4] <= 0;	pcounters_g_5[4] <= 0;	pcounters_g_6[4] <= 0;	pcounters_g_7[4] <= 0;
		pcounters_g_0[5] <= 0;	pcounters_g_1[5] <= 0;	pcounters_g_2[5] <= 0;	pcounters_g_3[5] <= 0;
		pcounters_g_4[5] <= 0;	pcounters_g_5[5] <= 0;	pcounters_g_6[5] <= 0;	pcounters_g_7[5] <= 0;
		pcounters_g_0[6] <= 0;	pcounters_g_1[6] <= 0;	pcounters_g_2[6] <= 0;	pcounters_g_3[6] <= 0;
		pcounters_g_4[6] <= 0;	pcounters_g_5[6] <= 0;	pcounters_g_6[6] <= 0;	pcounters_g_7[6] <= 0;
		pcounters_g_0[7] <= 0;	pcounters_g_1[7] <= 0;	pcounters_g_2[7] <= 0;	pcounters_g_3[7] <= 0;
		pcounters_g_4[7] <= 0;	pcounters_g_5[7] <= 0;	pcounters_g_6[7] <= 0;	pcounters_g_7[7] <= 0;
	end	
	else if(updat_state == `updat_updat)begin
		if(min_g_reg > wm_trigger)begin
			pcounters_g_0[pcounters_g_addr] <= ithcodelen_g_0 >> 1;
			pcounters_g_1[pcounters_g_addr] <= ithcodelen_g_1 >> 1;
			pcounters_g_2[pcounters_g_addr] <= ithcodelen_g_2 >> 1;
			pcounters_g_3[pcounters_g_addr] <= ithcodelen_g_3 >> 1;
			pcounters_g_4[pcounters_g_addr] <= ithcodelen_g_4 >> 1;
			pcounters_g_5[pcounters_g_addr] <= ithcodelen_g_5 >> 1;
			pcounters_g_6[pcounters_g_addr] <= ithcodelen_g_6 >> 1;
			pcounters_g_7[pcounters_g_addr] <= ithcodelen_g_7 >> 1;end
		else begin
			pcounters_g_0[pcounters_g_addr] <= ithcodelen_g_0;
			pcounters_g_1[pcounters_g_addr] <= ithcodelen_g_1;
			pcounters_g_2[pcounters_g_addr] <= ithcodelen_g_2;
			pcounters_g_3[pcounters_g_addr] <= ithcodelen_g_3;
			pcounters_g_4[pcounters_g_addr] <= ithcodelen_g_4;
			pcounters_g_5[pcounters_g_addr] <= ithcodelen_g_5;
			pcounters_g_6[pcounters_g_addr] <= ithcodelen_g_6;
			pcounters_g_7[pcounters_g_addr] <= ithcodelen_g_7;end		
	end
	
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		pcounters_b_0[0] <= 0;
		pcounters_b_1[0] <= 0;
		pcounters_b_2[0] <= 0;
		pcounters_b_3[0] <= 0;
		pcounters_b_4[0] <= 0;
		pcounters_b_5[0] <= 0;
		pcounters_b_6[0] <= 0;
		pcounters_b_7[0] <= 0;end
	else if(quic_dec_state == `quic_dec_set)begin
		pcounters_b_0[0] <= 0;
		pcounters_b_1[0] <= 0;
		pcounters_b_2[0] <= 0;
		pcounters_b_3[0] <= 0;
		pcounters_b_4[0] <= 0;
		pcounters_b_5[0] <= 0;
		pcounters_b_6[0] <= 0;
		pcounters_b_7[0] <= 0;end	
	else if(quic_dec_state == `quic_dec_init)begin
		pcounters_b_0[0] <= 0;	pcounters_b_1[0] <= 0;	pcounters_b_2[0] <= 0;	pcounters_b_3[0] <= 0;
		pcounters_b_4[0] <= 0;	pcounters_b_5[0] <= 0;	pcounters_b_6[0] <= 0;	pcounters_b_7[0] <= 0;
		pcounters_b_0[1] <= 0;	pcounters_b_1[1] <= 0;	pcounters_b_2[1] <= 0;	pcounters_b_3[1] <= 0;
		pcounters_b_4[1] <= 0;	pcounters_b_5[1] <= 0;	pcounters_b_6[1] <= 0;	pcounters_b_7[1] <= 0;
		pcounters_b_0[2] <= 0;	pcounters_b_1[2] <= 0;	pcounters_b_2[2] <= 0;	pcounters_b_3[2] <= 0;
		pcounters_b_4[2] <= 0;	pcounters_b_5[2] <= 0;	pcounters_b_6[2] <= 0;	pcounters_b_7[2] <= 0;
		pcounters_b_0[3] <= 0;	pcounters_b_1[3] <= 0;	pcounters_b_2[3] <= 0;	pcounters_b_3[3] <= 0;
		pcounters_b_4[3] <= 0;	pcounters_b_5[3] <= 0;	pcounters_b_6[3] <= 0;	pcounters_b_7[3] <= 0;
		pcounters_b_0[4] <= 0;	pcounters_b_1[4] <= 0;	pcounters_b_2[4] <= 0;	pcounters_b_3[4] <= 0;
		pcounters_b_4[4] <= 0;	pcounters_b_5[4] <= 0;	pcounters_b_6[4] <= 0;	pcounters_b_7[4] <= 0;
		pcounters_b_0[5] <= 0;	pcounters_b_1[5] <= 0;	pcounters_b_2[5] <= 0;	pcounters_b_3[5] <= 0;
		pcounters_b_4[5] <= 0;	pcounters_b_5[5] <= 0;	pcounters_b_6[5] <= 0;	pcounters_b_7[5] <= 0;
		pcounters_b_0[6] <= 0;	pcounters_b_1[6] <= 0;	pcounters_b_2[6] <= 0;	pcounters_b_3[6] <= 0;
		pcounters_b_4[6] <= 0;	pcounters_b_5[6] <= 0;	pcounters_b_6[6] <= 0;	pcounters_b_7[6] <= 0;
		pcounters_b_0[7] <= 0;	pcounters_b_1[7] <= 0;	pcounters_b_2[7] <= 0;	pcounters_b_3[7] <= 0;
		pcounters_b_4[7] <= 0;	pcounters_b_5[7] <= 0;	pcounters_b_6[7] <= 0;	pcounters_b_7[7] <= 0;
	end	
	else if(updat_state == `updat_updat)begin
		if(min_b_reg > wm_trigger)begin
			pcounters_b_0[pcounters_b_addr] <= ithcodelen_b_0 >> 1;
			pcounters_b_1[pcounters_b_addr] <= ithcodelen_b_1 >> 1;
			pcounters_b_2[pcounters_b_addr] <= ithcodelen_b_2 >> 1;
			pcounters_b_3[pcounters_b_addr] <= ithcodelen_b_3 >> 1;
			pcounters_b_4[pcounters_b_addr] <= ithcodelen_b_4 >> 1;
			pcounters_b_5[pcounters_b_addr] <= ithcodelen_b_5 >> 1;
			pcounters_b_6[pcounters_b_addr] <= ithcodelen_b_6 >> 1;
			pcounters_b_7[pcounters_b_addr] <= ithcodelen_b_7 >> 1;end
		else begin
			pcounters_b_0[pcounters_b_addr] <= ithcodelen_b_0;
			pcounters_b_1[pcounters_b_addr] <= ithcodelen_b_1;
			pcounters_b_2[pcounters_b_addr] <= ithcodelen_b_2;
			pcounters_b_3[pcounters_b_addr] <= ithcodelen_b_3;
			pcounters_b_4[pcounters_b_addr] <= ithcodelen_b_4;
			pcounters_b_5[pcounters_b_addr] <= ithcodelen_b_5;
			pcounters_b_6[pcounters_b_addr] <= ithcodelen_b_6;
			pcounters_b_7[pcounters_b_addr] <= ithcodelen_b_7;end		
	end
	
		
		
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		bestcode_r_ram[0] <= 3'd7;
		bestcode_r_ram[1] <= 3'd7;
		bestcode_r_ram[2] <= 3'd7;
		bestcode_r_ram[3] <= 3'd7;
		bestcode_r_ram[4] <= 3'd7;
		bestcode_r_ram[5] <= 3'd7;
		bestcode_r_ram[6] <= 3'd7;
		bestcode_r_ram[7] <= 3'd7;end
	else if(quic_dec_state == `quic_dec_set)begin
		bestcode_r_ram[0] <= 3'd7;
		bestcode_r_ram[1] <= 3'd7;
		bestcode_r_ram[2] <= 3'd7;
		bestcode_r_ram[3] <= 3'd7;
		bestcode_r_ram[4] <= 3'd7;
		bestcode_r_ram[5] <= 3'd7;
		bestcode_r_ram[6] <= 3'd7;
		bestcode_r_ram[7] <= 3'd7;end	
	else if(quic_dec_state == `quic_dec_init)begin
		bestcode_r_ram[0] <= 3'd7;
		bestcode_r_ram[1] <= 3'd7;
		bestcode_r_ram[2] <= 3'd7;
		bestcode_r_ram[3] <= 3'd7;
		bestcode_r_ram[4] <= 3'd7;
		bestcode_r_ram[5] <= 3'd7;
		bestcode_r_ram[6] <= 3'd7;
		bestcode_r_ram[7] <= 3'd7;end
	else if(updat_state == `updat_updat)
		bestcode_r_ram[pcounters_r_addr] <= bestcode_updat_r;

		
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		bestcode_g_ram[0] <= 3'd7;
		bestcode_g_ram[1] <= 3'd7;
		bestcode_g_ram[2] <= 3'd7;
		bestcode_g_ram[3] <= 3'd7;
		bestcode_g_ram[4] <= 3'd7;
		bestcode_g_ram[5] <= 3'd7;
		bestcode_g_ram[6] <= 3'd7;
		bestcode_g_ram[7] <= 3'd7;end
	else if(quic_dec_state == `quic_dec_set)begin
		bestcode_g_ram[0] <= 3'd7;
		bestcode_g_ram[1] <= 3'd7;
		bestcode_g_ram[2] <= 3'd7;
		bestcode_g_ram[3] <= 3'd7;
		bestcode_g_ram[4] <= 3'd7;
		bestcode_g_ram[5] <= 3'd7;
		bestcode_g_ram[6] <= 3'd7;
		bestcode_g_ram[7] <= 3'd7;end	
	else if(quic_dec_state == `quic_dec_init)begin
		bestcode_g_ram[0] <= 3'd7;
		bestcode_g_ram[1] <= 3'd7;
		bestcode_g_ram[2] <= 3'd7;
		bestcode_g_ram[3] <= 3'd7;
		bestcode_g_ram[4] <= 3'd7;
		bestcode_g_ram[5] <= 3'd7;
		bestcode_g_ram[6] <= 3'd7;
		bestcode_g_ram[7] <= 3'd7;end
	else if(updat_state == `updat_updat)
		bestcode_g_ram[pcounters_g_addr] <= bestcode_updat_g;


always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		bestcode_b_ram[0] <= 3'd7;
		bestcode_b_ram[1] <= 3'd7;
		bestcode_b_ram[2] <= 3'd7;
		bestcode_b_ram[3] <= 3'd7;
		bestcode_b_ram[4] <= 3'd7;
		bestcode_b_ram[5] <= 3'd7;
		bestcode_b_ram[6] <= 3'd7;
		bestcode_b_ram[7] <= 3'd7;end
	else if(quic_dec_state == `quic_dec_set)begin
		bestcode_b_ram[0] <= 3'd7;
		bestcode_b_ram[1] <= 3'd7;
		bestcode_b_ram[2] <= 3'd7;
		bestcode_b_ram[3] <= 3'd7;
		bestcode_b_ram[4] <= 3'd7;
		bestcode_b_ram[5] <= 3'd7;
		bestcode_b_ram[6] <= 3'd7;
		bestcode_b_ram[7] <= 3'd7;end	
	else if(quic_dec_state == `quic_dec_init)begin
		bestcode_b_ram[0] <= 3'd7;
		bestcode_b_ram[1] <= 3'd7;
		bestcode_b_ram[2] <= 3'd7;
		bestcode_b_ram[3] <= 3'd7;
		bestcode_b_ram[4] <= 3'd7;
		bestcode_b_ram[5] <= 3'd7;
		bestcode_b_ram[6] <= 3'd7;
		bestcode_b_ram[7] <= 3'd7;end
	else if(updat_state == `updat_updat)
		bestcode_b_ram[pcounters_b_addr] <= bestcode_updat_b;
	
			
reg [15:0] wmileft;


reg [1:0] left_flag;
always@(posedge clk or negedge reset_n)	
	if(reset_n == 0)
		left_flag <= 0;
	else if(quic_dec_state == `quic_dec_set)
		left_flag <= 0;	
	else if(decode_state == `rst_decode_state && column == 0)begin
		if((wmidx < 3'd5) && (wmileft + 16'd2048 == width))
			left_flag <= 2'd3;
		else if((wmidx < 3'd5) && (wmileft + 16'd2048 < width))
			left_flag <= 2'd2;
		else if((wmidx < 3'd6) && (wmileft <= width))
			left_flag <= 2'd1;
		else
			left_flag <= 2'd0;
	end

	
	
reg [15:0] wmileft_tmp;
	
reg left_changed;
always@(posedge clk or negedge reset_n)	
	if(reset_n == 0)
		wmidx <= 0;
	else if(quic_dec_state == `quic_dec_set)
		wmidx <= 0;	
	else if((updat_state == `updat_updat || decode_state == `decode_noupdat || decode_state == `decode_runupdat) && left_changed == 0
					&& column == wmileft - 16'd1 && left_flag != 0)
		wmidx <= wmidx + 3'd1;
	else if((updat_state == `updat_updat || decode_state == `decode_noupdat || decode_state == `decode_runupdat) 
					&& column == wmileft_tmp + 16'd2047 && left_flag[1] == 1)
		wmidx <= wmidx + 3'd1;
		


always@(posedge clk or negedge reset_n)	
	if(reset_n == 0)
		wmileft <= 0;
	else if(quic_dec_state == `quic_dec_set)
		wmileft <= 0;	
	else if(quic_dec_state == `quic_dec_init)
		wmileft <= 16'h800;		
	else if((updat_state == `updat_updat || decode_state == `decode_noupdat || decode_state == `decode_runupdat) 
			&& column == width - 16'd1 && width != wmileft && width != wmileft + 16'd2048)begin
		if(wmidx < 3'd6)begin
			if(left_flag == 2)
				wmileft <= 16'h1000 - width + wmileft_tmp;
			else if(left_flag == 1)
				wmileft <= 16'h800 - width + wmileft_tmp;
			else if(left_flag == 0)
				wmileft <= wmileft - width;
		end
	end
	else if((updat_state == `updat_updat || decode_state == `decode_noupdat || decode_state == `decode_runupdat)
			&& column == wmileft - 16'd1 && left_flag != 0 && left_changed == 0)
		wmileft <= 16'h800;	

always@(posedge clk or negedge reset_n)	
	if(reset_n == 0)
		left_changed <= 0;
	else if(quic_dec_state == `quic_dec_set)
		left_changed <= 0;	
	else if(decode_state == `rst_decode_state && column == 0)
		left_changed <= 0;
	else if((updat_state == `updat_updat || decode_state == `decode_noupdat || decode_state == `decode_runupdat)
			&& column == wmileft - 16'd1 && left_flag != 0 && left_changed == 0)
		left_changed <= 1;
	

		
always@(posedge clk or negedge reset_n)	
	if(reset_n == 0)
		wmileft_tmp <= 0;
	else if(quic_dec_state == `quic_dec_set)
		wmileft_tmp <= 0;	
	else if((updat_state == `updat_updat || decode_state == `decode_noupdat || decode_state == `decode_runupdat) 
		&& column == wmileft - 16'd1 && left_flag != 0 && left_changed == 0)
		wmileft_tmp <= wmileft;


wire [7:0] bppmask_wmidx;
assign bppmask_wmidx = (8'd1 << wmidx[2:0]) - 8'd1;


//wire [7:0] tabrand;
reg [7:0] tabrand_seed;
//reg [7:0] tabrand_chaos [0:255];
//assign tabrand = tabrand_chaos[tabrand_seed];

   reg [7:0] tabrand;   
   always@(*) begin
      case (tabrand_seed) 
        0  : tabrand = 8'h42     ;
        1  : tabrand = 8'h17     ;
        2  : tabrand = 8'h53     ;
        3  : tabrand = 8'h55     ;
        4  : tabrand = 8'h07     ;
        5  : tabrand = 8'h52     ;
        6  : tabrand = 8'h28     ;
        7  : tabrand = 8'h8e     ;
        8  : tabrand = 8'h8c     ;
        9  : tabrand = 8'he0     ;
        10  : tabrand = 8'haf    ;
        11  : tabrand = 8'hac    ;
        12  : tabrand = 8'h64    ;
        13  : tabrand = 8'h86    ;
        14  : tabrand = 8'h92    ;
        15  : tabrand = 8'h4b    ;
        16  : tabrand = 8'h44    ;
        17  : tabrand = 8'h13    ;
        18  : tabrand = 8'hea    ;
        19  : tabrand = 8'h1d    ;
        20  : tabrand = 8'h50    ;
        21  : tabrand = 8'h7f    ;
        22  : tabrand = 8'hb9    ;
        23  : tabrand = 8'h33    ;
        24  : tabrand = 8'hd0    ;
        25  : tabrand = 8'h03    ;
        26  : tabrand = 8'h05    ;
        27  : tabrand = 8'h4e    ;
        28  : tabrand = 8'h0f    ;
        29  : tabrand = 8'h9e    ;
        30  : tabrand = 8'h94    ;
        31  : tabrand = 8'h89    ;
        32  : tabrand = 8'ha4    ;
        33  : tabrand = 8'h6d    ;
        34  : tabrand = 8'h43    ;
        35  : tabrand = 8'hf9    ;
        36  : tabrand = 8'hbd    ;
        37  : tabrand = 8'h00    ;
        38  : tabrand = 8'h08    ;
        39  : tabrand = 8'h45    ;
        40  : tabrand = 8'h29    ;
        41  : tabrand = 8'hce    ;
        42  : tabrand = 8'h6b    ;
        43  : tabrand = 8'h5b    ;
        44  : tabrand = 8'hab    ;
        45  : tabrand = 8'hbb    ;
        46  : tabrand = 8'h1f    ;
        47  : tabrand = 8'he3    ;
        48  : tabrand = 8'h27    ;
        49  : tabrand = 8'h7c    ;
        50  : tabrand = 8'h2a    ;
        51  : tabrand = 8'ha6    ;
        52  : tabrand = 8'h4d    ;
        53  : tabrand = 8'h36    ;
        54  : tabrand = 8'h7e    ;
        55  : tabrand = 8'hc1    ;
        56  : tabrand = 8'h1a    ;
        57  : tabrand = 8'hc3    ;
        58  : tabrand = 8'h0b    ;
        59  : tabrand = 8'h3d    ;
        60  : tabrand = 8'h74    ;
        61  : tabrand = 8'ha2    ;
        62  : tabrand = 8'hc7    ;
        63  : tabrand = 8'hf0    ;
        64  : tabrand = 8'h04    ;
        65  : tabrand = 8'h3b    ;
        66  : tabrand = 8'h16    ;
        67  : tabrand = 8'h0c    ;
        68  : tabrand = 8'h96    ;
        69  : tabrand = 8'h88    ;
        70  : tabrand = 8'hb2    ;
        71  : tabrand = 8'h84    ;
        72  : tabrand = 8'h8a    ;
        73  : tabrand = 8'h46    ;
        74  : tabrand = 8'h2c    ;
        75  : tabrand = 8'hc8    ;
        76  : tabrand = 8'h8b    ;
        77  : tabrand = 8'hee    ;
        78  : tabrand = 8'hdf    ;
        79  : tabrand = 8'h73    ;
        80  : tabrand = 8'h75    ;
        81  : tabrand = 8'h11    ;
        82  : tabrand = 8'h01    ;
        83  : tabrand = 8'h2b    ;
        84  : tabrand = 8'h6e    ;
        85  : tabrand = 8'h3c    ;
        86  : tabrand = 8'he4    ;
        87  : tabrand = 8'h76    ;
        88  : tabrand = 8'h0a    ;
        89  : tabrand = 8'h9b    ;
        90  : tabrand = 8'h67    ;
        91  : tabrand = 8'h6c    ;
        92  : tabrand = 8'h56    ;
        93  : tabrand = 8'he9    ;
        94  : tabrand = 8'h57    ;
        95  : tabrand = 8'hc2    ;
        96  : tabrand = 8'hec    ;
        97  : tabrand = 8'h40    ;
        98  : tabrand = 8'h68    ;
        99  : tabrand = 8'hb5    ;
        100 : tabrand = 8'ha8    ;
        101 : tabrand = 8'hb0    ;
        102 : tabrand = 8'h90    ;
        103 : tabrand = 8'heb    ;
        104 : tabrand = 8'h60    ;
        105 : tabrand = 8'h5c    ;
        106 : tabrand = 8'he1    ;
        107 : tabrand = 8'h4c    ;
        108 : tabrand = 8'h54    ;
        109 : tabrand = 8'h02    ;
        110 : tabrand = 8'h78    ;
        111 : tabrand = 8'hbe    ;
        112 : tabrand = 8'h77    ;
        113 : tabrand = 8'hfa    ;
        114 : tabrand = 8'h12    ;
        115 : tabrand = 8'h14    ;
        116 : tabrand = 8'h0d    ;
        117 : tabrand = 8'h37    ;
        118 : tabrand = 8'h26    ;
        119 : tabrand = 8'h9d    ;
        120 : tabrand = 8'h79    ;
        121 : tabrand = 8'hd3    ;
        122 : tabrand = 8'h31    ;
        123 : tabrand = 8'h21    ;
        124 : tabrand = 8'h6f    ;
        125 : tabrand = 8'hbf    ;
        126 : tabrand = 8'hfb    ;
        127 : tabrand = 8'h80    ;
        128 : tabrand = 8'h23    ;
        129 : tabrand = 8'hfd    ;
        130 : tabrand = 8'h93    ;
        131 : tabrand = 8'h19    ;
        132 : tabrand = 8'h2e    ;
        133 : tabrand = 8'h66    ;
        134 : tabrand = 8'hfc    ;
        135 : tabrand = 8'hc4    ;
        136 : tabrand = 8'h63    ;
        137 : tabrand = 8'h41    ;
        138 : tabrand = 8'h9a    ;
        139 : tabrand = 8'he8    ;
        140 : tabrand = 8'h9c    ;
        141 : tabrand = 8'hca    ;
        142 : tabrand = 8'h85    ;
        143 : tabrand = 8'h0e    ;
        144 : tabrand = 8'hd9    ;
        145 : tabrand = 8'hd2    ;
        146 : tabrand = 8'h70    ;
        147 : tabrand = 8'hf1    ;
        148 : tabrand = 8'hd4    ;
        149 : tabrand = 8'h7b    ;
        150 : tabrand = 8'h3e    ;
        151 : tabrand = 8'he2    ;
        152 : tabrand = 8'hae    ;
        153 : tabrand = 8'h87    ;
        154 : tabrand = 8'ha1    ;
        155 : tabrand = 8'h34    ;
        156 : tabrand = 8'h22    ;
        157 : tabrand = 8'h7a    ;
        158 : tabrand = 8'hc9    ;
        159 : tabrand = 8'h5d    ;
        160 : tabrand = 8'h48    ;
        161 : tabrand = 8'hf7    ;
        162 : tabrand = 8'hfe    ;
        163 : tabrand = 8'hbc    ;
        164 : tabrand = 8'ha5    ;
        165 : tabrand = 8'h24    ;
        166 : tabrand = 8'he5    ;
        167 : tabrand = 8'h72    ;
        168 : tabrand = 8'hc6    ;
        169 : tabrand = 8'h83    ;
        170 : tabrand = 8'h4a    ;
        171 : tabrand = 8'h1c    ;
        172 : tabrand = 8'h30    ;
        173 : tabrand = 8'h98    ;
        174 : tabrand = 8'h5a    ;
        175 : tabrand = 8'h7d    ;
        176 : tabrand = 8'h39    ;
        177 : tabrand = 8'h1e    ;
        178 : tabrand = 8'hcb    ;
        179 : tabrand = 8'hb6    ;
        180 : tabrand = 8'h82    ;
        181 : tabrand = 8'h06    ;
        182 : tabrand = 8'h32    ;
        183 : tabrand = 8'hef    ;
        184 : tabrand = 8'h47    ;
        185 : tabrand = 8'h91    ;
        186 : tabrand = 8'ha3    ;
        187 : tabrand = 8'h35    ;
        188 : tabrand = 8'h20    ;
        189 : tabrand = 8'hcc    ;
        190 : tabrand = 8'hd7    ;
        191 : tabrand = 8'hd1    ;
        192 : tabrand = 8'hc5    ;
        193 : tabrand = 8'h15    ;
        194 : tabrand = 8'h71    ;
        195 : tabrand = 8'hb7    ;
        196 : tabrand = 8'hb3    ;
        197 : tabrand = 8'h2d    ;
        198 : tabrand = 8'hb4    ;
        199 : tabrand = 8'h1b    ;
        200 : tabrand = 8'he7    ;
        201 : tabrand = 8'h99    ;
        202 : tabrand = 8'ha7    ;
        203 : tabrand = 8'hff    ;
        204 : tabrand = 8'hd6    ;
        205 : tabrand = 8'hd8    ;
        206 : tabrand = 8'haa    ;
        207 : tabrand = 8'hf4    ;
        208 : tabrand = 8'h38    ;
        209 : tabrand = 8'he6    ;
        210 : tabrand = 8'h69    ;
        211 : tabrand = 8'ha9    ;
        212 : tabrand = 8'hb8    ;
        213 : tabrand = 8'ha0    ;
        214 : tabrand = 8'hcd    ;
        215 : tabrand = 8'h58    ;
        216 : tabrand = 8'hda    ;
        217 : tabrand = 8'hf3    ;
        218 : tabrand = 8'hdb    ;
        219 : tabrand = 8'hf8    ;
        220 : tabrand = 8'h3a    ;
        221 : tabrand = 8'h65    ;
        222 : tabrand = 8'h18    ;
        223 : tabrand = 8'h6a    ;
        224 : tabrand = 8'h8f    ;
        225 : tabrand = 8'hdc    ;
        226 : tabrand = 8'h51    ;
        227 : tabrand = 8'h5e    ;
        228 : tabrand = 8'h5f    ;
        229 : tabrand = 8'hcf    ;
        230 : tabrand = 8'h10    ;
        231 : tabrand = 8'h97    ;
        232 : tabrand = 8'h59    ;
        233 : tabrand = 8'hf6    ;
        234 : tabrand = 8'h61    ;
        235 : tabrand = 8'h62    ;
        236 : tabrand = 8'h81    ;
        237 : tabrand = 8'hdd    ;
        238 : tabrand = 8'h9f    ;
        239 : tabrand = 8'hf2    ;
        240 : tabrand = 8'hf5    ;
        241 : tabrand = 8'h95    ;
        242 : tabrand = 8'hb1    ;
        243 : tabrand = 8'h4f    ;
        244 : tabrand = 8'h2f    ;
        245 : tabrand = 8'h49    ;
        246 : tabrand = 8'hc0    ;
        247 : tabrand = 8'hba    ;
        248 : tabrand = 8'h25    ;
        249 : tabrand = 8'had    ;
        250 : tabrand = 8'hde    ;
        251 : tabrand = 8'h8d    ;
        252 : tabrand = 8'h09    ;
        253 : tabrand = 8'hed    ;
        254 : tabrand = 8'h3f    ;
        255 : tabrand = 8'hd5    ;
      endcase; // case (tabrand_seed)
   end


		
		
		
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		tabrand_seed <= 8'b0;
	else if(quic_dec_state == `quic_dec_set)
		tabrand_seed <= 8'b0;	
	else  if(updat_state == `updat_updat)
		tabrand_seed <= tabrand_seed + 8'd1;



always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		jump_count <= 0;
	else if(quic_dec_state == `quic_dec_set)
		jump_count <= 0;	
	else if(updat_state == `updat_updat)
		jump_count <= tabrand & bppmask_wmidx;
	else if(decode_state == `decode_noupdat)
		jump_count <= jump_count - 8'd1;
		




always@(reset_n or updat_state or decode_state or nGRcodewords_0  or notGRcwlen_0
			or context_cur_r or context_cur_g or context_cur_b )
	if(reset_n == 0)begin
		GolombCodeLen_r_0 = 0;	GolombCodeLen_g_0 = 0;	
		GolombCodeLen_b_0 = 0;	end
	else if(updat_state == `rst_updat_state && decode_state == `decode_updat)begin
		GolombCodeLen_r_0 = (context_cur_r < nGRcodewords_0[7:0]) ? {8'd0,context_cur_r} + 16'd1 : notGRcwlen_0[15:0];
		GolombCodeLen_g_0 = (context_cur_g < nGRcodewords_0[7:0]) ? {8'd0,context_cur_g} + 16'd1 : notGRcwlen_0[15:0];
		GolombCodeLen_b_0 = (context_cur_b < nGRcodewords_0[7:0]) ? {8'd0,context_cur_b} + 16'd1 : notGRcwlen_0[15:0];end
	else begin 
		GolombCodeLen_r_0 = 0;	GolombCodeLen_g_0 = 0;	
		GolombCodeLen_b_0 = 0;	end
	

always@(reset_n or updat_state or decode_state or nGRcodewords_1 or notGRcwlen_1
			or context_cur_r or context_cur_g or context_cur_b  )
	if(reset_n == 0)begin
		GolombCodeLen_r_1 = 0;	GolombCodeLen_g_1 = 0;	
		GolombCodeLen_b_1 = 0;	end		
	else if(updat_state == `rst_updat_state && decode_state == `decode_updat)begin
		GolombCodeLen_r_1 = (context_cur_r < nGRcodewords_1[7:0]) ? {9'd0,context_cur_r[7:1]} + 16'd2 : notGRcwlen_1[15:0];
		GolombCodeLen_g_1 = (context_cur_g < nGRcodewords_1[7:0]) ? {9'd0,context_cur_g[7:1]} + 16'd2 : notGRcwlen_1[15:0];
		GolombCodeLen_b_1 = (context_cur_b < nGRcodewords_1[7:0]) ? {9'd0,context_cur_b[7:1]} + 16'd2 : notGRcwlen_1[15:0];
		end
	else begin
		GolombCodeLen_r_1 = 0;	GolombCodeLen_g_1 = 0;	
		GolombCodeLen_b_1 = 0;	end
	
always@(reset_n or updat_state or decode_state or nGRcodewords_2 or notGRcwlen_2
		or context_cur_r or context_cur_g or context_cur_b )
	if(reset_n == 0)begin
		GolombCodeLen_r_2 = 0;	GolombCodeLen_g_2 = 0;	
		GolombCodeLen_b_2 = 0;	end			
	else if(updat_state == `rst_updat_state && decode_state == `decode_updat)begin
		GolombCodeLen_r_2 = (context_cur_r < nGRcodewords_2[7:0]) ? {10'd0,context_cur_r[7:2]} + 16'd3 : notGRcwlen_2[15:0];
		GolombCodeLen_g_2 = (context_cur_g < nGRcodewords_2[7:0]) ? {10'd0,context_cur_g[7:2]} + 16'd3 : notGRcwlen_2[15:0];
		GolombCodeLen_b_2 = (context_cur_b < nGRcodewords_2[7:0]) ? {10'd0,context_cur_b[7:2]} + 16'd3 : notGRcwlen_2[15:0];
		end
	else begin
		GolombCodeLen_r_2 = 0;	GolombCodeLen_g_2 = 0;	
		GolombCodeLen_b_2 = 0;	end

		
always@(reset_n or updat_state or decode_state or nGRcodewords_3 or notGRcwlen_3
		or context_cur_r or context_cur_g or context_cur_b )
	if(reset_n == 0)begin
		GolombCodeLen_r_3 = 0;	GolombCodeLen_g_3 = 0;	
		GolombCodeLen_b_3 = 0;	end			
	else if(updat_state == `rst_updat_state && decode_state == `decode_updat)begin
		GolombCodeLen_r_3 = (context_cur_r < nGRcodewords_3[7:0]) ? {11'd0,context_cur_r[7:3]} + 16'd4 : notGRcwlen_3[15:0];
		GolombCodeLen_g_3 = (context_cur_g < nGRcodewords_3[7:0]) ? {11'd0,context_cur_g[7:3]} + 16'd4 : notGRcwlen_3[15:0];
		GolombCodeLen_b_3 = (context_cur_b < nGRcodewords_3[7:0]) ? {11'd0,context_cur_b[7:3]} + 16'd4 : notGRcwlen_3[15:0];
		end
	else begin
		GolombCodeLen_r_3 = 0;	GolombCodeLen_g_3 = 0;	
		GolombCodeLen_b_3 = 0;	end

		
always@(reset_n or updat_state or decode_state or nGRcodewords_4 or notGRcwlen_4
		or context_cur_r or context_cur_g or context_cur_b)
	if(reset_n == 0)begin
		GolombCodeLen_r_4 = 0;	GolombCodeLen_g_4 = 0;	
		GolombCodeLen_b_4 = 0;	end			
	else if(updat_state == `rst_updat_state && decode_state == `decode_updat)begin
		GolombCodeLen_r_4 = (context_cur_r < nGRcodewords_4[7:0]) ? {12'd0,context_cur_r[7:4]} + 16'd5 : notGRcwlen_4[15:0];
		GolombCodeLen_g_4 = (context_cur_g < nGRcodewords_4[7:0]) ? {12'd0,context_cur_g[7:4]} + 16'd5 : notGRcwlen_4[15:0];
		GolombCodeLen_b_4 = (context_cur_b < nGRcodewords_4[7:0]) ? {12'd0,context_cur_b[7:4]} + 16'd5 : notGRcwlen_4[15:0];
	end
	else  begin
		GolombCodeLen_r_4 = 0;	GolombCodeLen_g_4 = 0;	
		GolombCodeLen_b_4 = 0;	end

		
always@(reset_n or updat_state or decode_state or nGRcodewords_5 or notGRcwlen_5
		or context_cur_r or context_cur_g or context_cur_b )
	if(reset_n == 0)begin
		GolombCodeLen_r_5 = 0;	GolombCodeLen_g_5 = 0;	
		GolombCodeLen_b_5 = 0;	end		
	else if(updat_state == `rst_updat_state && decode_state == `decode_updat)begin
		GolombCodeLen_r_5 = (context_cur_r < nGRcodewords_5[7:0]) ? {13'd0,context_cur_r[7:5]} + 16'd6 : notGRcwlen_5[15:0];
		GolombCodeLen_g_5 = (context_cur_g < nGRcodewords_5[7:0]) ? {13'd0,context_cur_g[7:5]} + 16'd6 : notGRcwlen_5[15:0];
		GolombCodeLen_b_5 = (context_cur_b < nGRcodewords_5[7:0]) ? {13'd0,context_cur_b[7:5]} + 16'd6 : notGRcwlen_5[15:0];
	end
	else  begin
		GolombCodeLen_r_5 = 0;	GolombCodeLen_g_5 = 0;	
		GolombCodeLen_b_5 = 0;	end

always@(reset_n or updat_state or decode_state or nGRcodewords_6 or notGRcwlen_6
		or context_cur_r or context_cur_g or context_cur_b )
	if(reset_n == 0)begin
		GolombCodeLen_r_6 = 0;	GolombCodeLen_g_6 = 0;	
		GolombCodeLen_b_6 = 0;	end			
	else if(updat_state == `rst_updat_state && decode_state == `decode_updat)begin
		GolombCodeLen_r_6 = (context_cur_r < nGRcodewords_6[7:0]) ? {14'd0,context_cur_r[7:6]} + 16'd7 : notGRcwlen_6[15:0]; 
		GolombCodeLen_g_6 = (context_cur_g < nGRcodewords_6[7:0]) ? {14'd0,context_cur_g[7:6]} + 16'd7 : notGRcwlen_6[15:0]; 
		GolombCodeLen_b_6 = (context_cur_b < nGRcodewords_6[7:0]) ? {14'd0,context_cur_b[7:6]} + 16'd7 : notGRcwlen_6[15:0]; 
	end
	else begin
		GolombCodeLen_r_6 = 0;	GolombCodeLen_g_6 = 0;	
		GolombCodeLen_b_6 = 0;	end
	
always@(reset_n or updat_state or decode_state or nGRcodewords_7 or notGRcwlen_7
		or context_cur_r or context_cur_g or context_cur_b )
	if(reset_n == 0)begin
		GolombCodeLen_r_7 = 0;	GolombCodeLen_g_7 = 0;	
		GolombCodeLen_b_7 = 0;	end			
	else if(updat_state == `rst_updat_state && decode_state == `decode_updat)begin
		GolombCodeLen_r_7 = (context_cur_r < nGRcodewords_7[7:0]) ? {15'd0,context_cur_r[7]} + 16'd8 : notGRcwlen_7[15:0]; 
		GolombCodeLen_g_7 = (context_cur_g < nGRcodewords_7[7:0]) ? {15'd0,context_cur_g[7]} + 16'd8 : notGRcwlen_7[15:0]; 
		GolombCodeLen_b_7 = (context_cur_b < nGRcodewords_7[7:0]) ? {15'd0,context_cur_b[7]} + 16'd8 : notGRcwlen_7[15:0]; 
		end
	else begin
		GolombCodeLen_r_7 = 0;	GolombCodeLen_g_7 = 0;	
		GolombCodeLen_b_7 = 0;	end


endmodule

module min_8(
input [15:0] i0,i1,i2,i3,i4,i5,i6,i7,

output [15:0] min,
output [2:0] minidx
);

wire [15:0] min_01,min_23,min_45,min_67;
wire [2:0] minidx_01,minidx_23,minidx_45,minidx_67;

assign min_01 = i0 < i1 ? i0 : i1;
assign min_23 = i2 < i3 ? i2 : i3;
assign min_45 = i4 < i5 ? i4 : i5;
assign min_67 = i6 < i7 ? i6 : i7;

assign minidx_01 = i0 < i1 ? 3'd0 : 3'd1;
assign minidx_23 = i2 < i3 ? 3'd2 : 3'd3;
assign minidx_45 = i4 < i5 ? 3'd4 : 3'd5;
assign minidx_67 = i6 < i7 ? 3'd6 : 3'd7;


wire [15:0] min_03,min_47;
wire [2:0] minidx_03,minidx_47;

assign min_03 = min_01 < min_23 ? min_01 : min_23;
assign min_47 = min_45 < min_67 ? min_45 : min_67;
assign minidx_03 = min_01 < min_23 ? minidx_01 : minidx_23;
assign minidx_47 = min_45 < min_67 ? minidx_45 : minidx_67;

assign min = min_03 < min_47 ? min_03 : min_47;
assign minidx = min_03 < min_47 ? minidx_03 : minidx_47;


endmodule
