module neg (
    input wire [31:0] A, 
    output wire [31:0] neg_result
);
    wire [31:0] inverted_A;
    wire [32:0] carry; // Expand carry to 33 bits to prevent out-of-bounds access

    assign inverted_A = ~A;  // Bitwise NOT
    assign carry[0] = 1'b1;  // Initial carry-in for Two’s Complement

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : bitwise_neg
            assign neg_result[i] = inverted_A[i] ^ carry[i]; // Sum
            assign carry[i+1] = inverted_A[i] & carry[i];  // Carry propagation
        end
    endgenerate
endmodule