/*

This is the R0.v module. This module implements Register R0 of the Mini SRC CPU. As instructed
in Phase 2, there were changes made to the R0 register so that if both BAout and enable are 
asserted, R0 clears its contents to 0 instead of loading data from the bus. This is used 
during base address operations.

*/
`timescale 1ns/1ps

module r0 (
    input clear, 
    input clock,               
    input enable, //r0 enable signal
    input BAout, //the special control signal used during base address calc
    input [31:0] BusMuxOut, //data from the bus

    output wire [31:0] BusMuxIn //output to the bus (when R0out is enabled)
);
    //internal register to hold R0's value
    reg [31:0] q;  

    //loading or resetting R0 based on control signals
    always @(clock) begin
        if (BAout && enable)
            q <= 32'b0; //this is the special case where we clear R0 when BAout and enable are high
        else if (clear)
            q <= 32'b0; //regular clear logic
        else if (enable)
            q <= BusMuxOut; //normal loading from the bus
    end

    //output value to bus
    assign BusMuxIn = q;

endmodule

