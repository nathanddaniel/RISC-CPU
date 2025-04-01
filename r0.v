// not tested needs check
`timescale 1ns/1ps

module r0 (
    input clear, clock, enable, BAout, 
    input [31:0] BusMuxOut,
    output wire [31:0] BusMuxIn
);
    reg [31:0] q;

    always @(clock) begin
		  if (BAout && enable) 
			   q <= 32'b0;
        else if (clear)
            q <= 32'b0;
        else if (enable) 
            q <= BusMuxOut;
    end
endmodule