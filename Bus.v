module Bus (
	//Mux
	input wire[31:0] BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3, BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7, BusMuxInR8, 
	BusMuxInR9, BusMuxInR10, BusMuxInR11, BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15, 
	BusMuxInHI, BusMuxInLO, BusMuxInY, BusMuxInZhigh, BusMuxInZlow, BusMuxInPC, BusMuxInMDR, BusMuxIn_InPort, BusMuxInCsignextended,
	//Encoder
	input PCout, Zhighout, Zlowout, MDRout, R0out, R2out, R3out, R4out, R5out, R6out, R7out, HIout, LOout,
	
	output wire [31:0]BusMuxOut
);

reg [31:0]q;

always @ (*) begin
	if(PCout) q = BusMuxInPC; // using if-else so that only one output drives the bus
	else if(HIout) q = BusMuxInHI;
	else if(LOout) q = BusMuxInLO;
	else if(Zhighout) q = BusMuxInZhigh;
	else if(MDRout) q = BusMuxInMDR;
	else if(R0out) q = BusMuxInR0;
	else if(R2out) q = BusMuxInR2;
	else if(R3out) q = BusMuxInR3;
	else if(R4out) q = BusMuxInR4;
	else if(R5out) q = BusMuxInR5;
	else if(R6out) q = BusMuxInR6;
	else if(R7out) q = BusMuxInR7;
	else if(Zlowout) q = BusMuxInZlow;
end
assign BusMuxOut = q;
endmodule