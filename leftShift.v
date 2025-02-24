module leftShift (
    input wire [31:0] A, 
    input wire [4:0] B, // B is 5-bit to restrict shifts to 0-31
    output wire [31:0] result
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : bitwise_left_shift
            assign result[i] = (i >= B) ? A[i - B] : 1'b0; // Shift left, fill with 0s
        end
    endgenerate
endmodule