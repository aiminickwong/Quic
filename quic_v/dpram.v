
module dpram(
	// Generic synchronous double-port RAM interface
	clk_a, rst_a, ce_a, oe_a, addr_a, do_a,
	clk_b, rst_b, ce_b, we_b, addr_b, di_b
);
parameter aw = 1;
parameter dw = 1;

//
// Generic synchronous double-port RAM interface
//
input			clk_a;	// Clock
input			rst_a;	// Reset
input			ce_a;	// Chip enable input
input			oe_a;	// Output enable input
input 	[aw-1:0]	addr_a;	// address bus inputs
output	[dw-1:0]	do_a;	// output data bus
input			clk_b;	// Clock
input			rst_b;	// Reset
input			ce_b;	// Chip enable input
input			we_b;	// Write enable input
input 	[aw-1:0]	addr_b;	// address bus inputs
input	[dw-1:0]	di_b;	// input data bus

//
// Generic double-port synchronous RAM model
//

//
// Generic RAM's registers and wires
//
reg	[dw-1:0]	mem [(1<<aw)-1:0];	// RAM content
reg	[aw-1:0]	addr_a_reg;		// RAM address registered

//
// Data output drivers
//
assign do_a = (oe_a) ? mem[addr_a_reg] : {dw{1'b0}};

//
// RAM read
//
always @(posedge clk_a )
	if (rst_a)
		addr_a_reg <=  {aw{1'b0}};
	else if (ce_a)
		addr_a_reg <=  addr_a;

//
// RAM write
//
always @(posedge clk_b)
	if (ce_b && we_b)
		mem[addr_b] <=  di_b;

endmodule
