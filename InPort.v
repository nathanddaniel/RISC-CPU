
/*
This is the InPort.v module. This module implements the Input Port for the Mini SRC CPU.
It allows the CPU to receive 32-bit data from an external source. The received value is 
stored in an internal register and can be placed onto the bus.
*/

module InPort (
    input wire clock, 
    input wire clear, 
    input wire [31:0] InPortData, //the data from an external input device

    output reg [31:0] BusMuxIn_InPort //outputing to the CPU bus when InPortout is enabled
);

    //always block on the rising edge of clock or when reset is high
    always @(posedge clock or posedge clear) begin
        if (clear)
            BusMuxIn_InPort <= 32'b0; //clearing the register
        else
            BusMuxIn_InPort <= InPortData; //loading the external input into the register
    end

endmodule




