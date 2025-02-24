module sub (
    input wire [31:0] A, 
    input wire [31:0] B, 
    output wire [31:0] Result
);
    wire [31:0] B_complement;
    wire [32:0] LocalCarry;

    assign B_complement = ~B; // Bitwise NOT of B for two's complement
    assign LocalCarry[0] = 1'b1; // Adding 1 for two's complement

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : bitwise_sub
            assign Result[i] = A[i] ^ B_complement[i] ^ LocalCarry[i]; // Bitwise sum
            assign LocalCarry[i+1] = (A[i] & B_complement[i]) | (LocalCarry[i] & (A[i] | B_complement[i])); // Carry computation
        end
    endgenerate
endmodule