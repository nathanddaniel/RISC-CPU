module div(input signed [31:0] A, B, output reg [63:0] result);
	reg [31:0] upper, lower;
	always @ (*)
	begin
		upper = A % B;
		lower = (A - upper) / B;
		begin
			result = {upper, lower};
		end
	end
				
endmodule