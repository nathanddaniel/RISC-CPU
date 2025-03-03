module division (
    input  signed [31:0] A,
    input  signed [31:0] B,
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
        signQ = signA ^ signB;  

        absA = signA ? -A : A;  
        absB = signB ? -B : B;  

        quotient  = 32'd0;
        remainder = 32'd0;
        
        partial = {32'b0, absA};

        for (i = 0; i < 32; i = i + 1) begin
            partial = partial <<< 1; 
            partial[63:32] = partial[63:32] - absB;

            // Check if remainder went negative
            if (partial[63] == 1'b1) begin
                partial[63:32] = partial[63:32] + absB;
            end
            else begin
                quotient[31 - i] = 1'b1;
            end
        end
        remainder = partial[63:32];

        if (signQ) begin
            quotient = -quotient;
        end
        
        if (signA) begin
            remainder = -remainder;
        end

        result = { remainder, quotient };
    end

endmodule