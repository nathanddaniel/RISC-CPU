module mdr(
	input clear, clock, enable, read,
	input [31:0] BusMuxOut,
	input [31:0] Mdatain, 
	output wire [31:0] BusMuxIn
); 
	
reg [31:0]q;
always @ (posedge clock)
		begin 
			if (clear) begin
				q <= {31{1'b0}};
			end
			else if (enable) begin
				q <= read ? Mdatain : BusMuxOut;
			end
		end
	assign BusMuxIn = q[31:0];
endmodule
