`include "timescale.v"
`include "defines.v"

module quic_dec_fsm(
input clk,reset_n,
input [15:0] width,height,
input full,rd,
input [7:0] jump_count,
input run,
input [15:0] run_i,run_i_tmp,
input [4:0] hit_temp,

output reg [15:0] row,column,
output reg [15:0] column_pred,row_pred,
output reg [2:0] quic_dec_state,
output reg [2:0] header_state,
output reg [3:0] decode_state,
output reg [2:0] updat_state,
output reg [2:0] wewait_flag,
output reg wait_updat_flag,

output quic_dec_header_end,

output decode_pix_end,quic_dec_decode_end
);


wire decode_updat_end;
assign decode_pix_end = updat_state == `updat_updat || decode_state == `decode_noupdat || 
			(decode_state == `decode_runupdat) || 
			(decode_state == `decode_pixwait && wait_updat_flag) ||
			(decode_state == `decode_pixwait && wait_updat_flag == 0 && rd == 0) ||
			(decode_state == `decode_runwait && rd == 0);
assign decode_updat_end = updat_state == `updat_updat;
assign quic_dec_header_end = header_state == `header_height && full;
assign quic_dec_decode_end = ((decode_state == `decode_updat && decode_updat_end) || decode_state == `decode_noupdat || decode_state == `decode_runupdat ) 
			 && column == width - 16'd1 && row == height - 16'd1;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		quic_dec_state <= `rst_quic_dec;
	else 
		case(quic_dec_state)
		`rst_quic_dec:			quic_dec_state <= `quic_dec_header ;
		`quic_dec_header:		quic_dec_state <= quic_dec_header_end ? `quic_dec_init : `quic_dec_header;
		`quic_dec_init:			quic_dec_state <= `quic_dec_decode;
		`quic_dec_decode:		quic_dec_state <= quic_dec_decode_end ? `quic_dec_set : `quic_dec_decode;
		`quic_dec_set:			quic_dec_state <= `rst_quic_dec;
		default:;
		endcase


		


always@(posedge clk or negedge reset_n)
	if(reset_n == 0)	
		header_state <= `rst_header_state;
	else if(quic_dec_state == `quic_dec_header && full)
		case(header_state)
		`rst_header_state:	header_state <= `header_quic;
		`header_quic:			header_state <= `header_version;
		`header_version:		header_state <= `header_type;
		`header_type:			header_state <= `header_width;
		`header_width:			header_state <= `header_height;
		`header_height:		header_state <= `rst_header_state;
		default:;
		endcase
		
reg [4:0] hit,hit_temp_r;
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		hit <= 0;
	else if(quic_dec_state == `quic_dec_set)
		hit <= 0;
	else if(decode_state == `decode_run)
		hit <= 5'd1;
	else if(decode_state == `decode_hit)
		hit <= hit + 5'd1;
		
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		hit_temp_r <= 0;
	else if(quic_dec_state == `quic_dec_set)
		hit_temp_r <= 0;	
	else if(decode_state == `decode_run)
		hit_temp_r <= hit_temp;
		
reg [15:0] i_run;
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		i_run <= 0;
	else if(quic_dec_state == `quic_dec_set)
		i_run <= 0;	
	else if(decode_state == `decode_len)
		i_run <= 0;
	else if(decode_state == `decode_runupdat)
		i_run <= i_run + 16'd1;
		
reg [4:0] hit_temp_wewait;
reg [15:0] run_i_tmp_wewait;
reg rd_flag;
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)	
		decode_state <= `rst_decode_state;
	else if(quic_dec_state == `quic_dec_decode)
		case(decode_state)
		`rst_decode_state:	decode_state <=  full ? ( run ? `decode_run :
				`decode_golomb_r ) : `rst_decode_state;
		`decode_golomb_r:		decode_state <= full ? `decode_golomb_g : `decode_wewait;
		`decode_golomb_g:		decode_state <= full ? `decode_golomb_b : `decode_wewait;
		`decode_golomb_b:		decode_state <= full ? (jump_count != 0 ? `decode_noupdat : `decode_updat) : `decode_wewait;
		
		//`decode_store:		decode_state <= jump_count != 0 ? `decode_noupdat : `decode_updat;
		`decode_run:		decode_state <= full ? ( hit_temp == 0 ? `decode_len : `decode_hit) : `decode_wewait;
		`decode_hit:		decode_state <= hit == hit_temp_r ? `decode_len : `decode_hit;
		`decode_len:		decode_state <= full ? (run_i_tmp == 0 ? `rst_decode_state : `decode_runupdat_wait) : `decode_wewait;
		`decode_runupdat_wait:	decode_state <= rd ? `decode_runupdat : `decode_runupdat_wait;
		`decode_runupdat:	decode_state <= rd ? (
					(i_run == run_i - 16'd1 || column == width - 16'd1) ? `decode_runwait : `decode_runupdat) :
							`decode_pixwait;
		`decode_updat:		decode_state <= decode_updat_end ? (rd ? `rst_decode_state : `decode_pixwait) : 
						`decode_updat;
		`decode_noupdat:	decode_state <= rd ? `rst_decode_state : `decode_pixwait;
		`decode_wewait:		decode_state <= full ? 
					(wewait_flag == 3'd0 ? `decode_golomb_g : 
					 wewait_flag == 3'd1 ? `decode_golomb_b :
					 wewait_flag == 3'd2 ? (jump_count != 0 ? `decode_noupdat : `decode_updat) : 
					 wewait_flag == 3'd3 ? ( hit_temp_wewait == 0 ? `decode_len : `decode_hit) :
					(run_i_tmp_wewait == 0 ? `rst_decode_state : `decode_runupdat)) : `decode_wewait;
		`decode_pixwait:	decode_state <= rd ? (rd_flag ? `decode_runupdat: 
						wait_updat_flag ? `decode_runwait : `rst_decode_state) : 
					`decode_pixwait;
		`decode_runwait:	decode_state <= rd ? `rst_decode_state : `decode_runwait;
		default:;
		endcase



always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		wait_updat_flag <= 0;
	else if(quic_dec_state == `quic_dec_set)
		wait_updat_flag <= 0;	
	else if(decode_state == `decode_runupdat && rd == 0)
		wait_updat_flag <= 1;
	else if((decode_state == `decode_updat && decode_updat_end) ||
			(decode_state == `decode_noupdat) )
		wait_updat_flag <= 0;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		rd_flag <= 0;
	else if(quic_dec_state == `quic_dec_set)
		rd_flag <= 0;	
	else if(decode_state == `decode_runupdat &&  i_run != run_i - 16'd1 && column != width - 16'd1)
		rd_flag <= 1;
	else if(((decode_state == `decode_updat && decode_updat_end) ||
		(decode_state == `decode_noupdat) || 
		(decode_state == `decode_runupdat && (i_run == run_i - 16'd1 || column == width - 16'd1))))
		rd_flag <= 0;


always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		hit_temp_wewait <= 0;
	else if(quic_dec_state == `quic_dec_set)
		hit_temp_wewait <= 0;
	else if(decode_state == `decode_run && full == 0)
		hit_temp_wewait <= hit_temp;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		run_i_tmp_wewait <= 0;
	else if(quic_dec_state == `quic_dec_set)
		run_i_tmp_wewait <= 0;
	else if(decode_state == `decode_len && full == 0)
		run_i_tmp_wewait <= run_i_tmp;



always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		wewait_flag <= 3'd0;
	else if(quic_dec_state == `quic_dec_set)
		wewait_flag <= 3'd0;	
	else if(decode_state == `decode_golomb_r && full == 0)
		wewait_flag <= 3'd0;
	else if(decode_state == `decode_golomb_g && full == 0)
		wewait_flag <= 3'd1;
	else if(decode_state == `decode_golomb_b && full == 0)
		wewait_flag <= 3'd2;
	else if(decode_state == `decode_run && full == 0)
		wewait_flag <= 3'd3;
	else if(decode_state == `decode_len && full == 0)
		wewait_flag <= 3'd4;
		
		
always@(posedge clk or negedge reset_n)
	if(reset_n == 0)
		updat_state <= `rst_updat_state;
	else if(decode_state == `decode_updat)
		case(updat_state)
		`rst_updat_state:		updat_state <= `updat_bestcode;
		`updat_bestcode:		updat_state <= `updat_updat;
		`updat_updat:			updat_state <= `rst_updat_state;
		default:;
		endcase


		
		


always@(reset_n or quic_dec_state or column or width or updat_state or decode_state or updat_state)
	if(reset_n == 0)
		column_pred = 0;
	else if(quic_dec_state == `quic_dec_set)
		column_pred = 0;
	else if(quic_dec_state == `quic_dec_init)
		column_pred = 0;
	else if(updat_state == `updat_updat ||  decode_state == `decode_noupdat || decode_state == `decode_runupdat)
		column_pred = (column == (width - 16'd1)) ? 16'd0 : column + 16'd1;
	else	
		column_pred = column;

always@(reset_n or row or quic_dec_state or updat_state or column or width or height or decode_state or updat_state)
	if(reset_n == 0)
		row_pred = 0;
	else if(quic_dec_state == `quic_dec_set)
		row_pred = 0;
	else if(quic_dec_state == `quic_dec_init)
		row_pred = 0;
	else if((updat_state == `updat_updat || decode_state == `decode_noupdat  || decode_state == `decode_runupdat) && column == (width - 16'd1))
		row_pred = (row == height - 16'd1) ? 16'd0 : row + 16'd1;
	else
		row_pred = row;
	

always@(posedge clk or negedge reset_n)	
		if(reset_n == 0)begin
			row <= 0;	column <= 0;end
		else if(quic_dec_state == `quic_dec_set)begin
				row <= 0;	column <= 0;end
		else begin
			row <= row_pred;	column <= column_pred;end
			
			

	


endmodule
