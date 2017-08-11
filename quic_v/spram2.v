module spram2(/*AUTOARG*/
   // Outputs
   ao_data,
   // Inputs
   clk, rst, ai_ce, ai_we, ai_oe, ai_addr, ai_data
   );

   //
   // Default address and data buses width
   //
   parameter aw = 1;
   parameter dw = 1;

   //
   // Generic synchronous single-port RAM interface
   //
   input			clk;	// Clock
   input                        rst;
   input			ai_ce;	// Chip enable input
   input			ai_we;	// Write enable input
   input			ai_oe;	// Output enable input
   input [aw-1:0]               ai_addr;	// address bus inputs
   input [dw-1:0]               ai_data;	// input data bus
   output [dw-1:0]              ao_data;	// output data bus

   //
   // Generic single-port synchronous RAM model
   //

   //
   // Generic RAM's registers and wires
   //
   reg [dw-1:0]                 mem [(1<<aw)-1:0];	// RAM content
   reg [aw-1:0]                 addr_reg;		// RAM address register

   //
   // Data output drivers
   //
   assign ao_data = (ai_oe) ? mem[addr_reg] : {dw{1'bz}};

   //
   // RAM address register
   //

   always @(posedge clk) 
     if (ai_ce)
       addr_reg <=  ai_addr;

   //
   // RAM write
   //
   always @(posedge clk)
     if (ai_ce && ai_we)
       mem[ai_addr] <=  ai_data;

endmodule
