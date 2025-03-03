module DataPath(
    // These are the signals that also appear in Bus.v
    input PCout, Zhighout, Zlowout, MDRout,
    input R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out,
    input R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,
    input HIout, LOout, Yout, InPortout, CSignOut,

    // CPU control signals for writing into registers, etc.
    input MARin, PCin, MDRin, IRin, Yin,
    input IncPC, Read,
    input [4:0] opcode,
    input R0in, R1in, R2in, R3in, 
    input R4in, R5in, R6in, R7in, 
    input R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in,
    input HIin, LOin, ZHighIn, ZLowIn, Cin,

    // Standard clock/reset lines
    input clock, clear,

    // Data input from external memory
    input [31:0] Mdatain
);

  // 64-bit ALU result bus
  wire [63:0] BusMuxInZ;

  // 32-bit wires for internal register data
  wire [31:0] BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3;
  wire [31:0] BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7;
  wire [31:0] BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11;
  wire [31:0] BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15;
  wire [31:0] BusMuxInHI, BusMuxInLO, BusMuxInY;
  wire [31:0] BusMuxInZhigh, BusMuxInZlow;
  wire [31:0] BusMuxInPC, BusMuxInMDR, BusMuxIn_InPort, BusMuxInCsignextended;
  wire [31:0] BusMuxOut;

  // ------------------------------------------------
  //  Register Instantiations
  // ------------------------------------------------
  register r0  (clear, clock, R0in,  BusMuxOut, BusMuxInR0);
  register r1  (clear, clock, R1in,  BusMuxOut, BusMuxInR1);
  register r2  (clear, clock, R2in,  BusMuxOut, BusMuxInR2);
  register r3  (clear, clock, R3in,  BusMuxOut, BusMuxInR3);
  register r4  (clear, clock, R4in,  BusMuxOut, BusMuxInR4);
  register r5  (clear, clock, R5in,  BusMuxOut, BusMuxInR5);
  register r6  (clear, clock, R6in,  BusMuxOut, BusMuxInR6);
  register r7  (clear, clock, R7in,  BusMuxOut, BusMuxInR7);
  register r8  (clear, clock, R8in,  BusMuxOut, BusMuxInR8);
  register r9  (clear, clock, R9in,  BusMuxOut, BusMuxInR9);
  register r10 (clear, clock, R10in, BusMuxOut, BusMuxInR10);
  register r11 (clear, clock, R11in, BusMuxOut, BusMuxInR11);
  register r12 (clear, clock, R12in, BusMuxOut, BusMuxInR12);
  register r13 (clear, clock, R13in, BusMuxOut, BusMuxInR13);
  register r14 (clear, clock, R14in, BusMuxOut, BusMuxInR14);
  register r15 (clear, clock, R15in, BusMuxOut, BusMuxInR15);

  register HI  (clear, clock, HIin,  BusMuxOut, BusMuxInHI);
  register LO  (clear, clock, LOin,  BusMuxOut, BusMuxInLO);

  // "Y" register holds first ALU operand
  register Y   (clear, clock, Yin,   BusMuxOut, BusMuxInY);

  // Z registers hold 64-bit ALU result
  register Zhigh (clear, clock, ZHighIn, BusMuxInZ[63:32], BusMuxInZhigh);
  register Zlow  (clear, clock, ZLowIn,  BusMuxInZ[31:0],  BusMuxInZlow);

  // PC and MDR
  ProgramCounter PC_inst (clock, PCin, IncPC, BusMuxOut, BusMuxInPC);
  mdr           mdr_i    (clear, clock, MDRin, Read, BusMuxOut, Mdatain, BusMuxInMDR);

  // ------------------------------------------------
  //  The System Bus
  // ------------------------------------------------
  Bus bus (
    // 32-bit inputs
    BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3, 
    BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7,
    BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11,
    BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15,
    BusMuxInHI, BusMuxInLO, BusMuxInY, BusMuxInZhigh, BusMuxInZlow,
    BusMuxInPC, BusMuxInMDR, BusMuxIn_InPort, BusMuxInCsignextended,

    // Control signals that select which input drives BusMuxOut:
    PCout, Zhighout, Zlowout, MDRout,
    R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out,
    R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,
    HIout, LOout, Yout, InPortout, CSignOut,

    // 32-bit bus output
    BusMuxOut
  );

  // ------------------------------------------------
  //  Single ALU Instantiation
  // ------------------------------------------------
  ALU main_alu (
      .clear (clear),
      .clock (clock),
      .opcode(opcode),
      .A     (BusMuxInY),     // 1st operand from Y register
      .B     (BusMuxOut),     // 2nd operand from system bus
      .Z     (BusMuxInZ)     // 64-bit result
  );

endmodule