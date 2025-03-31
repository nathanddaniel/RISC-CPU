`timescale 1ns/10ps

module MiniSRC (
	input clock, 
      input reset,
      input stop,
      input interrupts
      input [31:0] InPortData,
      output [31:0] OutPortData
);

      //internal wires for the DataPath module
      wire [31:0] IR;
      wire CON_FF;

      // Control Signals
      wire Gra, Grb, Grc, Rin, Rout;
      wire Run, Clear;
      wire InPortout;
      wire Read, Write;
      wire ADD, SUB, AND, OR;
      wire ROR, ROL, SHR, SHRA, SHL;
      wire ADDI, ANDI, ORI;
      wire DIV, MUL, NEG, NOT;
      wire BRZR, BRNZ, BRMI, BRPL;
      wire JAR, JR;
      wire IN, OUT;
      wire MFLO, MFHI;
      wire NOP, HALT;
      wire HIin, LOin, CONin;
      wire PCin, IRin, Yin, Zin;
      wire ZHighIn, ZLowIn;
      wire MARin, MDRin, OutPortin;
      wire Cout, BAout;
      wire PCout, MDRout;
      wire Zhighout, Zlowout;
      wire HIout, LOout;

    
    //instantiating the ControlUnit
    ControlUnit CU (
      .IR(IR), .Clock(Clock), .Reset(Reset), .Stop(Stop), .Interrupts(Interrupts),
      .CON_FF(CON_FF), .Gra(Gra), .Grb(Grb), .Grc(Grc), .Rin(Rin), .Rout(Rout),
      .Run(Run), .Clear(Clear), .InPortout(InPortout), .Read(Read), .Write(Write),
      .ADD(ADD), .SUB(SUB), .AND(AND), .OR(OR), .ROR(ROR), .ROL(ROL), .SHR(SHR), 
      .SHRA(SHRA), .SHL(SHL), .ADDI(ADDI), .ANDI(ANDI), .ORI(ORI), .DIV(DIV), 
      .MUL(MUL), .NEG(NEG), .NOT(NOT), .BRZR(BRZR), .BRNZ(BRNZ), .BRMI(BRMI), 
      .BRPL(BRPL), .JAR(JAR), .JR(JR), .IN(IN), .OUT(OUT), .MFLO(MFLO), .MFHI(MFHI),
      .NOP(NOP), .HALT(HALT), .HIin(HIin), .LOin(LOin), .CONin(CONin),.PCin(PCin),
      .IRin(IRin), .Yin(Yin), .Zin(Zin), .ZHighIn(ZHighIn), .ZLowIn(ZLowIn),
      .MARin(MARin), .MDRin(MDRin), .OutPortin(OutPortin), .Cout(Cout), .BAout(BAout),
      .PCout(PCout), .MDRout(MDRout), .Zhighout(Zhighout), .Zlowout(Zlowout),
      .HIout(HIout), .LOout(LOout)
    );

    // Instantiate Data Path
    DataPath DP (
      .PCout(PCout), .Zhighout(Zhighout), .Zlowout(Zlowout), 
      .MDRout(MDRout), .BAout(BAout), .Rin(Rin), .Rout(Rout),
      .HIout(HIout), .LOout(LOout), .Yout(Yout), .InPortout(InPortout),
      .Cout(Cout), .OutPortin(OutPortin), .MARin(MARin), .PCin(PCin), 
      .MDRin(MDRin), .IRin(IRin), .Yin(Yin), .CONin(CONin), .IncPC(IncPC), 
      .Read(Read), .Write(Write), .Gra(Gra), .Grb(Grb), .Grc(Grc), 
      .opcode(opcode), .HIin(HIin), .LOin(LOin), .ZHighIn(ZHighIn), 
      .ZLowIn(ZLowIn), .clock(clock), .clear(Clear), .Address(Address), 
      .Mdatain(Mdatain), .InPortData(InPortData), .R0out(), .R1out(), 
      .R2out(), .R3out(), .R4out(), .R5out(), .R6out(), .R7out(), .R8out(), 
      .R9out(), .R10out(), .R11out(), .R12out(), .R13out(), .R14out(), 
      .R15out(), .OutPortData(OutPortData), .IR(IR), .CON_FF(CON_FF)
    ); 
	
endmodule
