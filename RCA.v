module RCA (
    input wire [31:0] A, 
    input wire [31:0] B, 
    output wire [31:0] Result
);
    wire [32:0] LocalCarry;
    
    assign LocalCarry[0] = 1'b0; // Initial carry-in is 0

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : bitwise_add
            assign Result[i] = A[i] ^ B[i] ^ LocalCarry[i];
            assign LocalCarry[i+1] = (A[i] & B[i]) | (LocalCarry[i] & (A[i] | B[i]));
        end
    endgenerate
endmodule