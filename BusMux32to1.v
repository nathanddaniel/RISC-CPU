
module BusMux32to1 (

	input [31:0] BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3,	
	input [31:0] BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7,
	input [31:0] BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11,
	input [31:0] BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15,
	input [31:0] BusMuxInHI, BusMuxInLO, BusMuxInY, BusMuxInZhigh, BusMuxInZlow,
	input [31:0] BusMuxInPC, BusMuxInMDR, BusMuxIn_InPort, BusMuxInCsignextended,
	input [4:0] select,
	output reg [31:0] BusMuxOut

);

	always @(*) begin
		case (select)
			5'd0: BusMuxOut = BusMuxInR0;
			5'd1: BusMuxOut = BusMuxInR1;
			5'd2: BusMuxOut = BusMuxInR2;
			5'd3: BusMuxOut = BusMuxInR3;
			5'd4: BusMuxOut = BusMuxInR4;
			5'd5: BusMuxOut = BusMuxInR5;
			5'd6: BusMuxOut = BusMuxInR6;
			5'd7: BusMuxOut = BusMuxInR7;
			5'd8: BusMuxOut = BusMuxInR8;
			5'd9: BusMuxOut = BusMuxInR9;
			5'd10: BusMuxOut = BusMuxInR10;
			5'd11: BusMuxOut = BusMuxInR11;
			5'd12: BusMuxOut = BusMuxInR12;
			5'd13: BusMuxOut = BusMuxInR13;
			5'd14: BusMuxOut = BusMuxInR14;
			5'd15: BusMuxOut = BusMuxInR15;
			5'd16: BusMuxOut = BusMuxInHI;
			5'd17: BusMuxOut = BusMuxInLO;
			5'd18: BusMuxOut = BusMuxInY;
			5'd19: BusMuxOut = BusMuxInZhigh;
			5'd20: BusMuxOut = BusMuxInZlow;
			5'd21: BusMuxOut = BusMuxInPC;
			5'd22: BusMuxOut = BusMuxInMDR;
			5'd23: BusMuxOut = BusMuxIn_InPort;
			5'd24: BusMuxOut = BusMuxInCsignextended;
			default: BusMuxOut = 32'b0; 
		endcase
	end
endmodule