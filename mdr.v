module mdr(
	input Clear, 
	input Clock, 
	input MDRin, 
	input Read,
	input [31:0] BusMuxOut,
	input [31:0] Mdatain, 
	output wire [31:0] BusMuxIn,		//tri-state logic controlled by MDRout
	output wire [31:0] MDRout			//drives data to RAM
);
	
	reg [31:0] q;							//mdr register
	
	always @ (posedge Clock) begin
		
		if (Clear) 
			q <= 32'b0;

		else if (MDRin) begin
			if (Read)
				q <= Mdatain;			//loading from RAM
			else 
				q <= BusMuxOut;		//loading from Bus
		end
	end
				
	// Tri-state buffer for BusMuxIn (only drive bus when MDRout=1)
   assign BusMuxIn = (MDRout) ? q : 32'bz;

   // Directly connect MDRout to RAM (no tri-state needed here)
   assign MDRout = q;
	
endmodule
