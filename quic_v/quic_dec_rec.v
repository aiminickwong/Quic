`include "timescale.v"
`include "defines.v"

module quic_dec_rec(
input clk,reset_n,
input rd,
input [2:0] quic_dec_state,
input [3:0] decode_state,
input [2:0] updat_state,
input [7:0] context_cur_r,
input [7:0] context_cur_g,
input [7:0] context_cur_b,
input [15:0] width,height,
input [7:0] pix_r_pred,pix_g_pred,pix_b_pred,
input [15:0] column,row,
input [15:0] column_pred,row_pred,
input wait_updat_flag,


output reg [7:0] pix_r,pix_g,pix_b,
output reg [7:0] pix_r_a,pix_g_a,pix_b_a,
output  [7:0] pix_r_b,pix_g_b,pix_b_b,
output reg [7:0] pix_r_c,pix_g_c,pix_b_c,
output reg [7:0] pix_r_d,pix_g_d,pix_b_d

);

wire [7:0] res_r,res_g,res_b;

assign res_r = context_cur_r[0] ? {1'b1,~(context_cur_r[7:1])} : {1'b0,context_cur_r[7:1]};
assign res_g = context_cur_g[0] ? {1'b1,~(context_cur_g[7:1])} : {1'b0,context_cur_g[7:1]};
assign res_b = context_cur_b[0] ? {1'b1,~(context_cur_b[7:1])} : {1'b0,context_cur_b[7:1]};


always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		pix_r <= 0;
	else if(quic_dec_state == `quic_dec_set)
		pix_r <= 0;	
	else if(updat_state == `updat_updat  || decode_state == `decode_noupdat)
		pix_r <= pix_r_pred + res_r;
	else if(decode_state == `decode_runupdat  && rd)
		pix_r <= pix_r_a;
	else if(decode_state == `decode_pixwait && wait_updat_flag && rd)
		pix_r <= pix_r_a;
		
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		pix_g <= 0;
	else if(quic_dec_state == `quic_dec_set)
		pix_g <= 0;	
	else 
	if(updat_state == `updat_updat  || decode_state == `decode_noupdat)
		pix_g <= pix_g_pred + res_g;
	else if(decode_state == `decode_runupdat  && rd)
		pix_g <= pix_g_a;
	else if(decode_state == `decode_pixwait && wait_updat_flag && rd)
		pix_g <= pix_g_a;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		pix_b <= 0;
	else if(quic_dec_state == `quic_dec_set)
		pix_b <= 0;	
	else 
	if(updat_state == `updat_updat  || decode_state == `decode_noupdat)
		pix_b <= pix_b_pred + res_b;
	else if(decode_state == `decode_runupdat && rd )
		pix_b <= pix_b_a;
	else if(decode_state == `decode_pixwait && wait_updat_flag && rd)
		pix_b <= pix_b_a;
		

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		pix_r_a <= 0;
	else if(quic_dec_state == `quic_dec_set)
		pix_r_a <= 0;	
	else if(updat_state == `updat_updat  || decode_state == `decode_noupdat)
		pix_r_a <= pix_r_pred + res_r;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		pix_g_a <= 0;
	else if(quic_dec_state == `quic_dec_set)
		pix_g_a <= 0;		
	else if(updat_state == `updat_updat  || decode_state == `decode_noupdat)
		pix_g_a <= pix_g_pred + res_g;


always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		pix_b_a <= 0;
	else if(quic_dec_state == `quic_dec_set)
		pix_b_a <= 0;		
	else if(updat_state == `updat_updat  || decode_state == `decode_noupdat)
		pix_b_a <= pix_b_pred + res_b;


reg [11:0] pix_up_addr;
reg [11:0] pix_up_addr_w;
reg [7:0] pix_up_r_datain,pix_up_g_datain,pix_up_b_datain;
reg pix_up_we;
   

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		pix_up_addr <= 0;
	else if(quic_dec_state == `quic_dec_set)
		pix_up_addr <= 0;	
	else
		pix_up_addr <= column[11:0];

always@(updat_state or decode_state or pix_r_pred or pix_g_pred or pix_b_pred or 
	pix_up_addr or res_r or pix_r_a or column or res_g or pix_g_a or res_b or pix_b_a)
	if(updat_state == `updat_updat  || decode_state == `decode_noupdat)begin
		pix_up_we = 1;
		pix_up_r_datain = pix_r_pred + res_r;
		pix_up_g_datain = pix_g_pred + res_g;
		pix_up_b_datain = pix_b_pred + res_b;
		pix_up_addr_w = pix_up_addr;end
	else if(decode_state == `decode_runupdat)begin
		pix_up_we = 1;
		pix_up_r_datain = pix_r_a;
		pix_up_g_datain = pix_g_a;
		pix_up_b_datain = pix_b_a;
		pix_up_addr_w = column[11:0];end
	else begin
		pix_up_we = 0;
		pix_up_r_datain = 0;
		pix_up_g_datain = 0;
		pix_up_b_datain = 0;
		pix_up_addr_w = 0;end
		

		
wire [11:0] pix_b_addr;	
wire pix_b_rd;

dpram #(12,8)
	pix_r_up(
	// Generic synchronous double-port RAM interface
	.clk_a(clk), .rst_a(~reset_n), .ce_a(1'b1), .oe_a(pix_b_rd), 
	.addr_a(pix_b_addr), .do_a(pix_r_b),
	.clk_b(clk), .rst_b(~reset_n), .ce_b(1'b1), .we_b(pix_up_we), 
	.addr_b(pix_up_addr_w), .di_b(pix_up_r_datain)
);

dpram #(12,8)
	pix_g_up(
	// Generic synchronous double-port RAM interface
	.clk_a(clk), .rst_a(~reset_n), .ce_a(1'b1), .oe_a(pix_b_rd), 
	.addr_a(pix_b_addr), .do_a(pix_g_b),
	.clk_b(clk), .rst_b(~reset_n), .ce_b(1'b1), .we_b(pix_up_we), 
	.addr_b(pix_up_addr_w), .di_b(pix_up_g_datain)
);

dpram #(12,8)
	pix_b_up(
	// Generic synchronous double-port RAM interface
	.clk_a(clk), .rst_a(~reset_n), .ce_a(1'b1), .oe_a(pix_b_rd), 
	.addr_a(pix_b_addr), .do_a(pix_b_b),
	.clk_b(clk), .rst_b(~reset_n), .ce_b(1'b1), .we_b(pix_up_we), 
	.addr_b(pix_up_addr_w), .di_b(pix_up_b_datain)
);

reg [11:0] pix_b_addr_reg;

assign pix_b_addr = quic_dec_state == `quic_dec_set ? 12'd0 : 
	(updat_state == `updat_updat  || decode_state == `decode_noupdat || decode_state == `decode_runupdat) ?
		column_pred[11:0] : pix_b_addr_reg;
assign 	pix_b_rd = 	1;//(updat_state == `updat_updat  || decode_state == `decode_noupdat || decode_state == `decode_runupdat);
		
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		pix_b_addr_reg <= 0;
	/*else if(quic_dec_state == `quic_dec_set)
		pix_b_addr_reg <= 0;*/	
	else 
		pix_b_addr_reg <= pix_b_addr;
		


always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		pix_r_c <= 0;	pix_g_c <= 0;
		pix_b_c <= 0;	end
	else if(quic_dec_state == `quic_dec_set)begin
		pix_r_c <= 0;	pix_g_c <= 0;
		pix_b_c <= 0;	end		
	else if(updat_state == `updat_updat  || decode_state == `decode_noupdat || decode_state == `decode_runupdat)begin
		pix_r_c <= pix_r_b;	pix_g_c <= pix_g_b;
		pix_b_c <= pix_b_b;	end

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		pix_r_d <= 0;	pix_g_d <= 0;
		pix_b_d <= 0;	end
	else if(quic_dec_state == `quic_dec_set)begin
		pix_r_d <= 0;	pix_g_d <= 0;
		pix_b_d <= 0;	end	
	else if(updat_state == `updat_updat  || decode_state == `decode_noupdat || decode_state == `decode_runupdat)begin
		pix_r_d <= pix_r_a;	pix_g_d <= pix_g_a;
		pix_b_d <= pix_b_a;	end	
		
		
endmodule
