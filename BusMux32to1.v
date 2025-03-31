/*

This is the BusMux32to1.v module. This module acts as a 32-to-1 MUX for the
Mini SRC datapath. Based on the 5-bit 'select' input, it forwards one of the
32-bit sources ot the shared BusMuxOut line

*/

module BusMux32to1 (

    //these are the bus inputs from the general-purpose registers R0–R15
	input [31:0] BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3,	
	input [31:0] BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7,
	input [31:0] BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11,
	input [31:0] BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15,

    //bus inputs from the special purpose registers like HI, LO, Y, Zhigh and Zlow
	input [31:0] BusMuxInHI, BusMuxInLO, BusMuxInY, BusMuxInZhigh, BusMuxInZlow,

    //other source bus inputs
	input [31:0] BusMuxInPC, BusMuxInMDR, BusMuxIn_InPort, BusMuxInCsignextended,

    //this is the select signal that determines which source drives the bus
	input [4:0] select,

    //outputting the selected data to the bus
	output reg [31:0] BusMuxOut
);

    //the always block that chooses which input goes to the bus based on the select value
	always @(*) begin
		case (select)
			5'd0: BusMuxOut = BusMuxInR0; //register R0
			5'd1: BusMuxOut = BusMuxInR1; //register R1
			5'd2: BusMuxOut = BusMuxInR2; //register R2
			5'd3: BusMuxOut = BusMuxInR3; //register R3
			5'd4: BusMuxOut = BusMuxInR4; //register R4
			5'd5: BusMuxOut = BusMuxInR5; //register R5
			5'd6: BusMuxOut = BusMuxInR6; //register R6
			5'd7: BusMuxOut = BusMuxInR7; //register R7
			5'd8: BusMuxOut = BusMuxInR8; //register R8
			5'd9: BusMuxOut = BusMuxInR9; //register R9
			5'd10: BusMuxOut = BusMuxInR10; //register R10
			5'd11: BusMuxOut = BusMuxInR11; //register R11
			5'd12: BusMuxOut = BusMuxInR12; //register R12
			5'd13: BusMuxOut = BusMuxInR13; //register R13
			5'd14: BusMuxOut = BusMuxInR14; //register R14
			5'd15: BusMuxOut = BusMuxInR15; //register R15
			5'd16: BusMuxOut = BusMuxInHI; //register HI
			5'd17: BusMuxOut = BusMuxInLO; //register LO
			5'd18: BusMuxOut = BusMuxInY; //register Y
			5'd19: BusMuxOut = BusMuxInZhigh; //Zhigh (upper 32 bits of ALU result)
			5'd20: BusMuxOut = BusMuxInZlow; //Zlow (lower 32 bits of ALU result)
			5'd21: BusMuxOut = BusMuxInPC; //Program Counter
			5'd22: BusMuxOut = BusMuxInMDR; //Memory Data Register
			5'd23: BusMuxOut = BusMuxIn_InPort; //External input port
			5'd24: BusMuxOut = BusMuxInCsignextended;  //Sign-extended constant (immediate value)
			default: BusMuxOut = 32'b0; //default 
		endcase
	end
endmodule