module OutPort (
    input wire clock,
    input wire clear,
    input wire OutPortin,         // Write enable for OutPort
    input wire [31:0] BusMuxOut,  // Data from the Bus
    output reg [31:0] OutPortData // Output data to an external unit
);

    always @(posedge clock or posedge clear) begin
        if (clear)
            OutPortData <= 32'b0;
        else if (OutPortin)
            OutPortData <= BusMuxOut;
    end

endmodule