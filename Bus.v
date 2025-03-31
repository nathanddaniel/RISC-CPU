/*

This is the Bus.v module. It essentially acts as the wrapper for all the components
needed for the bus to work within our Mini SRC datapath. It uses an encoder and a
32-to-1 multiplexer to select one of the many possible data sources. Then it places the 
selected value onto the BusMuxOut line.

*/

module Bus (
    //all the Bus Sources that can place data onto the bus
    input wire [31:0] BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3, 
                      BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7,  
                      BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11, 
                      BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15, 
                      BusMuxInHI, BusMuxInLO, BusMuxInY, BusMuxInZhigh, 
                      BusMuxInZlow, BusMuxInPC, BusMuxInMDR, 
                      BusMuxIn_InPort, BusMuxInCsignextended,

    //control signals from select and encode that select which module outputs onto the bus               
    input wire  PCout, Zhighout, Zlowout, MDRout, R0out, R1out, R2out, R3out, 
                R4out, R5out, R6out, R7out, R8out, R9out, R10out, R11out, R12out, 
                R13out, R14out, R15out, HIout, LOout, Yout, InPortout, Cout, BAout,

    //the bus output
    output wire [31:0] BusMuxOut

);

    //combining the R0-R15 output signals into a 16 bit vector
    /* 
    special logic has been implemented where if BAout is asserted and R0out, then R0out
    is suppressed by forcing it to become 0. This is following the instructions provided 
    for revisions to register R0.

    */
    wire [15:0] RoutSignals = BAout ? (R0out ? 16'b0 : 
                          { R15out, R14out, R13out, R12out, R11out, R10out, R9out, R8out,  
                            R7out, R6out, R5out, R4out, R3out, R2out, R1out, R0out }) 
                          : { R15out, R14out, R13out, R12out, R11out, R10out, R9out, R8out,  
                              R7out, R6out, R5out, R4out, R3out, R2out, R1out, R0out }; 
     
    //the 5-bit select signal generated from the Bus Encoder to choose one source for the MUX
    wire [4:0] BusSelect;
     
    //instantiating the Bus Encoder (converts Rout signals to a 5-bit select signal)
    BusEncoder32to5 bus_encoder (
        .RoutSignals(RoutSignals), .HIout(HIout), .LOout(LOout), .Yout(Yout), 
        .Zhighout(Zhighout), .Zlowout(Zlowout), .PCout(PCout), .MDRout(MDRout), 
        .InPortout(InPortout), .Cout(Cout), .select(BusSelect)
    );
     
    //instantiating the Bus MUX (selects which input gets placed on the bus)
    BusMux32to1 bus_mux (
        .select(BusSelect), 
        .BusMuxInR0(BAout ? 32'b0 : BusMuxInR0), //masking R0 when BAout is active
        .BusMuxInR1(BusMuxInR1), .BusMuxInR2(BusMuxInR2), .BusMuxInR3(BusMuxInR3),
        .BusMuxInR4(BusMuxInR4), .BusMuxInR5(BusMuxInR5), .BusMuxInR6(BusMuxInR6), 
        .BusMuxInR7(BusMuxInR7), .BusMuxInR8(BusMuxInR8), .BusMuxInR9(BusMuxInR9), 
        .BusMuxInR10(BusMuxInR10), .BusMuxInR11(BusMuxInR11), .BusMuxInR12(BusMuxInR12), 
        .BusMuxInR13(BusMuxInR13), .BusMuxInR14(BusMuxInR14), .BusMuxInR15(BusMuxInR15),
        .BusMuxInHI(BusMuxInHI), .BusMuxInLO(BusMuxInLO), .BusMuxInY(BusMuxInY), 
        .BusMuxInZhigh(BusMuxInZhigh), .BusMuxInZlow(BusMuxInZlow), .BusMuxInPC(BusMuxInPC), 
        .BusMuxInMDR(BusMuxInMDR), .BusMuxIn_InPort(BusMuxIn_InPort), 
        .BusMuxInCsignextended(BusMuxInCsignextended), .BusMuxOut(BusMuxOut)
    );

endmodule