module Bus (
    // 32-bit input signals
    input wire [31:0] BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3, BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7,  
                      BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11, BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15, 
                      BusMuxInHI, BusMuxInLO, BusMuxInY, BusMuxInZhigh, BusMuxInZlow, BusMuxInPC, BusMuxInMDR, 
                      BusMuxIn_InPort, BusMuxInCsignextended,
    // Control signals to select the bus output
    input wire PCout, Zhighout, Zlowout, MDRout, R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out,  
               R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out, HIout, LOout, Yout, InPortout, CSignOut,
    // Output signal with the selected data 
    output wire [31:0] BusMuxOut
);
    // Temp internal registor to hold selected value
    reg [31:0] q;
    // Below block determines which signal is placed on the bus
    always @(*) begin
        q = 32'd0; // Default value

        if      (PCout)       q = BusMuxInPC;
        else if (Zhighout)    q = BusMuxInZhigh;
        else if (Zlowout)     q = BusMuxInZlow;
        else if (MDRout)      q = BusMuxInMDR;
        else if (R0out)       q = BusMuxInR0;
        else if (R1out)       q = BusMuxInR1;
        else if (R2out)       q = BusMuxInR2;
        else if (R3out)       q = BusMuxInR3;
        else if (R4out)       q = BusMuxInR4;
        else if (R5out)       q = BusMuxInR5;
        else if (R6out)       q = BusMuxInR6;
        else if (R7out)       q = BusMuxInR7;
        else if (R8out)       q = BusMuxInR8;
        else if (R9out)       q = BusMuxInR9;
        else if (R10out)      q = BusMuxInR10;
        else if (R11out)      q = BusMuxInR11;
        else if (R12out)      q = BusMuxInR12;
        else if (R13out)      q = BusMuxInR13;
        else if (R14out)      q = BusMuxInR14;
        else if (R15out)      q = BusMuxInR15;
        else if (HIout)       q = BusMuxInHI;
        else if (LOout)       q = BusMuxInLO;
        else if (Yout)        q = BusMuxInY;
        else if (InPortout)   q = BusMuxIn_InPort;
        else if (CSignOut)    q = BusMuxInCsignextended;
    end

    assign BusMuxOut = q;

endmodule