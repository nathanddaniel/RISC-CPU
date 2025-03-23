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
			
		  // Hardcoded instructions
		  ram[9'h00] = 32'h08005400;  // ld R4, 0x54
		  ram[9'h01] = 32'h0C863000;  // ld R6, 0x63(R2)
        ram[9'h02] = 32'h14054000;  // ldi R4, 0x54
        ram[9'h03] = 32'h16263000;  // ldi R6, 0x63(R2)
        ram[9'h04] = 32'h23034000;  // st 0x34, R3
        ram[9'h05] = 32'h23334000;  // st 0x34(R3), R3
		  
		  // Hardcoded memory values
		  ram[9'h054] = 32'h00000097;  // Data at RAM[0x54] = 0x97
        ram[9'h078] = 32'h00000078;  // R2 contains 0x78
        ram[9'h0DB] = 32'h00000046;  // Data at RAM[0xDB] = 0x46
        ram[9'h034] = 32'h00000025;  // Data at RAM[0x34] = 0x25 (before store)
        ram[9'h0EA] = 32'h00000019;  // Data at RAM[0xEA] = 0x19 (before store)
		  

 
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