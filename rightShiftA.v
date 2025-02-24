module rightShiftA (
    input wire [31:0] A, 
    input wire [4:0] B, // B is limited to 5 bits (0-31)
    output wire [31:0] result
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : bitwise_arithmetic_right_shift
            assign result[i] = (i + B < 32) ? A[i + B] : A[31]; // Shift right, fill with sign bit
        end
    endgenerate
endmodule