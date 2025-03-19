// NOT TESTED
module MemorySubsystem(
	input clear, clock,
	input read, write, // Read and write for RAM (read is also used for MDR)
	input [31:0] Mdatain,
	input [8:0] address,
	input [31:0] BusMuxOut, // For MAR inputs
	input MARin, MDRin,
	output wire [31:0] BusMuxInMDR // Holds 32 bit output value 
);
wire [31:0] data_output = Mdatain[31:0];

mdr mdr_i (clear, clock, MDRin, read, BusMuxOut, data_output, data_output);
MAR mar (BusMuxOut, MARin, clock, clear, address);
RAM ram (read, write, clock, data_output, address, data_output);

assign BusMuxInMDR = data_output;

endmodule