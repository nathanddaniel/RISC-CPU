module mdr(
	input Clear, 
	input Clock, 
	input MDRin, 
	input Read,
	input [31:0] BusMuxOut,
	input [31:0] Mdatain, 
	output wire [31:0] BusMuxIn,					//tri-state logic controlled by MDRout
	output wire [31:0] MDR_data_out			//drives data to RAM
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
				
   assign BusMuxIn = q;
   assign MDR_data_out = q;
	
endmodule