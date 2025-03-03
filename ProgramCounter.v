module ProgramCounter (
    input enable, clock, clear, IncPC,
    input [31:0] inputPC,
    output reg[31:0] newPC
);

always @ (posedge clock) begin
    if (clear) 
        newPC <= 32'b0;
    else if (enable) begin
        if (IncPC)
            newPC <= newPC + 1;
        else
            newPC <= inputPC;
    end
end

endmodule