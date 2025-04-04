
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
			
		//Commented out hardcoded instructions from Phase 2
		// // Hardcoded instructions
		// ram[9'h00] = 32'h02000054;  // ld R4, 0x54
		// ram[9'h01] = 32'h03100063; // ld R6, 0x63(R2)
        // ram[9'h02] = 32'h0A000054; // ldi R4, 0x54
        // ram[9'h03] = 32'h0B100063; // ldi R6, 0x63(R2)
        // ram[9'h04] = 32'h10180034; // st 0x34, R3
        // ram[9'h05] = 32'h11980034; // st 0x34(R3), R3
		// ram[9'h06] = 32'h98800027; // brzr R1, 27
		// ram[9'h07] = 32'h98880027; // brnz R1, 27
		// ram[9'h08] = 32'h98900027; // brpl R1, 27
		// ram[9'h09] = 32'h98980027; // brmi R1, 27
		// ram[9'h10] = 32'h62B7FFF9; // addi R5, R6, -7
		// ram[9'h11] = 32'h72B00095; // ori R5, R6, 0x95
		// ram[9'h12] = 32'h6AB00095; // andi R5, R6, 0x95
		// ram[9'h13] = 32'hAC000000; // jr R8
		// ram[9'h14] = 32'hA2C00000; // jal R5
		// ram[9'h15] = 32'hC1000000; // mflo R2
		// ram[9'h16] = 32'hC9800000; // mfhi R3
		// ram[9'h17] = 32'hBB000000; // out R6
		// ram[9'h18] = 32'hB1800000; // in R3
		  
		  
		// // Hardcoded memory values
		// ram[9'h054] = 32'h00000097;  // Data at RAM[0x54] = 0x97
        // ram[9'h078] = 32'h00000078;  // R2 contains 0x78
        // ram[9'h0DB] = 32'h00000046;  // Data at RAM[0xDB] = 0x46
        // ram[9'h034] = 32'h00000025;  // Data at RAM[0x34] = 0x25 (before store)
        // ram[9'h0EA] = 32'h00000019;  // Data at RAM[0xEA] = 0x19 (before store)

		//Program Instructions for Phase 3
		// ram[9'h00] = 32'h09800065; //ldi R3, 0x65
		// ram[9'h01] = 32'h09980003; //ldi R3, 3(R3)
		// ram[9'h02] = 32'h01000054; //ld  R2, 0x54
		// ram[9'h03] = 32'h09100001; //ldi R2, 1(R2)
		// ram[9'h04] = 32'h0017FFFA; //ld R0, -6(R2)
		// ram[9'h05] = 32'h08800003; //ldi R1, 3
		// ram[9'h06] = 32'h09800057; //ldi R3, 0x57
		// ram[9'h07] = 32'h99980003; //brmi R3, 3
		// ram[9'h08] = 32'h09980003; //ldi R3, 3(R3)
		// ram[9'h09] = 32'h021FFFFA; //ld R4, -6(R3)
		// ram[9'h0A] = 32'hD0000000; //nop
		// ram[9'h0B] = 32'h9A100002; //brpl R4, 2
		// ram[9'h0C] = 32'h0B180007; //ldi R6, 7(R3) -- will be skipped
		// ram[9'h0D] = 32'h0AB7FFFC; //ldi R5, -4(R6) -- will be skipped
		// ram[9'h0E] = 32'h19988000; //add R3, R3, R1
		// ram[9'h0F] = 32'h62200002; //addi R4, R4, 2
		// ram[9'h10] = 32'h8A200000; //neg R4, R4
		// ram[9'h11] = 32'h92200000; //not R4, R4
		// ram[9'h12] = 32'h6A20000F; //andi R4, R4, 0xF
		// ram[9'h13] = 32'h39008000; //ror R2, R0, R1
		// ram[9'h14] = 32'h72100007; //ori R4, R2, 7
		// ram[9'h15] = 32'h51208000; //shra R2, R4, R1
		// ram[9'h16] = 32'h49988000; //shr R3, R3, R1
		// ram[9'h17] = 32'h11800092; //st 0x92, R3
		// ram[9'h18] = 32'h41808000; //rol R3, R0, R1
		// ram[9'h19] = 32'h32880000; //or R5, R1, R0
		// ram[9'h1A] = 32'h29180000; //and R2, R3, R0
		// ram[9'h1B] = 32'h12900054; //st 0x54(R2), R5
		// ram[9'h1C] = 32'h201A8000; //sub R0, R3, R5
		// ram[9'h1D] = 32'h59188000; //shl R2, R3, R1
		// ram[9'h1E] = 32'h0A800008; //ldi R5, 8
		// ram[9'h1F] = 32'h0B000017; //ldi R6, 0x17
		// ram[9'h20] = 32'h83280000; //mul R6, R5
		// ram[9'h21] = 32'hCA000000; //mfhi R4
		// ram[9'h22] = 32'hC3800000; //mflo R7
		// ram[9'h23] = 32'h7B280000; //div R6, R5
		// ram[9'h24] = 32'h0D280001; //ldi R10, 1(R5)
		// ram[9'h25] = 32'h0DB7FFFD; //ldi R11, -3(R6)
		// ram[9'h26] = 32'h0E380001; //ldi R12, 1(R7)
		// ram[9'h27] = 32'h0EA00004; //ldi R13, 4(R4)
		// ram[9'h28] = 32'hA6000000; //jal R12
		// ram[9'h29] = 32'hD8000000; //halt

		// //Subroutine subA @ 0xB9
		// ram[9'h0B9] = 32'h1F2A0000; //add R15, R10, R12
		// ram[9'h0BA] = 32'h203B8000; //sub R14, R11, R13
		// ram[9'h0BB] = 32'h203F7000; //sub R15, R15, R14
		// ram[9'h0BC] = 32'hAC000000; //jr R8

		// // Phase 3 required memory initialization
		// ram[9'h054] = 32'h00000097; //memory[0x54] = 0x97
		// ram[9'h092] = 32'h00000046; //memory[0x92] = 0x46

		//Phase 4 RAM instruction encoding
		ram[8'h00] = 32'h09800065;
		ram[8'h01] = 32'h09980003;
		ram[8'h02] = 32'h01000054;
		ram[8'h03] = 32'h09100001;
		ram[8'h04] = 32'h0017FFFA;
		ram[8'h05] = 32'h08800003;
		ram[8'h06] = 32'h09800057;
		ram[8'h07] = 32'h99980003;
		ram[8'h08] = 32'h09980003;
		ram[8'h09] = 32'h021FFFFA;
		ram[8'h0A] = 32'hD0000000;
		ram[8'h0B] = 32'h9A100002;
		ram[8'h0C] = 32'h0B180007;
		ram[8'h0D] = 32'h0AB7FFFC;
		ram[8'h0E] = 32'h19988000;
		ram[8'h0F] = 32'h62200002;
		ram[8'h10] = 32'h8A200000;
		ram[8'h11] = 32'h92200000;
		ram[8'h12] = 32'h6A20000F;
		ram[8'h13] = 32'h39008000;
		ram[8'h14] = 32'h72100007;
		ram[8'h15] = 32'h51208000;
		ram[8'h16] = 32'h49988000;
		ram[8'h17] = 32'h11800092;
		ram[8'h18] = 32'h41808000;
		ram[8'h19] = 32'h32880000;
		ram[8'h1A] = 32'h29180000;
		ram[8'h1B] = 32'h12900054;
		ram[8'h1C] = 32'h201A8000;
		ram[8'h1D] = 32'h59188000;
		ram[8'h1E] = 32'h0A800008;
		ram[8'h1F] = 32'h0B000017;
		ram[8'h20] = 32'h83280000;
		ram[8'h21] = 32'hCA000000;
		ram[8'h22] = 32'hC3800000;
		ram[8'h23] = 32'h7B280000;
		ram[8'h24] = 32'h0D280001;
		ram[8'h25] = 32'h0DB7FFFD;
		ram[8'h26] = 32'h0E380001;
		ram[8'h27] = 32'h0EA00004;
		ram[8'h28] = 32'hA6000000;
		ram[8'h29] = 32'hB2000000;
		ram[8'h2A] = 32'h12000055;
		ram[8'h2B] = 32'h0880002E;
		ram[8'h2C] = 32'h0B800001;
		ram[8'h2D] = 32'h0A800028;
		ram[8'h2E] = 32'hBA000000;
		ram[8'h2F] = 32'h0AAFFFFF;
		ram[8'h30] = 32'h9A800008;
		ram[8'h31] = 32'h030000F0;
		ram[8'h32] = 32'h0B37FFFF;
		ram[8'h33] = 32'hD0000000;
		ram[8'h34] = 32'h9B0FFFFD;
		ram[8'h35] = 32'h4A238000;
		ram[8'h36] = 32'h9A0FFFF7;
		ram[8'h37] = 32'h02000055;
		ram[8'h38] = 32'hA8800000;
		ram[8'h39] = 32'h0A0000AA;
		ram[8'h3A] = 32'hBA000000;
		ram[8'h3B] = 32'hD8000000;

		//initializing memory locations 0x54, 0x92, and 0xF0 to hold values as instructed
		ram[8'h54] = 32'h00000097;
		ram[8'h92] = 32'h00000046;
		ram[8'hF0] = 32'h0000FFFF;

		//subroutines
		ram[8'hB9] = 32'h1FD60000;
		ram[8'hBA] = 32'h275E8000;
		ram[8'hBB] = 32'h27FF0000;
		ram[8'hBC] = 32'hAC000000;

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