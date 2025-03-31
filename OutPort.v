
/*
This is the OutPort.v module. This module implements the Output Port for the Mini SRC CPU.
It allows the CPU to send 32-bit data to an external device. The output is written when the 
control signal `OutPortin` is asserted.
*/

module OutPort (
    input wire clock, 
    input wire clear, 
    input wire OutPortin, //enabling for the OutPort
    input wire [31:0] BusMuxOut, //data from the CPU bus

    output reg [31:0] OutPortData //output to the external system
);

    //always block on clock edge or clear
    always @(posedge clock or posedge clear) begin
        if (clear)
            OutPortData <= 32'b0; //clearing the output if reset is active
        else if (OutPortin)
            OutPortData <= BusMuxOut; //storing data from bus into OutPort
    end

endmodule




