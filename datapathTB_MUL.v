`timescale 1ns / 10ps
module datapathTB_MUL; 	
	reg	PCout, ZHighout, Zlowout, MDRout, R0out, R2out, R3out, R4out, R5out, R6out, R7out;
	reg	MARin, PCin, MDRin, IRin, Yin;
	reg 	IncPC, Read;
	reg 	[4:0] MUL; 
	reg 	R0in, R1in, R2in, R3in;
	reg   R4in, R5in, R6in, R7in, R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in;
	reg	HIout, LOout, HIin, LOin, ZHighIn, ZLowIn, Cin;
	reg	Clock, Clear;	
	reg	[31:0] Mdatain;

    parameter  Default    = 4'b0000,
               Reg_load1a = 4'b0001, Reg_load1b = 4'b0010,
               Reg_load2a = 4'b0011, Reg_load2b = 4'b0100,
               Reg_load3a = 4'b0101, Reg_load3b = 4'b0110,
               T0         = 4'b0111, T1         = 4'b1000,
               T2         = 4'b1001, T3         = 4'b1010,
               T4         = 4'b1011, T5         = 4'b1100,
               T6         = 4'b1101;  // For HI register load

    reg [3:0] Present_state = Default;

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

        .opcode     (MUL),   // 5-bit opcode

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

    initial begin
        Clock = 0;
        forever #10 Clock = ~Clock;
    end

    always @(posedge Clock)
    begin
        case (Present_state)
            Default   : #40 Present_state = Reg_load1a;
            Reg_load1a: #40 Present_state = Reg_load1b;
            Reg_load1b: #40 Present_state = Reg_load2a;
            Reg_load2a: #40 Present_state = Reg_load2b;
            Reg_load2b: #40 Present_state = Reg_load3a;
            Reg_load3a: #40 Present_state = Reg_load3b;
            Reg_load3b: #40 Present_state = T0;
            T0        : #40 Present_state = T1;
            T1        : #40 Present_state = T2;
            T2        : #40 Present_state = T3;
            T3        : #40 Present_state = T4;
            T4        : #40 Present_state = T5;
            T5        : #40 Present_state = T6;
        endcase
    end

    always @(Present_state)
    begin
        case (Present_state)

            Default: begin
                PCout   <= 0;   Zlowout  <= 0;   ZHighout <= 0;   MDRout  <= 0;
                R2out   <= 0;   R6out    <= 0;   MARin    <= 0;   ZLowIn  <= 0;
                PCin    <= 0;   MDRin    <= 0;   IRin     <= 0;   Yin     <= 0;
                IncPC   <= 0;   Read     <= 0;   MUL      <= 0;
                R1in    <= 0;   R2in     <= 0;   R6in     <= 0;
                HIin    <= 0;   LOin     <= 0;   ZHighIn  <= 0;   ZLowIn  <= 0;
                Mdatain <= 32'h00000000;
            end

            Reg_load1a: begin
                Mdatain <= 32'h00000012;
                Read    = 0;   MDRin = 0; 
                #10 Read <= 1; MDRin <= 1;  
                #15 Read <= 0; MDRin <= 0;
            end

            Reg_load1b: begin
                #10 MDRout <= 1; R2in <= 1;  
                #15 MDRout <= 0; R2in <= 0;   // R2 = 0x12
            end

            Reg_load2a: begin 
                Mdatain <= 32'h00000014;
                #10 Read <= 1; MDRin <= 1;  
                #15 Read <= 0; MDRin <= 0;
            end

            Reg_load2b: begin
                #10 MDRout <= 1; R6in <= 1;  
                #15 MDRout <= 0; R6in <= 0;   // R6 = 0x14
            end

            Reg_load3a: begin
                Mdatain <= 32'h00000018;
                #10 Read <= 1; MDRin <= 1;
                #15 Read <= 0; MDRin <= 0;
            end

            Reg_load3b: begin
                #10 MDRout <= 1; LOin <= 1;
                #15 MDRout <= 0; LOin <= 0;   // LO = 0x18 just to test if value drives
            end

            // T0: PCout, MARin, IncPC, Zin
            T0: begin
                #10 PCout <= 1; MARin <= 1; IncPC <= 1; ZLowIn <= 1;
                #10 PCout <= 0; MARin <= 0; IncPC <= 0; ZLowIn <= 0;
            end

            // T1: Zlowout, PCin, Read, Mdatain[31..0], MDRin
            T1: begin
                Zlowout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
                Mdatain <= 32'h81300000;  // opcode for "mul R2, R6" (1000 0001 0011 0000 0000 0000 0000 0000)
                #10 Zlowout <= 0; PCin <= 0; Read <= 0; MDRin <= 0;
            end

            // T2: MDRout, IRin
            T2: begin
                #10 MDRout <= 1; IRin <= 1;
                #15 MDRout <= 0; IRin <= 0;
            end

            // T3: R2out, Yin
            T3: begin
                #10 R2out <= 1; Yin <= 1;
                #15 R2out <= 0; Yin <= 0;
            end

            // T4: R6out, MUL, Zin
            T4: begin
                #10 R6out <= 1; MUL <= 5'b10000; ZHighIn <= 1; ZLowIn <= 1;
                #25 R6out <= 0; MUL <= 0; ZHighIn <= 0; ZLowIn <= 0;
            end

            // T5: Zlowout, LOin
            T5: begin
                #10 Zlowout <= 1; LOin <= 1;
                #25 Zlowout <= 0; LOin <= 0; 
            end

            // T6: Zhighout, HIin
            T6: begin
                #10 ZHighout <= 1; HIin <= 1;
                #25 ZHighout <= 0; HIin <= 0;
            end
        endcase
    end
endmodule