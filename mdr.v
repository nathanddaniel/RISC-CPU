module mdr(
	input Clear, Clock, MDRin, Read,
	input [31:0] BusMuxOut,
	input [31:0] Mdatain, 
	output wire [31:0] BusMuxIn
);
	
	reg [31:0]q;
	
	always @ (posedge Clock) begin
		
		if (Clear) begin
			//if clear is active, reset MDR
			q <= 32'b0;
		end
		
		else if (MDRin) begin
		
			if (Read) begin
				//reading from the RAM
				q <= Mdatain;
			end
			
			else 
				//reading from the bus
				q <= BusMuxOut;
		end
	end
				
	assign BusMuxIn = q[31:0];
	
endmodule