//DataPath module integrating registers, ALU, memory, and control logic

module DataPath(
  input clock, clear, stop,
  input Run, Interrupts,
  input [31:0] InPortData,
  output [31:0] OutPortData
);

  //Control Unit output control signals to coordinate datapath operations
  wire Gra_w, Grb_w, Grc_w, Rin_w, Rout_w;
  wire Read_w, Write_w, Clear_w;
  wire PCin_w, PCout_w, IRin_w, Yin_w, Zin_w;
  wire MARin_w, MDRin_w, MDRout_w;
  wire ZHighIn_w, ZLowIn_w;
  wire Zhighout_w, Zlowout_w, HIin_w, LOin_w, HIout_w, LOout_w;
  wire CONin_w, Cout_w, BAout_w, InPortout_w, OutPortin_w;
  wire ADD_w, SUB_w, AND_w, OR_w, ROR_w, ROL_w, SHR_w, SHRA_w, SHL_w;
  wire ADDI_w, ANDI_w, ORI_w, DIV_w, MUL_w, NEG_w, NOT_w;
  wire BRZR_w, BRNZ_w, BRMI_w, BRPL_w, JAR_w, JR_w;
  wire IN_w, OUT_w, MFLO_w, MFHI_w, NOP_w, HALT_w;

  //inputs to the bus MUX from general-purpose reg and other datapath components
  wire [63:0] BusMuxInZ;
  wire [31:0] BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3;
  wire [31:0] BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7;
  wire [31:0] BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11;
  wire [31:0] BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15;
  wire [31:0] BusMuxInHI, BusMuxInLO, BusMuxInY;
  wire [31:0] BusMuxInZhigh, BusMuxInZlow;
  wire [31:0] BusMuxInPC, BusMuxInMDR, BusMuxIn_InPort, BusMuxInCsignextended;
  wire [31:0] BusMuxOut;
  
  //register input and output enable signals assigned based on the decoded instruction
  wire [15:0] RinSignals;
  wire [15:0] RoutSignals;
  
  wire R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
  wire R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;
  
  //Assign register enable signals
  assign {R15in, R14in, R13in, R12in, R11in, R10in, R9in, R8in,
          R7in, R6in, R5in, R4in, R3in, R2in, R1in, R0in} = RinSignals;
  
  
  assign {R15out, R14out, R13out, R12out,
          R11out, R10out, R9out, R8out,
          R7out,  R6out,  R5out,  R4out,
          R3out,  R2out,  R1out,  R0out} = RoutSignals;
  
  //wires for memory address, data input/output, and MDR interface
  wire [8:0] mem_address;
  wire [31:0] mem_data_out, mem_data_in;
  wire [31:0] MDR_data_out;

  //fields decoded from the IR
  wire [31:0] IR_out;
  wire [4:0] Opcode;
  wire [3:0] Ra, Rb, Rc;
  wire [18:0] C;
  wire [3:0] C2;
  wire [25:0] Jaddr;
  wire CON_out;

  //instantiation of general-purpose registers (R0-R15) with input and output lines
  r0 r0_inst (
	  .clear(Clear_w), 
	  .clock(clock), 
	  .enable(RinSignals[0]), 
	  .BAout(BAout_w), 
	  .BusMuxOut(BusMuxOut), 
	  .BusMuxIn(BusMuxInR0)
  );
  
  register r1 (Clear_w, clock, RinSignals[1], BusMuxOut, BusMuxInR1);
  register r2 (Clear_w, clock, RinSignals[2], BusMuxOut, BusMuxInR2);
  register r3 (Clear_w, clock, RinSignals[3], BusMuxOut, BusMuxInR3);
  register r4 (Clear_w, clock, RinSignals[4], BusMuxOut, BusMuxInR4);
  register r5 (Clear_w, clock, RinSignals[5], BusMuxOut, BusMuxInR5);
  register r6 (Clear_w, clock, RinSignals[6], BusMuxOut, BusMuxInR6);
  register r7 (Clear_w, clock, RinSignals[7], BusMuxOut, BusMuxInR7);
  register r8 (Clear_w, clock, RinSignals[8], BusMuxOut, BusMuxInR8);
  register r9 (Clear_w, clock, RinSignals[9], BusMuxOut, BusMuxInR9);
  register r10 (Clear_w, clock, RinSignals[10], BusMuxOut, BusMuxInR10);
  register r11 (Clear_w, clock, RinSignals[11], BusMuxOut, BusMuxInR11);
  register r12 (Clear_w, clock, RinSignals[12], BusMuxOut, BusMuxInR12);
  register r13 (Clear_w, clock, RinSignals[13], BusMuxOut, BusMuxInR13);
  register r14 (Clear_w, clock, RinSignals[14], BusMuxOut, BusMuxInR14);
  register r15 (Clear_w, clock, RinSignals[15], BusMuxOut, BusMuxInR15);

  //special registers used in ALU operations and instruction flow
  //HI/LO for MUL/DIV results, Y for holding intermediate ALU input
  register HI  (Clear_w, clock, HIin_w,  BusMuxOut, BusMuxInHI);
  register LO  (Clear_w, clock, LOin_w,  BusMuxOut, BusMuxInLO);
  register Y   (Clear_w, clock, Yin_w,   BusMuxOut, BusMuxInY);
  register Zhigh (Clear_w, clock, ZHighIn_w, BusMuxInZ[63:32], BusMuxInZhigh);
  register Zlow  (Clear_w, clock, ZLowIn_w,  BusMuxInZ[31:0],  BusMuxInZlow);

  //conditional code (FF) to evaluate branch conditions (BRZR, BRNZ, BRMI, etc.)
  CON_FF con_ff (
    .Clock(clock), 
    .Clear(Clear_w), 
    .CONin(CONin_w), 
    .BusMuxOut(BusMuxOut), 
    .C2(C2), 
    .CON(CON_out)
  );

  //Program Counter instantiation
  ProgramCounter PC_inst (
    .clock(clock), 
	  .clear(Clear_w), 
	  .enable(PCin_w),
    .IncPC(IncPC_w), 
	  .CON(CON_out), 
	  .inputPC(BusMuxOut),
    .C_sign_extended(BusMuxInCsignextended), 
	  .newPC(BusMuxInPC)
  );

  //Memory Address Register instantiation
  MAR mar_inst (
    .BusMuxOut(BusMuxOut), 
    .MARin(MARin_w), 
    .Clock(clock), 
    .Clear(Clear_w), 
    .Address(mem_address)
  );

  //RAM memory block for instruction and data access
  RAM ram_inst (
    .Read(Read_w), 
    .Write(Write_w), 
    .Clock(clock), 
    .Mdatain(BusMuxOut), 
    .Address(mem_address), 
    .data_output(mem_data_out)
  );

  //Memory Data register instantiation
  mdr mdr_inst (
    .Clear(Clear_w), 
    .Clock(clock), 
    .MDRin(MDRin_w), 
    .Read(Read_w), 
    .BusMuxOut(BusMuxOut), 
    .Mdatain(mem_data_out), 
    .BusMuxIn(BusMuxInMDR), 
    .MDR_data_out(MDR_data_out)
  );

  // Bus instantiation within the Datapath, connecting the bus subsystem with the other modules
  Bus bus (
    .BusMuxInR0(BusMuxInR0), .BusMuxInR1(BusMuxInR1), .BusMuxInR2(BusMuxInR2), .BusMuxInR3(BusMuxInR3),
    .BusMuxInR4(BusMuxInR4), .BusMuxInR5(BusMuxInR5), .BusMuxInR6(BusMuxInR6), .BusMuxInR7(BusMuxInR7),
    .BusMuxInR8(BusMuxInR8), .BusMuxInR9(BusMuxInR9), .BusMuxInR10(BusMuxInR10), .BusMuxInR11(BusMuxInR11),
    .BusMuxInR12(BusMuxInR12), .BusMuxInR13(BusMuxInR13), .BusMuxInR14(BusMuxInR14), .BusMuxInR15(BusMuxInR15),
    .BusMuxInHI(BusMuxInHI), .BusMuxInLO(BusMuxInLO), .BusMuxInY(BusMuxInY), .BusMuxInZhigh(BusMuxInZhigh),
    .BusMuxInZlow(BusMuxInZlow), .BusMuxInPC(BusMuxInPC), .BusMuxInMDR(BusMuxInMDR),
    .BusMuxIn_InPort(BusMuxIn_InPort), .BusMuxInCsignextended(BusMuxInCsignextended),
	 
	  .R0out(R0out), .R1out(R1out), .R2out(R2out), .R3out(R3out), .R4out(R4out), .R5out(R5out), 
    .R6out(R6out), .R7out(R7out), .R8out(R8out), .R9out(R9out), .R10out(R10out), .R11out(R11out), 
    .R12out(R12out), .R13out(R13out), .R14out(R14out), .R15out(R15out), 
    .PCout(PCout_w), .Zhighout(Zhighout_w), .Zlowout(Zlowout_w), .MDRout(MDRout_w),
    .HIout(HIout_w), .LOout(LOout_w), .Yout(Yout), .InPortout(InPortout_w), .Cout(Cout_w), .BAout(BAout_w),
    .BusMuxOut(BusMuxOut)
  );

  //Select and Encode module instantiation
  select_and_encode selectLogic (
    .Gra(Gra_w), .Grb(Grb_w), .Grc(Grc_w), 
    .Rin(Rin_w), .Rout(Rout_w), .BAout(BAout_w),
    .Ra(Ra), .Rb(Rb), .Rc(Rc), .C(C), 
    .RinSignals(RinSignals), .RoutSignals(RoutSignals),
    .C_sign_extended(BusMuxInCsignextended)
  );

  //ALU instantiation
  ALU main_alu (
    .clear(Clear_w), 
    .clock(clock), 
    .opcode(Opcode),
    .A(BusMuxInY), 
    .B(BusMuxOut), 
    .Z(BusMuxInZ)
  );

  //Instruction Register instantiation
  IR ir_inst (
    .Clock(clock), 
    .Clear(Clear_w), 
    .IRin(IRin_w), 
    .BusMuxOut(BusMuxOut), 
    .IR(IR_out), 
    .Opcode(Opcode),
    .Ra(Ra), 
    .Rb(Rb), 
    .Rc(Rc), 
    .C(C), 
    .C2(C2), 
    .Jaddr(Jaddr)
  );

  //I/O Ports instantation 
  InPort inport_inst (
    .clock(clock), 
    .clear(Clear_w), 
    .InPortData(InPortData), 
    .BusMuxIn_InPort(BusMuxIn_InPort)
  );
  
  OutPort outport_inst (
    .clock(clock), 
    .clear(Clear_w), 
    .OutPortin(OutPortin_w), 
    .BusMuxOut(BusMuxOut), 
    .OutPortData(OutPortData)
  );

  //Control Unit instanttion, connecting it to the datapath for Phase 3
  ControlUnit control_unit_inst (
		 .IR(IR_out), 
		 .Clock(clock), 
		 .Reset(Clear_w), 
		 .Run(Run), 
		 .CON_FF(CON_out), 
		 .Interrupts(Interrupts),  
		 .Stop(stop),

		 .Gra(Gra_w), .Grb(Grb_w), .Grc(Grc_w), 
		 .Rin(Rin_w), .Rout(Rout_w), 
		 .Clear(Clear_w), 
		 .InPortout(InPortout_w),

		 .Read(Read_w), .Write(Write_w), 

		 .ADD(ADD_w), .SUB(SUB_w), .AND(AND_w), .OR(OR_w),
		 .ROR(ROR_w), .ROL(ROL_w), .SHR(SHR_w), .SHRA(SHRA_w), .SHL(SHL_w),
		 .ADDI(ADDI_w), .ANDI(ANDI_w), .ORI(ORI_w), .DIV(DIV_w), .MUL(MUL_w),
		 .NEG(NEG_w), .NOT(NOT_w), 

		 .BRZR(BRZR_w), .BRNZ(BRNZ_w), .BRMI(BRMI_w), .BRPL(BRPL_w),
		 .JAR(JAR_w), .JR(JR_w), 

		 .IN(IN_w), .OUT(OUT_w), 
		 .MFLO(MFLO_w), .MFHI(MFHI_w), 
		 .NOP(NOP_w), .HALT(HALT_w),

		 .HIin(HIin_w), .LOin(LOin_w), .CONin(CONin_w), 
		 .PCin(PCin_w), .IRin(IRin_w), .Yin(Yin_w), .Zin(Zin_w), 
		 .ZHighIn(ZHighIn_w), .ZLowIn(ZLowIn_w), 

		 .MARin(MARin_w), .MDRin(MDRin_w), 
		 .OutPortin(OutPortin_w), .Cout(Cout_w), .BAout(BAout_w),

		 .PCout(PCout_w), .MDRout(MDRout_w), 
		 .Zhighout(Zhighout_w), .Zlowout(Zlowout_w), 
		 .HIout(HIout_w), .LOout(LOout_w),
		 
		 .IncPC(IncPC_w)
	);


endmodule
