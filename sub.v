module sub(A, B, Result);
    input [31:0] A, B;
    output reg [31:0] Result;

    always @(*) begin
        Result = A + (~B + 1'b1); // Using Two's Complement (A - B)
    end
endmodule
