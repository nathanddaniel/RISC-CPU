//NOT TESTED

`timescale 1ns/1ps

module datapathTB_LD;

    reg Clock, Clear;
    reg MARin, MDRin, MDRout, Read, Write, R4in;
    reg [8:0] Address;
    reg [31:0] Mdatain;

    // Wires for output verification
    wire [31:0] BusMuxInMDR;

    // Instantiate the DataPath module
    DataPath dp_inst (
        .PCout(0), .Zhighout(0), .Zlowout(0), .MDRout(MDRout),
        .R0out(0), .R1out(0), .R2out(0), .R3out(0), .R4out(0),
        .R5out(0), .R6out(0), .R7out(0), .R8out(0), .R9out(0),
        .R10out(0), .R11out(0), .R12out(0), .R13out(0), .R14out(0), .R15out(0),
        .HIout(0), .LOout(0), .Yout(0), .InPortout(0), .CSignOut(0),
        .MARin(MARin), .PCin(0), .MDRin(MDRin), .IRin(0), .Yin(0),
        .IncPC(0), .Read(Read), .Write(Write), .opcode(5'b00000),
        .R0in(0), .R1in(0), .R2in(0), .R3in(0), .R4in(R4in),
        .R5in(0), .R6in(0), .R7in(0), .R8in(0), .R9in(0), .R10in(0),
        .R11in(0), .R12in(0), .R13in(0), .R14in(0), .R15in(0),
        .HIin(0), .LOin(0), .ZHighIn(0), .ZLowIn(0), .Cin(0),
        .clock(Clock), .clear(Clear),
        .Address(Address), .Mdatain(Mdatain)
    );

    // Clock Generation
    always #10 Clock = ~Clock;

    initial begin
        Clock = 0; Clear = 1; MARin = 0; MDRin = 0; 
        MDRout = 0; Read = 0; Write = 0; R4in = 0;
        Address = 9'd0;
        Mdatain = 32'b0;
        
        #10 Clear = 0; // Release Reset
        
        // Step 1: Write a value to RAM (Address 5)
        #10 Mdatain = 32'h12345678;
        #10 Address = 9'd5;
        #10 Write = 1;  // Store in RAM
        #10 Write = 0;

        // Step 2: Execute Load (`ld R4, 5`)
        #10 MARin = 1; Address = 9'd5; // Load address into MAR
        #10 MARin = 0;

        #10 Read = 1;  // Trigger RAM read
        #10 Read = 0;

        #10 MDRin = 1; // Store RAM output in MDR
        #10 MDRin = 0;

        #10 MDRout = 1; R4in = 1; // Load MDR data into R4
        #10 MDRout = 0; R4in = 0;

    end
     
endmodule
