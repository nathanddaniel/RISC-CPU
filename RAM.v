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
		ram[9'h00] = 32'h02000054;  // ld R4, 0x54
		ram[9'h01] = 32'h03100063; // ld R6, 0x63(R2)
        ram[9'h02] = 32'h0A000054; // ldi R4, 0x54
        ram[9'h03] = 32'h0B100063; // ldi R6, 0x63(R2)
        ram[9'h04] = 32'h10180034; // st 0x34, R3
        ram[9'h05] = 32'h11980034; // st 0x34(R3), R3
		ram[9'h06] = 32'h98800027; // brzr R1, 27
		ram[9'h07] = 32'h98880027; // brnz R1, 27
		ram[9'h08] = 32'h98900027; // brpl R1, 27
		ram[9'h09] = 32'h98980027; // brmi R1, 27
		ram[9'h10] = 32'h62B7FFF9; // addi R5, R6, -7
		ram[9'h11] = 32'h72B00095; // ori R5, R6, 0x95
		ram[9'h12] = 32'h6AB00095; // andi R5, R6, 0x95
		ram[9'h13] = 32'hAC000000; // jr R8
		ram[9'h14] = 32'hA2C00000; // jal R5
		ram[9'h15] = 32'hC1000000; // mflo R2
		ram[9'h16] = 32'hC9800000; // mfhi R3
		ram[9'h17] = 32'hBB000000; // out R6
		ram[9'h18] = 32'hB1800000; // in R3
		  
		  
		// Hardcoded memory values
		ram[9'h054] = 32'h00000097;  // Data at RAM[0x54] = 0x97
        ram[9'h078] = 32'h00000078;  // R2 contains 0x78
        ram[9'h0DB] = 32'h00000046;  // Data at RAM[0xDB] = 0x46
        ram[9'h034] = 32'h00000025;  // Data at RAM[0x34] = 0x25 (before store)
        ram[9'h0EA] = 32'h00000019;  // Data at RAM[0xEA] = 0x19 (before store)
    end
	
	always @ (Clock) begin
	
		if (Write) begin
		
			//if write signal is high, we will write data to that address
			ram[Address] <= Mdatain;
		end
		
		if (Read) begin
			//if read signal is high we will read data from that address
			data_output <= ram[Address]; //ram[Address];
		end
	end
	
endmodule