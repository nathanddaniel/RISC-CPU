`timescale 1ns / 10ps
module datapathTB_ADD; 	
	reg	PCout, ZHighout, Zlowout, MDRout, R2out, R3out, R4out, R5out, R6out, R7out;
	reg	MARin, PCin, MDRin, IRin, Yin;
	reg 	IncPC, Read;
	reg 	[4:0] ADD; 
	reg 	R1in, R2in, R3in;
	reg   R4in, R5in, R6in, R7in, R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in;
	reg	HIin, LOin, ZHighIn, ZLowIn, Cin;
	reg	Clock, Clear;	
	reg	[31:0] Mdatain;

parameter	Default = 4'b0000, Reg_load1a= 4'b0001, Reg_load1b= 4'b0010,
					Reg_load2a= 4'b0011, Reg_load2b = 4'b0100, Reg_load3a = 4'b0101,
					Reg_load3b = 4'b0110, T0= 4'b0111, T1= 4'b1000,T2= 4'b1001, T3= 4'b1010, T4= 4'b1011, T5= 4'b1100;
reg	[3:0] Present_state= Default;

initial Clear = 0;

DataPath DUT (
        .PCout      (PCout),
        .Zhighout   (ZHighout),
        .Zlowout    (Zlowout),
        .MDRout     (MDRout),

        .R0out      (R0out),
        .R2out      (R2out),
        .R3out      (R3out),
        .R4out      (R4out),
        .R5out      (R5out),
        .R6out      (R6out),
        .R7out      (R7out),

        .MARin      (MARin),
        .PCin       (PCin),
        .MDRin      (MDRin),
        .IRin       (IRin),
        .Yin        (Yin),
        .IncPC      (IncPC),
        .Read       (Read),

        .opcode     (ADD),   // 5-bit opcode

        .R0in       (R0in),
        .R1in       (R1in),
        .R2in       (R2in),
        .R3in       (R3in),
        .R4in       (R4in),
        .R5in       (R5in),
        .R6in       (R6in),
        .R7in       (R7in),
        .R8in       (R8in),
        .R9in       (R9in),
        .R10in      (R10in),
        .R11in      (R11in),
        .R12in      (R12in),
        .R13in      (R13in),
        .R14in      (R14in),
        .R15in      (R15in),

        .HIin       (HIin),
        .LOin       (LOin),
        .ZHighIn    (ZHighIn),
        .ZLowIn     (ZLowIn),
        .Cin        (Cin),

        .clock      (Clock),
        .clear      (Clear),
        .Mdatain    (Mdatain)
    );
// add test logic here

initial 
	begin
		Clock = 0;
		forever #10 Clock = ~ Clock;
end

always @(posedge Clock)
begin
	case (Present_state)
		Default			:	#40 Present_state = Reg_load1a;
		Reg_load1a		:	#40 Present_state = Reg_load1b;
		Reg_load1b		:	#40 Present_state = Reg_load2a;
		Reg_load2a		:	#40 Present_state = Reg_load2b;
		Reg_load2b		:	#40 Present_state = Reg_load3a;
		Reg_load3a		:	#40 Present_state = Reg_load3b;
		Reg_load3b		:	#40 Present_state = T0;
		T0					:	#40 Present_state = T1;
		T1					:	#40 Present_state = T2;
		T2					:	#40 Present_state = T3;
		T3					:	#40 Present_state = T4;
		T4					:	#40 Present_state = T5;
		endcase
	end

always @(Present_state)
begin
	case (Present_state)
		Default: begin
				PCout <= 0;   Zlowout <= 0; ZHighout <= 0;  MDRout<= 0;
				R2out <= 0;   R3out <= 0;   MARin <= 0;   ZLowIn <= 0;  
				PCin <=0;   MDRin <= 0;   IRin  <= 0;   Yin <= 0;  
				IncPC <= 0;   Read <= 0;   ADD <= 0;
				R1in <= 0; R2in <= 0; R3in <= 0; Mdatain <= 32'h00000000;
		end
		Reg_load1a: begin 
				Mdatain<= 32'h00000012;
				Read = 0; MDRin = 0;	
				#10 Read <= 1; MDRin <= 1;  
				#15 Read <= 0; MDRin <= 0;
		end
		Reg_load1b: begin
				#10 MDRout<= 1; R4in <= 1;  
				#15 MDRout<= 0; R4in <= 0;     // initialize R4 with the value 0x12 (ANS: 1000 0000)
		end
		Reg_load2a: begin 
				Mdatain <= 32'h0000007F;
				#10 Read <= 1; MDRin <= 1;  
				#15 Read <= 0; MDRin <= 0;
		end
		Reg_load2b: begin
				#10 MDRout<= 1; R3in <= 1;  
				#15 MDRout<= 0; R3in <= 0;		// initialize R3 with the value 0x7F (0111 1111)
		end
		Reg_load3a: begin 
				Mdatain <= 32'h00000001;
				#10 Read <= 1; MDRin <= 1;  
				#15 Read <= 0; MDRin <= 0;
		end
		Reg_load3b: begin
				#10 MDRout<= 1; R7in <= 1;  
				#15 MDRout<= 0; R7in <= 0;		// initialize R7 with the value 0x01 (0000 0001)
		end
	
		T0: begin
				Mdatain <= 32'h00000007; 
				PCin <= 1; MDRout <=1;
				
				#10 PCout<= 1; MARin <= 1; IncPC <= 1; 
				#10 PCin <= 0; MDRout <=0; PCout<= 0; MARin <= 0; IncPC <= 0;
		end
		T1: begin
				Mdatain <= 32'h1A1B8000;   // opcode for "add R4, R3, R7"
				Read <= 1; MDRin <= 1;		// 0001 1010 0001 1011 1000 0000 0000 0000 (1A1B8000)
				#10 Read <= 0; MDRin <= 0;
				
		end
		T2: begin
				MDRout<= 1; IRin <= 1; 
				#10 MDRout<= 0; IRin <= 0; 
		end
		T3: begin
				#10 R3out<= 1; Yin <= 1;  
				#15 R3out<= 0; Yin <= 0;
		end
		T4: begin
				R7out<= 1; ADD <= 5'b00011; ZLowIn <= 1; 
				#25 R7out<= 0; ZLowIn <= 0; 
		end
		T5: begin
				Zlowout<= 1; R4in <= 1; 
				#25 Zlowout<= 0; R4in <= 0;
		end
	endcase
end
endmodule