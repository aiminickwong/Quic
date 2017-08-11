// 发送方 sender 每隔 SS 个时钟产生一个数
// 接收方 reciver 每隔 RR 个时钟收一个数
// 你可自己调整 RR 和 SS , 看它们是怎么工作的.

module sender(/*AUTOARG*/
   // Outputs
   ao_we, ao_data,
   // Inputs
   clk, rst, ai_next
   );
   input                   clk;   // clock  
   input                   rst;   // reset  
   
   output                  ao_we;
   input                   ai_next;         
   output [7:0]            ao_data;          

`define SS 20
 reg flag;  
   reg [7:0]               counter;
   always @(posedge clk) begin   
      if (rst)
        counter <= 0;
      else begin
         if (counter < `SS) counter <= counter + 1;
         else if (ao_we && ai_next)  counter <= 0;
      end
   end
   wire       ao_we   = (counter == `SS) || flag == 1;


always@(posedge clk)
	if (rst)
		flag <= 0;
	else if(counter == `SS)
		flag <= 1;

   reg [7:0] data;
   always @(posedge clk) begin   
      if (rst)
        data <= 88;
      else
        if (ao_we && ai_next) data <= data + 1;
   end

   wire [7:0] ao_data = data;
   
endmodule // sender

module reciver(/*AUTOARG*/
   // Outputs
   ao_next,
   // Inputs
   clk, rst, ai_we, ai_data
   );
   input                   clk;   // clock  
   input                   rst;   // reset  
   
   input                   ai_we;
   output                  ao_next;         
   input [7:0]             ai_data;          

`define RR 3

   reg [3:0]               counter;
   always @(posedge clk) begin   
      if (rst)
        counter <= 0;
      else begin
         if (counter < `RR) counter <= counter + 1;
         else if (ao_next && ai_we)  counter <= 0;
      end
   end
   wire       ao_next   = (counter == `RR);

   always @(posedge clk) begin   
      if (ai_we && ao_next) $display(ai_data);
   end
   
endmodule // reciver


module tb(/*AUTOARG*/);

   reg    clk;   
   initial begin
      clk <= 1'b0;
      forever #(50) begin
         clk <= ~clk;
      end
   end

   initial begin
      $dumpfile("tb.vcd");
      $dumpvars;
   end

   initial begin
      #(100000);     
      $finish;
   end

   reg rst;
   initial begin   
      rst <= 0;      
      @(posedge clk) ;      
      rst <= 1;
      @(posedge clk) ;
      @(posedge clk) ;      
      rst <= 0;      
      @(posedge clk) ;
   end // initial begin

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 r_ao_next;              // From r of reciver.v
   wire [7:0]           s_ao_data;              // From s of sender.v
   wire                 s_ao_we;                // From s of sender.v
   // End of automatics
   
   /* sender AUTO_TEMPLATE (
    .ai_\(.*\)       (r_ao_\1),       
    .ao_\(.*\)       (@"vl-cell-name"_ao_\1[]),       
    );*/   

   /* reciver AUTO_TEMPLATE (
    .ai_\(.*\)       (s_ao_\1),       
    .ao_\(.*\)       (@"vl-cell-name"_ao_\1[]),       
    );*/   
   
   sender s(/*AUTOINST*/
            // Outputs
            .ao_we                      (s_ao_we),               // Templated
            .ao_data                    (s_ao_data[7:0]),        // Templated
            // Inputs
            .clk                        (clk),
            .rst                        (rst),
            .ai_next                    (r_ao_next));             // Templated
   
   reciver r(/*AUTOINST*/
             // Outputs
             .ao_next                   (r_ao_next),             // Templated
             // Inputs
             .clk                       (clk),
             .rst                       (rst),
             .ai_we                     (s_ao_we),               // Templated
             .ai_data                   (s_ao_data));             // Templated
   
endmodule // reciver
