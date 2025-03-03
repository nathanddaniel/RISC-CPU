module division (
    input  signed [31:0] A, // Dividend (signed)
    input  signed [31:0] B, // Divisor  (signed)
    output reg   signed [63:0] result  // { remainder, quotient }
);
    // Loading relevant registers for booth algorithm
    reg signed [31:0] quotient;
    reg signed [31:0] remainder;
    
    reg signed [63:0] partial; 
    reg signA, signB, signQ;
    reg signed [31:0] absA, absB;

    integer i;  // Loop counter

    always @(*) begin
        // Determine the sign of A, B and the quotient
        signA = A[31]; 
        signB = B[31];
        signQ = signA ^ signB;  
        // Convert inputs to absoloute for division
        absA = signA ? -A : A;  
        absB = signB ? -B : B;  
        // Initilize the remaining registers
        quotient  = 32'd0;
        remainder = 32'd0;
        
        partial = {32'b0, absA};
        // Perform binary divsion using the restoring algorithm
        for (i = 0; i < 32; i = i + 1) begin
            partial = partial <<< 1; // Shift left by 2
            partial[63:32] = partial[63:32] - absB; // Subtract divisor from upper 32 bits

            // Check if remainder went negative
            if (partial[63] == 1'b1) begin
                partial[63:32] = partial[63:32] + absB; // Restore remainder
            end
            else begin
                quotient[31 - i] = 1'b1;
            end
        end
        // Store the final remainder
        remainder = partial[63:32];
        // Adjust quotient sign if necessary
        if (signQ) begin
            quotient = -quotient;
        end
        // Adjust remiander sign to match dividend
        if (signA) begin
            remainder = -remainder;
        end
        // Concatenate remainder and quotient into result
        result = { remainder, quotient };
    end

endmodule