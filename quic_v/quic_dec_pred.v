`include "timescale.v"
`include "defines.v"

module quic_dec_pred(
input clk,reset_n,
input [2:0] quic_dec_state,
input [3:0] decode_state,
input [15:0] row,column,
input [7:0] pix_r_a,pix_r_b,
input [7:0] pix_g_a,pix_g_b,
input [7:0] pix_b_a,pix_b_b,
input [7:0] pix_r_c,pix_r_d,
input [7:0] pix_g_c,pix_g_d,
input [7:0] pix_b_c,pix_b_d,
input [31:0] bitstream_output,

output reg [7:0] pix_r_pred,
output reg [7:0] pix_g_pred,
output reg [7:0] pix_b_pred,

output run


);

reg [15:0] column_run;
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)	
		column_run <= 0;
	else if(quic_dec_state == `quic_dec_set)
		column_run <= 0;	
	else if(decode_state == `decode_run)
		column_run <= column;
	else if(column == 16'd0)
		column_run <= 0;


assign run = decode_state == `rst_decode_state && (pix_r_a == pix_r_d) && column_run != column &&
			(pix_g_a == pix_g_d) && (pix_b_a == pix_b_d) && (pix_r_c == pix_r_b) && 
			(pix_g_c == pix_g_b) && (pix_b_c == pix_b_b) && column > 16'd2 && row != 0;


wire [8:0] pred_r_2_tmp,pred_g_2_tmp,pred_b_2_tmp;
assign pred_r_2_tmp = {1'd0,pix_r_a} + {1'd0,pix_r_b}; 
assign pred_g_2_tmp = {1'd0,pix_g_a} + {1'd0,pix_g_b}; 
assign pred_b_2_tmp = {1'd0,pix_b_a} + {1'd0,pix_b_b}; 


always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		pix_r_pred <= 0;
	else if(quic_dec_state == `quic_dec_set)
		pix_r_pred <= 0;	
	else if(decode_state == `decode_golomb_r)begin
		if(column == 0 && row == 0)
			pix_r_pred <= 0;
		else if(row == 0)
			pix_r_pred <= pix_r_a;
		else if(column == 0)
			pix_r_pred <= pix_r_b;
		else 
			pix_r_pred <= pred_r_2_tmp[8:1] ;
			
	end

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		pix_g_pred <= 0;
	else if(quic_dec_state == `quic_dec_set)
		pix_g_pred <= 0;		
	else if(decode_state == `decode_golomb_g)begin
		if(column == 0 && row == 0)
			pix_g_pred <= 0;
		else if(row == 0)
			pix_g_pred <= pix_g_a;
		else if(column == 0)
			pix_g_pred <= pix_g_b;
		else 
			pix_g_pred <= pred_g_2_tmp[8:1] ;
			
	end

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		pix_b_pred <= 0;
	else if(quic_dec_state == `quic_dec_set)
		pix_b_pred <= 0;	
	else if(decode_state == `decode_golomb_b)begin
		if(column == 0 && row == 0)
			pix_b_pred <= 0;
		else if(row == 0)
			pix_b_pred <= pix_b_a;
		else if(column == 0)
			pix_b_pred <= pix_b_b;
		else 
			pix_b_pred <= pred_b_2_tmp[8:1] ;
			
	end


	
	
	
/*wire [15:0] pred_8_noclip,pred_7_noclip,pred_6_noclip;
wire [15:0] pred_5_noclip,pred_4_noclip;
wire [7:0] pred_8,pred_7,pred_6;
wire [7:0] pred_5,pred_4,pred_3;
wire [7:0] pred_2,pred_1,pred_0;*/


	
/*

assign pred_8_noclip = (({7'd0,pix_a,1'b0} + {7'd0,pix_b,1'b0})  + ({8'd0,pix_a} + {8'd0,pix_b}) - {7'd0,pix_c,1'b0}) >> 2;
assign pred_8 = (pred_8_noclip[10] == 1) ? 8'd0 : (pred_8_noclip[9:0] > 10'd255) ?
		8'd255 : pred_8_noclip[7:0];

		
assign pred_7_noclip = ({8'd0,pix_a} + {8'd0,pix_b}) >> 1 ;
assign pred_7 = (pred_7_noclip[10] == 1) ? 8'd0 : (pred_7_noclip[9:0] > 10'd255) ?
		8'd255 : pred_7_noclip[7:0];	


wire [15:0] a_minu_c,b_minu_c;
assign a_minu_c = {8'd0,pix_a} - {8'd0,pix_c};
assign b_minu_c = {8'd0,pix_b} - {8'd0,pix_c};
		
assign pred_6_noclip	= {8'd0,pix_b}	+ {a_minu_c[15],a_minu_c[15:1]};
assign pred_6 = (pred_6_noclip[10] == 1) ? 8'd0 : (pred_6_noclip[9:0] > 10'd255) ?
		8'd255 : pred_6_noclip[7:0];			
		
assign pred_5_noclip	= {8'd0,pix_a}	+ {b_minu_c[15],b_minu_c[15:1]};
assign pred_5 = (pred_5_noclip[10] == 1) ? 8'd0 : (pred_5_noclip[9:0] > 10'd255) ?
		8'd255 : pred_5_noclip[7:0];	
		
assign pred_4_noclip = {8'd0,pix_a}	+ b_minu_c;
assign pred_4 = (pred_4_noclip[10] == 1) ? 8'd0 : (pred_4_noclip[9:0] > 10'd255) ?
		8'd255 : pred_4_noclip[7:0];	

assign pred_3 = pix_c;
assign pred_2 = pix_b;	
assign pred_1 = pix_a;
assign pred_0 = 0;
		
*/		
endmodule
