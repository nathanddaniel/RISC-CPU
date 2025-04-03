module booth_multiplier (
    input wire signed [31:0] a,  // Multiplicand (signed 32-bit)
    input wire signed [31:0] b,  // Multiplier  (signed 32-bit)
    output reg signed [63:0] Z   // 64-bit product (hi:lo)
);
    reg signed [31:0] A;  
    reg signed [31:0] Q;  
    reg Q_m1;  // Extra bit: Q-1
    reg signed [31:0] M;     // Copy of 'a'
    integer i;

    always @(*) begin
        A = 32'd0;  // High half
        Q = b;      // Low half
        Q_m1 = 1'b0;   // Q-1
        M = a;

        // Perform 32 iterations
        for (i = 0; i < 32; i = i + 1) begin
            case ({Q[0], Q_m1})
                2'b01: A = A + M;
                2'b10: A = A - M;
                default: ;          // 00 or 11 => do nothing
            endcase

            // Save old Q[0] into Q_m1 BEFORE shifting
            Q_m1 = Q[0];

            // Arithmetic shift right the entire 65-bit structure {A,Q,Q_m1}
            {A, Q} = { {A[31], A}, Q } >>> 1;
        end
        Z = {A, Q};
    end
endmodule