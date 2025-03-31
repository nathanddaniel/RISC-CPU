/*

This is the MAR.v module. This module implements the Memory Address Register (MAR) 
for the Mini SRC CPU. The MAR stores the memory address for load/store instructions.
It takes the lower 9 bits from the bus and provides them as the address to the RAM module.

*/

module MAR(
    input [31:0] BusMuxOut, //data on the bus 
    input MARin, //load enable signal for MAR
    input Clock, 
    input Clear, 

    output [8:0] Address //output address to be used for memory access
);

	//internal 9-bit register to hold the memory address
    reg [8:0] q;  

    //loading or clearing the MAR on the rising edge of the clock
    always @ (posedge Clock) begin
        if (Clear)
            q <= 9'b0; //resetting the MAR to 0
        else if (MARin)
            q <= BusMuxOut[8:0]; //loading the lower 9 bits of the bus into MAR
    end 
	
    //outputting the stored address to be used by the RAM
    assign Address = q;

endmodule
