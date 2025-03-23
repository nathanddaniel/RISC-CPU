// NOT TESTED
module DataPath(

    input PCout, Zhighout, Zlowout, MDRout, BAout, Rin, Rout,
    input HIout, LOout, Yout, InPortout, Cout,
    input MARin, PCin, MDRin, IRin, Yin,
    input IncPC, Read, Write,
	  input Gra, Grb, Grc, 				 
    input [4:0] opcode,
    input HIin, LOin, ZHighIn, ZLowIn,
    input clock, clear,
    input [8:0] Address,
    input [31:0] Mdatain,
	 
	 output R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out,
    output R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out
);

  wire [63:0] BusMuxInZ;

  wire [31:0] BusMuxInR0, BusMuxInR1, BusMuxInR2, BusMuxInR3;
  wire [31:0] BusMuxInR4, BusMuxInR5, BusMuxInR6, BusMuxInR7;
  wire [31:0] BusMuxInR8, BusMuxInR9, BusMuxInR10, BusMuxInR11;
  wire [31:0] BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15;
  wire [31:0] BusMuxInHI, BusMuxInLO, BusMuxInY;
  wire [31:0] BusMuxInZhigh, BusMuxInZlow;
  wire [31:0] BusMuxInPC, BusMuxInMDR, BusMuxIn_InPort, BusMuxInCsignextended;
  wire [31:0] BusMuxOut;
  
  wire [8:0]  mem_address;
  wire [31:0] mem_data_out;
  wire [31:0] mem_data_in;
  wire [15:0] RinSignals, RoutSignals;
  wire [31:0] MDR_data_out;
  
  wire [31:0] IR_out;
  wire [4:0] Opcode;
  wire [3:0] Ra, Rb, Rc;
  wire [14:0] C;
  
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
  register Y   (clear, clock, Yin,   BusMuxOut, BusMuxInY);
  register Zhigh (clear, clock, ZHighIn, BusMuxInZ[63:32], BusMuxInZhigh);
  register Zlow  (clear, clock, ZLowIn,  BusMuxInZ[31:0],  BusMuxInZlow);
  
  ProgramCounter PC_inst (
		 .clock(clock),        // Correct mapping
		 .clear(clear),        // Correct mapping
		 .enable(PCin),        // Use PCin instead of "enable"
		 .IncPC(IncPC),        // Correct mapping
		 .inputPC(BusMuxOut),  // PC takes its input from the bus
		 .newPC(BusMuxInPC)    // The new PC value is stored in BusMuxInPC
	);
  
  // Assign register enable signals
  assign {R15in, R14in, R13in, R12in, R11in, R10in, R9in, R8in,
          R7in, R6in, R5in, R4in, R3in, R2in, R1in, R0in} = RinSignals;

  assign {R15out, R14out, R13out, R12out, R11out, R10out, R9out, R8out,
          R7out, R6out, R5out, R4out, R3out, R2out, R1out, R0out} = RoutSignals;  
  
  // Instantiate MAR (Memory Address Register)
  MAR mar_inst (
      .BusMuxOut(BusMuxOut), 
      .MARin(MARin), 
      .Clock(clock), 
      .Clear(clear), 
      .Address(mem_address) // Connects to RAM
  );
  
  // Instantiate RAM (Memory)
  RAM ram_inst (
      .Read(Read), 
      .Write(Write), 
      .Clock(clock), 
      .Mdatain(MDR_data_out), 
      .Address(mem_address), 
      .data_output(mem_data_out) // Output to MDR
  );
  
  // Instantiate MDR (Memory Data Register)
  mdr mdr_inst (
      .Clear(clear), 
      .Clock(clock), 
      .MDRin(MDRin), 
      .Read(Read), 
      .BusMuxOut(BusMuxOut), 
      .Mdatain(mem_data_out), // Data from RAM
      .BusMuxIn(BusMuxInMDR), // Output to CPU Bus
		.MDR_data_out(MDR_data_out)
  );
  
  
  // Bus Mux instantiation
  Bus bus (
    .BusMuxInR0(BusMuxInR0), .BusMuxInR1(BusMuxInR1), .BusMuxInR2(BusMuxInR2), .BusMuxInR3(BusMuxInR3),
    .BusMuxInR4(BusMuxInR4), .BusMuxInR5(BusMuxInR5), .BusMuxInR6(BusMuxInR6), .BusMuxInR7(BusMuxInR7),
    .BusMuxInR8(BusMuxInR8), .BusMuxInR9(BusMuxInR9), .BusMuxInR10(BusMuxInR10), .BusMuxInR11(BusMuxInR11),
    .BusMuxInR12(BusMuxInR12), .BusMuxInR13(BusMuxInR13), .BusMuxInR14(BusMuxInR14), .BusMuxInR15(BusMuxInR15),
    .BusMuxInHI(BusMuxInHI), .BusMuxInLO(BusMuxInLO), .BusMuxInY(BusMuxInY), .BusMuxInZhigh(BusMuxInZhigh),
    .BusMuxInZlow(BusMuxInZlow), .BusMuxInPC(BusMuxInPC), .BusMuxInMDR(BusMuxInMDR),
    .BusMuxIn_InPort(BusMuxIn_InPort), .BusMuxInCsignextended(BusMuxInCsignextended),

    .PCout(PCout), .Zhighout(Zhighout), .Zlowout(Zlowout), .MDRout(MDRout),
    .R0out(R0out), .R1out(R1out), .R2out(R2out), .R3out(R3out), .R4out(R4out), .R5out(R5out), 
    .R6out(R6out), .R7out(R7out), .R8out(R8out), .R9out(R9out), .R10out(R10out), .R11out(R11out), 
    .R12out(R12out), .R13out(R13out), .R14out(R14out), .R15out(R15out), 
    .HIout(HIout), .LOout(LOout), .Yout(Yout), .InPortout(InPortout), .Cout(Cout),

    .BusMuxOut(BusMuxOut)
  );
  
  select_and_encode selectLogic (
    .Gra(Gra),		// Inputs from Control Unit
    .Grb(Grb),		
    .Grc(Grc),
    .Rin(Rin),
    .Rout(Rout),
    .BAout(BAout),
    .Ra(Ra),     						 // From IR_out[Ra_field]
    .Rb(Rb),     						 // From IR_out[Rb_field]
    .Rc(Rc),     						 // From IR_out[Rc_field]
    .C(C),       						 // From IR_out[C_field]
    .RinSignals(RinSignals),      // To register enables (R0in, R1in, etc.)
    .RoutSignals(RoutSignals),    // To bus control (R0out, R1out, etc.)
    .C_sign_extended(BusMuxInCsignextended) 
  );
  
  // ALU instantiation
  ALU main_alu (
			.clear (clear),
			.clock (clock),
			.opcode(opcode),
			.A     (BusMuxInY),  // Operand A recieves value from reg Y   
			.B     (BusMuxOut),  // Operand B recieves value from bus  
			.Z     (BusMuxInZ)   // Result is stored in reg Z
  );
  
  IR ir_inst (
		 .Clock(clock),
		 .Clear(clear),
		 .IRin(IRin),
		 .BusMuxOut(BusMuxOut), // Gets instruction from the CPU bus
		 .IR(IR_out), 				// Stores the instruction
		 .Opcode(IR_out[31:27]), 		// Extracts the opcode field
		 .Ra(IR_out[26:23]), 
		 .Rb(IR_out[22:19]), 
		 .Rc(IR_out[18:15]), 					// Extracts the register fields
		 .C(IR_out[14:0]) 						// Extracts the constant field
	);

endmodule