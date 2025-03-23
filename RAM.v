//not tested
module RAM (

	input Read, 
	input Write, 
	input Clock,
	input [31:0] Mdatain,
	input [8:0] Address,
	output reg [31:0] data_output
);

	//creating the 512 x 32-bit array in memory
	reg [31:0] ram [0:511];
	
	integer i;
	
	//Initialize RAM contents to zero
	initial begin
        for (i = 0; i < 512; i = i + 1) 
            ram[i] = 32'b0;
			
			//hard coding in values for the ld instruction
		  ram[9'h054] = 32'h00000097;  // Case 1: (0x54) = 0x97
		  ram[9'h0DB] = 32'h00000046;  // Case 2: (0xDB) = 0x46 
    end
	
	always @ (posedge Clock) begin
	
		if (Write) begin
		
			//if write signal is high, we will write data to that address
			ram[Address] <= Mdatain;
		end
		
		if (Read) begin
			//if read signal is high we will read data from that address
			data_output <= ram[Address];
		end
	end
	
endmodule