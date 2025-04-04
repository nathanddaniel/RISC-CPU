module rightRotate (
    input wire [31:0] A,
    input wire [4:0] B, // B is 5-bit to ensure shift range 0-31
    output wire [31:0] result
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : bitwise_right_rotate
            assign result[i] = (i + B < 32) ? A[i + B] : A[i + B - 32]; // Rotate right
        end
    endgenerate
endmodule