module mdr(
	input clear, clock, MDRin, read,
	input [31:0] BusMuxOut,
	input [31:0] Mdatain, 
	output wire [31:0] BusMuxIn
); 
	
	reg [31:0]q;
	
	always @ (posedge clock) begin
		
		if (clear) begin
			//if clear is active, reset MDR
			q <= 32'b0;
		end
		
		else if (MDRin) begin
		
			if (read) begin
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