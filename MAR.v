
module MAR(
	input [31:0] BusMuxOut,
	input MARin,
	input clock,
	input clear,
	output [8:0] address
);

	reg [8:0] q;
	
	always @ (posedge clock) begin
	
		if (clear)
			//clearing the MAR to all 0s if clear is active
			q <= 9'b0;
		
		else if (MARin)
			//storing the address in MAR if MARin active
			q <= BusMuxOut[8:0];
			
	end 
	
	//outputting the lower 9 bits for RAM addressing later on
	assign address = q;
	
endmodule