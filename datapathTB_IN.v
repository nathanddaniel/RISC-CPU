
`timescale 1ns/1ps

module datapathTB_IN;

    reg clock;
    reg clear;
    reg PCout, Zhighout, Zlowout, MDRout; 
    reg MARin, PCin, MDRin, IRin, Yin, Zin;
    reg IncPC, Read, Write;
    reg Gra, Grb, Grc, BAout;
    reg [4:0] opcode;
    reg HIin, LOin, ZHighIn, ZLowIn;
    reg [8:0] Address;    
    reg [31:0] Mdatain;     
	 reg Rout, Rin;
	 reg Cout, HIout, LOout, Yout, InPortout;
	 reg CONin;
	 reg [31:0] external_input;
	 reg OutPortin;

    // OUTPUTS FROM DataPath (wires)
    wire R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
    wire R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;
	 wire CON_out;
	 wire [31:0] external_output;
	 
	 parameter Default = 4'b0000, T0 = 4'b0111, T1 = 4'b1000, T2 = 4'b1001, T3 = 4'b1010, T4 = 4'b1011, T5 = 4'b1100, T6 = 4'b1101, T7 = 4'b1110;
    
	 reg [3:0] Present_state = Default;
	 

    // Instantiate DataPath
    DataPath uut (
        .clock(clock),
        .clear(clear),
        .PCout(PCout), 
        .Zhighout(Zhighout), 
        .Zlowout(Zlowout), 
        .MDRout(MDRout),
        .MARin(MARin), 
        .Rin(Rin),
        .PCin(PCin), 
        .MDRin(MDRin), 
        .IRin(IRin), 
        .Yin(Yin),
        .IncPC(IncPC), 
        .Read(Read), 
        .Write(Write),
        .Gra(Gra), 
        .Grb(Grb), 
        .Grc(Grc),
        .opcode(opcode),
        .HIin(HIin), 
        .LOin(LOin), 
        .ZHighIn(ZHighIn), 
        .ZLowIn(ZLowIn), 
        .Address(Address),
        .Mdatain(Mdatain),
        .BAout(BAout),
        .R0out(R0out), 
        .R1out(R1out), 
        .R2out(R2out), 
        .R3out(R3out),
        .R4out(R4out), 
        .R5out(R5out), 
        .R6out(R6out), 
        .R7out(R7out),
        .R8out(R8out), 
        .R9out(R9out), 
        .R10out(R10out), 
        .R11out(R11out),
        .R12out(R12out), 
        .R13out(R13out), 
        .R14out(R14out), 
        .R15out(R15out),
        .HIout(HIout), 
        .LOout(LOout),
        .Yout(Yout), 
        .InPortout(InPortout), 
        .Cout(Cout),   // Fixed naming (was CSignOut)
        .Rout(Rout),    // Added Rout
		  .CONin(CONin),
		  .InPortData(external_input),  // Input data to InPort
		  .OutPortData(external_output), // Output data from OutPort
        .OutPortin(OutPortin)        // Control signal for writing output
    );
	 
	 initial begin
      clock = 0;
		clear = 0;
		uut.PC_inst.newPC = 32'h18;
   end
	 
	always 
		#10  clock <= ~clock;
		
	always @(posedge clock) begin
    case (Present_state)
        Default: Present_state <= T0;
        T0:      Present_state <= T1;
        T1:      Present_state <= T2;
        T2:      Present_state <= T3;
        T3:      Present_state  <= Default; // Reset or stop
		endcase
	end 
	
	always @(Present_state) begin
			case (Present_state)
				Default: begin
                PCout <= 0;         Zhighout <= 0;      Zlowout <= 0;      MDRout <= 0;
                MARin <= 0;         PCin <= 0;          MDRin <= 0;        IRin <= 0;          Yin <= 0;
                IncPC <= 0;         Read <= 0;          Write <= 0;
                Gra <= 0;           Grb <= 0;           Grc <= 0;          opcode <= 0;
                HIin <= 0;          LOin <= 0;          ZHighIn <= 0;      ZLowIn <= 0; 
                Address <= 9'h0;    Mdatain <= 32'h0;
                Cout <= 0; 			CONin <= 0;			  external_input = 32'h5;
            end
				
			T0: begin 
                    MARin <= 1;     IncPC <= 1; PCout <= 1; ZLowIn <= 1; 
 
            end

			T1: begin 
					     MARin <= 0;         IncPC <= 0;      PCout <= 0; ZLowIn <= 0;  
						  Zlowout <= 1;       PCin <= 1;       Read <= 1; MDRin <= 1;
            end

			T2: begin 
						  Zlowout <= 0;       PCin <= 0;       Read <= 0; MDRin <= 0;
                    MDRout <= 1;        IRin <= 1; 
            end

			  T3: begin 
			  			  MDRout <= 0;     	 IRin <= 0;
                    Gra <= 1;           Rin <= 1;       InPortout <= 1;						
            end
		endcase
	end

endmodule