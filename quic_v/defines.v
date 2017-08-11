`define rst_quic_dec 		3'b000
`define quic_dec_header		3'b001
`define quic_dec_init		3'b010
`define quic_dec_decode		3'b011
`define quic_dec_set		3'b111




`define rst_header_state	3'b000
`define header_quic			3'b001
`define header_version		3'b010
`define header_type			3'b011
`define header_width		3'b100
`define header_height  	3'b101


`define rst_decode_state	4'b0000 
`define decode_noupdat		4'b0001
`define decode_golomb_r		4'b0010
`define decode_golomb_g		4'b0011
`define decode_golomb_b		4'b0100
//`define decode_store		4'b0101
`define decode_updat		4'b0110
`define decode_run		4'b0111
`define decode_hit		4'b1000
`define decode_len		4'b1001
`define decode_runupdat		4'b1010
`define decode_wewait		4'b1011
`define decode_pixwait		4'b1100
`define decode_runwait		4'b1101
`define decode_runupdat_wait	4'b1110

`define rst_updat_state		3'b000
`define updat_bestcode		3'b011
`define updat_updat			3'b100