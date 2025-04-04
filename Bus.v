module Bus (
    //all the Bus Sources
    input wire [31:0] BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3, 
                      BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7,  
                      BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11, 
                      BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15, 
                      BusMuxInHI, BusMuxInLO, BusMuxInY, BusMuxInZhigh, 
                      BusMuxInZlow, BusMuxInPC, BusMuxInMDR, 
                      BusMuxIn_InPort, BusMuxInCsignextended,

    //control signals from select and encode                 
    input wire  PCout, Zhighout, Zlowout, MDRout, 
                R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, 
                R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out, 
                HIout, LOout, Yout, InPortout, Cout, BAout,

    //bus output
    output wire [31:0] BusMuxOut

);

    //one-hot encoded control signals packed into a single 32-bit vector
    wire [15:0] RoutSignals = BAout ? (R0out ? 16'b0 : 
                          { R15out, R14out, R13out, R12out, R11out, R10out, R9out, R8out,  
                            R7out, R6out, R5out, R4out, R3out, R2out, R1out, R0out }) 
                          : { R15out, R14out, R13out, R12out, R11out, R10out, R9out, R8out,  
                              R7out, R6out, R5out, R4out, R3out, R2out, R1out, R0out }; 
     
    //5-bit select signal generated from the Bus Encoder
    wire [4:0] BusSelect;
     
    //instantiating the Bus Encoder (converts Rout signals to a 5-bit select signal)
    BusEncoder32to5 bus_encoder (
        .RoutSignals(RoutSignals),
        .HIout(HIout), 
        .LOout(LOout), 
        .Yout(Yout), 
        .Zhighout(Zhighout), 
        .Zlowout(Zlowout), 
        .PCout(PCout), 
        .MDRout(MDRout), 
        .InPortout(InPortout), 
        .Cout(Cout),  
        .select(BusSelect)
    );
     
    //instantiating the Bus MUX (selects which input gets placed on the bus)
    BusMux32to1 bus_mux (
        .select(BusSelect),
        .BusMuxInR0(BAout ? 32'b0 : BusMuxInR0),
        .BusMuxInR1(BusMuxInR1), 
        .BusMuxInR2(BusMuxInR2), 
        .BusMuxInR3(BusMuxInR3),
        .BusMuxInR4(BusMuxInR4), 
        .BusMuxInR5(BusMuxInR5), 
        .BusMuxInR6(BusMuxInR6), 
        .BusMuxInR7(BusMuxInR7),
        .BusMuxInR8(BusMuxInR8), 
        .BusMuxInR9(BusMuxInR9), 
        .BusMuxInR10(BusMuxInR10), 
        .BusMuxInR11(BusMuxInR11),
        .BusMuxInR12(BusMuxInR12), 
        .BusMuxInR13(BusMuxInR13), 
        .BusMuxInR14(BusMuxInR14), 
        .BusMuxInR15(BusMuxInR15),
        .BusMuxInHI(BusMuxInHI), 
        .BusMuxInLO(BusMuxInLO), 
        .BusMuxInY(BusMuxInY), 
        .BusMuxInZhigh(BusMuxInZhigh),
        .BusMuxInZlow(BusMuxInZlow), 
        .BusMuxInPC(BusMuxInPC), 
        .BusMuxInMDR(BusMuxInMDR), 
        .BusMuxIn_InPort(BusMuxIn_InPort), 
        .BusMuxInCsignextended(BusMuxInCsignextended),
        .BusMuxOut(BusMuxOut)
    );

endmodule