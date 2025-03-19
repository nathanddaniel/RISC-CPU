//NOT TESTED

`timescale 1ns/1ps

//declaring the module, no inputs/outputs needed for a testbench
module datapathTB_LD;

    //declaring control signals...each register (reg) holds value for simulation
    reg Clock, Clear; //these control CPU clock and reset signal
    reg MARin, MDRin, MDRout, Read, Write, R4in; 
    reg [8:0] Address;
    reg [31:0] Mdatain;

    /* 
    
    MARin: Loads value into the MAR
    Read: Reads from RAM into MDR
    MDRin: Loads MDR with data from RAM
    MDRout: Put MDR data onto the bus
    Address: Specifies the memory address being accessed
    Mdatain: Holds the value to be stored in RAM

    so would MDRin and Mdatain be the same thing??

    */

    // Wires for output verification
    wire [31:0] BusMuxInMDR;

    //instantiate the DataPath module
    /* 
    we're connecting all the control signals like MARin, MDRin, MDRout, 
    Read and Write. All unused control signals are set to 0, i.e theyre inactive



    */
    DataPath dp_inst (
        .PCout(0), 
        .Zhighout(0), 
        .Zlowout(0), 
        .MDRout(MDRout),
        .R0out(0), 
        .R1out(0), 
        .R2out(0), 
        .R3out(0), 
        .R4out(0),
        .R5out(0), 
        .R6out(0), 
        .R7out(0), 
        .R8out(0), 
        .R9out(0),
        .R10out(0), 
        .R11out(0), 
        .R12out(0), 
        .R13out(0), 
        .R14out(0), 
        .R15out(0),
        .HIout(0), 
        .LOout(0), 
        .Yout(0), 
        .InPortout(0), 
        .CSignOut(0),
        .MARin(MARin), 
        .PCin(0), 
        .MDRin(MDRin), 
        .IRin(0), 
        .Yin(0),
        .IncPC(0), 
        .Read(Read), 
        .Write(Write), 
        .opcode(5'b00000),
        .R0in(0), 
        .R1in(0), 
        .R2in(0), 
        .R3in(0), 
        .R4in(R4in),
        .R5in(0), 
        .R6in(0), 
        .R7in(0), 
        .R8in(0), 
        .R9in(0), 
        .R10in(0),
        .R11in(0), 
        .R12in(0), 
        .R13in(0), 
        .R14in(0), 
        .R15in(0),
        .HIin(0), 
        .LOin(0), 
        .ZHighIn(0), 
        .ZLowIn(0), 
        .Cin(0),
        .clock(Clock), 
        .clear(Clear),
        .Address(Address), 
        .Mdatain(Mdatain)
    );

    //this will toggle the clock every 10ns, creating a 20ns clock period
    always #10 Clock = ~Clock;

    //initial setup and execution
    initial begin

        //the clock is intially low, and clear is activated, reseting all registers
        //all control signals that we're going to use is set to 0 to ensure no accidental operations happens
        Clock = 0; Clear = 1; MARin = 0; MDRin = 0; 
        MDRout = 0; Read = 0; Write = 0; R4in = 0;
        Address = 9'd0;
        Mdatain = 32'b0;
        
        //after 10ns, Clear is set to 0, letting us carry out normal operation
        #10 Clear = 0; 
        
        // Step 1: Write a value to RAM (Address 5)
        #10 Mdatain = 32'h12345678;    //setting Mdatain = 0x12345678
        #10 Address = 9'd5;            //Storing the value at this address
        #10 Write = 1; #10 Write = 0;  // Store in RAM

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
