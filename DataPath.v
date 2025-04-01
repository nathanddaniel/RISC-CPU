// NOT TESTED
module DataPath(

    input PCout, Zhighout, Zlowout, MDRout, BAout, Rin, Rout,
    input HIout, LOout, Yout, InPortout, Cout, OutPortin,
    input MARin, PCin, MDRin, IRin, Yin, CONin,
    input IncPC, Read, Write,
	 input Gra, Grb, Grc, 				 
    input [4:0] opcode,
    input HIin, LOin, ZHighIn, ZLowIn,
    input clock, clear,
    input [8:0] Address,
    input [31:0] Mdatain,
	 input wire [31:0] InPortData,
	 
	 output R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out,
    output R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,
	 output wire [31:0] OutPortData

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
  wire [18:0] C;
  wire [3:0] C2;
  wire CON_out;
  
   r0 r0_inst (
		 .clear(clear),
		 .clock(clock),
		 .enable(R0in),
		 .BAout(BAout), // New BAout signal connected
		 .BusMuxOut(BusMuxOut),
		 .BusMuxIn(BusMuxInR0)
  );
	
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
  
	
	// Instantiate CON FF
	CON_FF con_ff (
     .Clock(clock),
     .Clear(clear),
     .CONin(CONin),      // Control signal from Control Unit
     .BusMuxOut(BusMuxOut), // Value from the Bus
     .C2(C2),       // Extracts IR[20:19] for condition checking
     .CON(CON_out)           // Output flag to indicate if the branch is taken
	);

	ProgramCounter PC_inst (
		  .clock(clock),        
		  .clear(clear),        
		  .enable(PCin),        
		  .IncPC(IncPC),        
		  .CON(CON_out),                              // NEW: Uses branch condition signal
		  .inputPC(BusMuxOut),                    
		  .C_sign_extended(BusMuxInCsignextended), // NEW: Uses the sign-extended branch offset
		  .newPC(BusMuxInPC)                      
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
      .Mdatain(BusMuxOut), 
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
    .HIout(HIout), .LOout(LOout), .Yout(Yout), .InPortout(InPortout), .Cout(Cout), .BAout(BAout),

    .BusMuxOut(BusMuxOut)
  );
  
  select_and_encode selectLogic (
    .Gra(Gra),		
    .Grb(Grb),		
    .Grc(Grc),
    .Rin(Rin),
    .Rout(Rout),
    .BAout(BAout),
    .Ra(Ra),     						 
    .Rb(Rb),     						 
    .Rc(Rc),     						 
    .C(C),       						 
    .RinSignals(RinSignals),      
    .RoutSignals(RoutSignals),    
    .C_sign_extended(BusMuxInCsignextended) 
  );
  
  // ALU instantiation
  ALU main_alu (
			.clear (clear),
			.clock (clock),
			.opcode(opcode),
			.A     (BusMuxInY),  //Operand A recieves value from reg Y   
			.B     (BusMuxOut),  //Operand B recieves value from bus  
			.Z     (BusMuxInZ)   //Result is stored in reg Z
  );
  
	IR ir_inst (
		  .Clock(clock),
		  .Clear(clear),
		  .IRin(IRin),
		  .BusMuxOut(BusMuxOut), //Gets instruction from the CPU bus
		  .IR(IR_out),           //Stores the instruction
		  .Opcode(Opcode),       //Extracts the opcode field
		  .Ra(Ra), 
		  .Rb(Rb), 
		  .Rc(Rc),               //Extracts the register fields
		  .C(C),                 //Extracts the constant field
		  .C2(C2),               //Extracts the branch condition field (NEW)
		  .Jaddr(Jaddr)          //Extracts the jump address (NEW)
	);
	
	InPort inport_inst (
		 .clock(clock),
		 .clear(clear),
		 .InPortData(InPortData),        // External input signal
		 .BusMuxIn_InPort(BusMuxIn_InPort) // Connects to the CPU bus
	);
	
	OutPort outport_inst (
		 .clock(clock),
		 .clear(clear),
		 .OutPortin(OutPortin),   // Write enable for OutPort
		 .BusMuxOut(BusMuxOut),   // Data from the Bus
		 .OutPortData(OutPortData) // Connects to the external output
	);


endmodule