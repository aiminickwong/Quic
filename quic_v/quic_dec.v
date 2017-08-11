`include "timescale.v"
`include "defines.v"

module quic_dec(
input clk,reset_n,
input [31:0] bitstream_input,
input we,rd,
input last_word,
output next,


output [7:0] pix_r,pix_g,pix_b,
output reg [15:0] row_o,column_o,

output quic_dec_header_end,
output reg decode_end,pix_end,

output [15:0] width,height
);


wire [2:0] quic_dec_state;
wire [2:0] header_state;
wire [3:0] decode_state;
wire [2:0] updat_state;
wire quic_dec_decode_end,decode_pix_end;

wire [15:0] row,column;
wire [15:0] column_pred,row_pred;
wire [31:0] quic;
wire [31:0] version;
wire [7:0] type_4;


wire [7:0] pix_r_pred,pix_g_pred,pix_b_pred;
wire [7:0] context_cur_r;
wire [7:0] context_cur_g;
wire [7:0] context_cur_b;
wire [2:0] bestcode;

wire [31:0] nGRcodewords_i; 
wire [31:0] notGRcwlen_i; 
wire [31:0] notGRprefixmask_i;
wire [31:0] notGRsuffixlen_i;

wire [31:0] nGRcodewords_0,nGRcodewords_1,nGRcodewords_2,nGRcodewords_3; 
wire [31:0] nGRcodewords_4,nGRcodewords_5,nGRcodewords_6,nGRcodewords_7;
wire [31:0] notGRcwlen_0,notGRcwlen_1,notGRcwlen_2,notGRcwlen_3; 
wire [31:0] notGRcwlen_4,notGRcwlen_5,notGRcwlen_6,notGRcwlen_7;

wire [7:0] golomb_output;
wire [5:0] golomb_len;


wire [7:0] pix_r_a,pix_r_b;
wire [7:0] pix_g_a,pix_g_b;
wire [7:0] pix_b_a,pix_b_b;

wire [7:0] pix_r_c,pix_r_d;
wire [7:0] pix_g_c,pix_g_d;
wire [7:0] pix_b_c,pix_b_d;

wire [7:0] jump_count;
wire [15:0] wm_trigger;
wire [2:0] wmidx;

wire [31:0] pc,pc_delta,pc_reg;
wire [31:0] bitstream_output;

wire full;
wire run;
wire wait_updat_flag;

wire [4:0] hit_temp;
wire [4:0] run_len;
wire [15:0] run_i,run_i_tmp;
wire [2:0] wewait_flag;

always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		row_o <= 0;	column_o <= 0;end
	else begin
		row_o <= row;	column_o <= column;end


always@(posedge clk or negedge reset_n)
	if(reset_n == 0)begin
		pix_end <= 0;
		decode_end <= 0;end
	else begin
		pix_end <= decode_pix_end;
		decode_end <= quic_dec_decode_end;end


quic_dec_bitbuffer quic_dec_bitbuffer(
	.clk(clk),.reset_n(reset_n),
	.last_word(last_word),
	.bitstream_input(bitstream_input),
	.we(we),
	.pc(pc),.pc_delta(pc_delta),.pc_reg(pc_reg),
	.quic_dec_state(quic_dec_state),
	.bitstream_output(bitstream_output),
	.next(next),.full(full)

);		
		
		
		
		
quic_dec_fsm quic_dec_fsm(
	.clk(clk),.reset_n(reset_n),
	.width(width),.height(height),
	.row(row),.column(column),
	.column_pred(column_pred),.row_pred(row_pred),
	.jump_count(jump_count),.full(full),.rd(rd),
	.run(run),.hit_temp(hit_temp),.run_i(run_i),
	.run_i_tmp(run_i_tmp),
	.quic_dec_state(quic_dec_state),
	.header_state(header_state),
	.decode_state(decode_state),
	.updat_state(updat_state),
	.wewait_flag(wewait_flag),
	.quic_dec_header_end(quic_dec_header_end),
	.decode_pix_end(decode_pix_end),
	.wait_updat_flag(wait_updat_flag),
	.quic_dec_decode_end(quic_dec_decode_end)
);

quic_dec_head quic_dec_head(
	.clk(clk),.reset_n(reset_n),
	.bitstream_output(bitstream_output),
	.header_state(header_state),
	.quic_dec_state(quic_dec_state),
	.quic(quic),.version(version),
	.type_4(type_4),
	.width(width),.height(height)
);

quic_dec_pc quic_dec_pc(
	.clk(clk),.reset_n(reset_n),
	.quic_dec_state(quic_dec_state),
	.header_state(header_state),
	.decode_state(decode_state),
	.golomb_len(golomb_len),.full(full),
	.wewait_flag(wewait_flag),
	.run_len(run_len),
	.pc(pc),.pc_delta(pc_delta),.pc_reg(pc_reg)
);

quic_dec_ini quic_dec_ini(
	.clk(clk),.reset_n(reset_n),
	.bestcode(bestcode),
	.quic_dec_state(quic_dec_state),
	.wmidx(wmidx),
	.nGRcodewords_i(nGRcodewords_i),
	.notGRcwlen_i(notGRcwlen_i),
	.notGRprefixmask_i(notGRprefixmask_i),
	.notGRsuffixlen_i(notGRsuffixlen_i),
	
	.nGRcodewords_0(nGRcodewords_0),.nGRcodewords_1(nGRcodewords_1),
	.nGRcodewords_2(nGRcodewords_2),.nGRcodewords_3(nGRcodewords_3),
	.nGRcodewords_4(nGRcodewords_4),.nGRcodewords_5(nGRcodewords_5),
	.nGRcodewords_6(nGRcodewords_6),.nGRcodewords_7(nGRcodewords_7),
	.notGRcwlen_0(notGRcwlen_0),.notGRcwlen_1(notGRcwlen_1),
	.notGRcwlen_2(notGRcwlen_2),.notGRcwlen_3(notGRcwlen_3),
	.notGRcwlen_4(notGRcwlen_4),.notGRcwlen_5(notGRcwlen_5),
	.notGRcwlen_6(notGRcwlen_6),.notGRcwlen_7(notGRcwlen_7),
	.wm_trigger(wm_trigger)
	
);

quic_dec_pred quic_dec_pred(
	.clk(clk),.reset_n(reset_n),
	.quic_dec_state(quic_dec_state),
	.decode_state(decode_state),
	.bitstream_output(bitstream_output),
	.row(row),.column(column),
	.pix_r_a(pix_r_a),.pix_r_b(pix_r_b),
	.pix_g_a(pix_g_a),.pix_g_b(pix_g_b),
	.pix_b_a(pix_b_a),.pix_b_b(pix_b_b),
	.pix_r_c(pix_r_c),.pix_r_d(pix_r_d),
	.pix_g_c(pix_g_c),.pix_g_d(pix_g_d),
	.pix_b_c(pix_b_c),.pix_b_d(pix_b_d),
	.pix_r_pred(pix_r_pred),
	.pix_g_pred(pix_g_pred),
	.pix_b_pred(pix_b_pred),
	.run(run)
);

quic_dec_golomb quic_dec_golomb(
	.clk(clk),.reset_n(reset_n),
	.bitstream_output(bitstream_output),
	.decode_state(decode_state),
	.bestcode(bestcode),
	.nGRcodewords_i(nGRcodewords_i),
	.notGRcwlen_i(notGRcwlen_i),
	.notGRprefixmask_i(notGRprefixmask_i),
	.notGRsuffixlen_i(notGRsuffixlen_i),
	

	.golomb_output(golomb_output),
	.golomb_len(golomb_len)

);


quic_dec_updat quic_dec_updat(
	.clk(clk),.reset_n(reset_n),
	.quic_dec_state(quic_dec_state),
	.decode_state(decode_state),
	.updat_state(updat_state),
	.wm_trigger(wm_trigger),
	.golomb_output(golomb_output),
	.row(row),.column(column),
	.column_pred(column_pred),.row_pred(row_pred),
	.width(width),.height(height),
	.nGRcodewords_0(nGRcodewords_0),.nGRcodewords_1(nGRcodewords_1),
	.nGRcodewords_2(nGRcodewords_2),.nGRcodewords_3(nGRcodewords_3),
	.nGRcodewords_4(nGRcodewords_4),.nGRcodewords_5(nGRcodewords_5),
	.nGRcodewords_6(nGRcodewords_6),.nGRcodewords_7(nGRcodewords_7),
	.notGRcwlen_0(notGRcwlen_0),.notGRcwlen_1(notGRcwlen_1),
	.notGRcwlen_2(notGRcwlen_2),.notGRcwlen_3(notGRcwlen_3),
	.notGRcwlen_4(notGRcwlen_4),.notGRcwlen_5(notGRcwlen_5),
	.notGRcwlen_6(notGRcwlen_6),.notGRcwlen_7(notGRcwlen_7),
	.context_cur_r(context_cur_r),
	.context_cur_g(context_cur_g),
	.context_cur_b(context_cur_b),
	.bestcode(bestcode),.wmidx(wmidx),
	.jump_count(jump_count)
);

quic_dec_rec quic_dec_rec(
	.clk(clk),.reset_n(reset_n),
	.rd(rd),
	.quic_dec_state(quic_dec_state),
	.decode_state(decode_state),
	.updat_state(updat_state),
	.wait_updat_flag(wait_updat_flag),
	.context_cur_r(context_cur_r),
	.context_cur_g(context_cur_g),
	.context_cur_b(context_cur_b),
	.width(width),.height(height),
	.row(row),.column(column),
	.column_pred(column_pred),.row_pred(row_pred),
	.pix_r_pred(pix_r_pred),
	.pix_g_pred(pix_g_pred),
	.pix_b_pred(pix_b_pred),
	.pix_r(pix_r),.pix_g(pix_g),.pix_b(pix_b),
	.pix_r_a(pix_r_a),.pix_r_b(pix_r_b),
	.pix_g_a(pix_g_a),.pix_g_b(pix_g_b),
	.pix_b_a(pix_b_a),.pix_b_b(pix_b_b),
	.pix_r_c(pix_r_c),.pix_r_d(pix_r_d),
	.pix_g_c(pix_g_c),.pix_g_d(pix_g_d),
	.pix_b_c(pix_b_c),.pix_b_d(pix_b_d)


);




quic_dec_run quic_dec_run(
	.clk(clk),.reset_n(reset_n),
	.quic_dec_state(quic_dec_state),
	.decode_state(decode_state),
	.bitstream_output(bitstream_output),
	.hit_temp(hit_temp),
	.run_len(run_len),
	.run_i(run_i),.run_i_tmp(run_i_tmp)
);

endmodule
