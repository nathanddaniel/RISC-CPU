module InPort (
    input wire clock,
    input wire clear,
    input wire [31:0] InPortData,  // Data coming from an external source
    output reg [31:0] BusMuxIn_InPort  // Data sent to the Bus
);

    always @(posedge clock or posedge clear) begin
        if (clear)
            BusMuxIn_InPort <= 32'b0;
        else
            BusMuxIn_InPort <= InPortData;
    end

endmodule