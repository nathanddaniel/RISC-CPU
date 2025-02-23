module neg(A, neg_result);
    input [31:0] A;
    output reg [31:0] neg_result;

    always @(*) begin
        neg_result = ~A + 1'b1; // Two's complement to negate
    end
endmodule
