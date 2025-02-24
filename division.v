module division (
    input  signed [31:0] A,   // Dividend
    input  signed [31:0] B,   // Divisor
    output reg   signed [63:0] result  // { remainder, quotient }
);

    reg signed [31:0] quotient;
    reg signed [31:0] remainder;
    
    reg signed [63:0] partial; 
    reg signA, signB, signQ;
    reg signed [31:0] absA, absB;

    integer i;

    always @(*) begin
        signA = A[31]; 
        signB = B[31];
        // Quotient sign is XOR of dividend and divisor signs
        signQ = signA ^ signB;  

        // Take absolute values of A and B for the division steps
        absA = signA ? -A : A;  
        absB = signB ? -B : B;  

        quotient  = 32'd0;
        remainder = 32'd0;
        
        partial = {32'b0, absA};

        // Restoring Division Algorithm
        // We perform 32 iterations. On each iteration:
        //  a) Shift partial left by 1 (this shifts the remainder:dividend).
        //  b) Subtract absB from the upper 32 bits (the remainder).
        //  c) If result is negative -> restore (add absB back) and set quotient bit to 0.
        //     If result is >= 0 -> keep it (no restore) and set quotient bit to 1.

        for (i = 0; i < 32; i = i + 1) begin
            // Shift "partial" left by 1
            partial = partial <<< 1; 
            // Subtract absB from the upper 32 bits (the remainder part)
            partial[63:32] = partial[63:32] - absB;

            // Check if remainder went negative by checking sign bit partial[63]
            if (partial[63] == 1'b1) begin
                // Negative -> restore
                partial[63:32] = partial[63:32] + absB;
                // The current quotient bit is 0 (do nothing)
            end
            else begin
                // Non-negative -> accept the subtraction
                // Set the LSB (bit 0) in the running quotient portion 
                // We build the quotient from MSB down to LSB in 32 steps.
                quotient[31 - i] = 1'b1;
            end
        end

        //-----------------------------------------
        // 4. Final remainder is in partial[63:32]
        //-----------------------------------------
        remainder = partial[63:32];

        //-----------------------------------------
        // 5. Apply sign corrections
        //-----------------------------------------
        // If signQ is 1, invert the quotient
        if (signQ) begin
            quotient = -quotient;
        end
        
        // Remainder should have the same sign as the dividend (A)
        if (signA) begin
            remainder = -remainder;
        end

        //-----------------------------------------
        // 6. Pack result { remainder, quotient }
        //-----------------------------------------
        result = { remainder, quotient };
    end

endmodule