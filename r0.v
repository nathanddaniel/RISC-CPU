// not tested needs check
`timescale 1ns/1ps

module r0(
	input  wire        clear,
   input  wire        clock,
   input  wire        enable,       // R0in
   input  wire [31:0] BusMuxOut,
   input  wire        BAout,			 
   output wire [31:0] BusMuxInR0
);

   reg [31:0] q;

   always @(posedge clock) begin
		if (clear) begin
			q <= 32'd0;
		end
      else if (enable) begin
         q <= BusMuxOut;
      end
   end

   // If BAout=1, pass the stored value; otherwise, drive zero
	// THIS SIGNAL MIGHT BE FLIPPED PLEASE CHECK
   assign BusMuxInR0 = (BAout) ? q : 32'd0;

endmodule