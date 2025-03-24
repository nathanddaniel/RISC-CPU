//NOT TESTED

`timescale 1ns/1ps

module datapathTB_LD;

    // Clock and Reset
    reg clock;
    reg clear;
    reg PCout, Zhighout, Zlowout, MDRout; 
    reg MARin, PCin, MDRin, IRin, Yin, Zin;
    reg IncPC, Read, Write;
    reg Gra, Grb, Grc, BAout;
    reg [4:0] ADD;
    reg HIin, LOin, ZHighIn, ZLowIn;
    reg [8:0] Address;    
    reg [31:0] Mdatain;     
	 reg Rout, Rin;
	 reg Cout, HIout, LOout, Yout, InPortout;

    // OUTPUTS FROM DataPath (wires)
    wire R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
    wire R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;
	 
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
        .opcode(ADD),
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
        .Rout(Rout)    // Added Rout
    );

    
   initial begin
      clock = 0;
		clear = 0;
   end
	 
	always 
		#10  clock <= ~clock;
		
	always @(posedge clock) begin
    case (Present_state)
        Default: Present_state <= T0;
        T0:      Present_state <= T1;
        T1:      Present_state <= T2;
        T2:      Present_state <= T3;
        T3:      Present_state <= T4;
        T4:      Present_state <= T5;
        T5:      Present_state <= T6;
        T6:      Present_state <= T7;
        T7:      Present_state <= Default; // Reset or stop
		endcase
	end 
	
	always @(Present_state) begin
			case (Present_state)
				Default: begin
                PCout <= 0;         Zhighout <= 0;      Zlowout <= 0;      MDRout <= 0;
                MARin <= 0;         PCin <= 0;          MDRin <= 0;        IRin <= 0;          Yin <= 0;
                IncPC <= 0;         Read <= 0;          Write <= 0;
                Gra <= 0;           Grb <= 0;           Grc <= 0;          ADD <= 0;
                HIin <= 0;          LOin <= 0;          ZHighIn <= 0;      ZLowIn <= 0; 
                Address <= 9'h0;    Mdatain <= 32'h0;
                Cout <= 0;  
            end
				
			T0: begin 
                #10 MARin <= 1;         IncPC <= 1;  	  PCout <= 1;   ZLowIn <= 1;
                
            end

			  T1: begin 
				PCout <= 0;     			 MARin <= 0;      	ZLowIn <= 0;
                #10 Zlowout <= 1;       PCin <= 1;       	Read <= 1;    	MDRin <= 1;  
                
            end

			  T2: begin 
				Zlowout <= 0;   			 PCin <= 0;       	MDRin <= 0;    IncPC <= 0;
                #10 MDRout <= 1;        IRin <= 1; 
            end

			  T3: begin 
				MDRout <= 0;     		 IRin <= 0;
                #10 Grb <= 1;           BAout <= 1;      	Yin <= 1; 
            end

			  T4: begin 
				Grb <= 0;         		 BAout <= 0;       	Yin <= 0;
                #10 Cout <= 1;          ADD <= 5'b00011;   	ZLowIn <= 1;  // Fixed naming and register assignment
            end

			  T5: begin 
				Cout <= 0;       		 ZLowIn <= 0;  		// Fixed incorrect Zin assignment
                #10 Zlowout <= 1;       MARin <= 1; 
                Zlowout <= 0;     		 MARin <= 0;
            end

			  T6: begin
				#10 Zlowout <= 0;     	 MARin <= 0;
                Read <= 1;              MDRin <= 1;		 
            end

			  T7: begin 
				#10 Read <= 0;        	 MDRin <= 0;  			// Fixed missing reset
                Gra <= 1;               MDRout <= 1;     	Rin <= 1;
                #10 Gra <= 0;           MDRout <= 0;     	Rin <= 0;
            end
		endcase
	end

endmodule