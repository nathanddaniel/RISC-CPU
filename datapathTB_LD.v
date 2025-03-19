//NOT TESTED

`timescale 1ns/1ps

//declaring the module, no inputs/outputs needed for a testbench
module datapathTB_LD;

    //declaring control signals...each register (reg) holds value for simulation
    reg Clock, Clear; //these control CPU clock and reset signal
    reg MARin, MDRin; 
    reg MDRout;
    reg Read, Write;

    reg HIin, LOin, ZHighIn, ZLowIn, Cin, Yin;
    reg HIout, LOut, Yout;

    reg InPortout, CSignOut;
    reg [4:0] LOAD;

    reg IncPC, PCin, IRin;
    reg PCout, Zhighout, Zlowout;

    reg R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, R8out;
    reg R9out, R10out, R11out, R12out, R13out, R14out, R15out;

    reg R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in;
    reg R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in;

    reg [8:0] Address;
    reg [31:0] Mdatain;
    reg [31:0] BusMuxOut;
    reg [31:0] BusMuxInMDR;

    /* 
    
    MARin: Loads value into the MAR
    Read: Reads from RAM into MDR
    MDRin: Loads MDR with data from RAM
    MDRout: Put MDR data onto the bus
    Address: Specifies the memory address being accessed
    Mdatain: Holds the value to be stored in RAM

    so would MDRin and Mdatain be the same thing??

    */

    // // Wires for output verification
    // wire [31:0] BusMuxInMDR;

    parameter 
    
    Default = 4'b0000, Reg_load1a = 4'b0001, Reg_load1b = 4'b0010,
    Reg_load2a = 4'b0011, Reg_load2b = 4'b0100, Reg_load3a = 4'b0101,
    Reg_load3b = 4'b0110, T0= 4'b0111, T1= 4'b1000,T2= 4'b1001, T3= 4'b1010, 
    T4= 4'b1011, T5= 4'b1100;

    reg [3:0] Present_state = Default;


    //instantiate the DataPath module
    /* 
    we're connecting all the control signals like MARin, MDRin, MDRout, 
    Read and Write. All unused control signals are set to 0, i.e theyre inactive

    */
    DataPath dp_inst (
        .PCout      (PCout), 
        .Zhighout   (Zhighout), 
        .Zlowout    (Zlowout), 
        .MDRout     (MDRout),
        
        .R0out      (R0out), 
        .R1out      (R1out), 
        .R2out      (R2out), 
        .R3out      (R3out), 
        .R4out      (R4out),
        .R5out      (R5out), 
        .R6out      (R6out), 
        .R7out      (R7out), 
        .R8out      (R8out), 
        .R9out      (R9out),
        .R10out     (R10out), 
        .R11out     (R11out), 
        .R12out     (R12out), 
        .R13out     (R13out), 
        .R14out     (R14out), 
        .R15out     (R15out),

        .HIout      (HIout), 
        .LOout      (LOout), 
        .Yout       (Yout),

        .InPortout  (InPortout), 
        .CSignOut   (CSignOut),
        
        .MARin      (MARin), 
        .PCin       (PCin), 
        .MDRin      (MDRin), 
        .IRin       (IRin), 
        .Yin        (Yin),
        .IncPC      (IncPC), 
        .Read       (Read), 
        .Write      (Write),

        .opcode     (LOAD),
        
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
        .HIin       (R16in), 
        .LOin       (R17in), 
        .ZHighIn    (R18in), 
        .ZLowIn     (ZLowIn), 
        .Cin        (Cin),

        .clock      (Clock), 
        .clear      (Clear),
        .Address    (Address), 
        .Mdatain    (Mdatain)
    );

    //this will toggle the clock every 10ns, creating a 20ns clock period
    initial
        begin 
            Clock = 0;
            forever #10 Clock = ~ Clock;
    end

    //initial setup and execution
    initial begin

        //the clock is intially low, and clear is activated, reseting all registers
        //all control signals that we're going to use is set to 0 to ensure no accidental operations happens
        Clock = 0; Clear = 1; MARin = 0; MDRin = 0; 
        MDRout = 0; Read = 0; Write = 0; R4in = 0;
        
        Mdatain = 32'b0;
        BusMuxOut = 32'b0;
        #10 Clear = 0; //releasing the reset
        
        //step 1: loading the address (5) into MAR using BusMuxOut 
        #10 BusMuxOut = 32'd5; //address value
        #10 MARin = 1; //load the address into MAR q register
        #10 MARin = 0;

        //step 2: load the data (0x12345678) into MDR using BusMuxOut
        #10 BusMuxOut = 32'h12345678; //value to put into RAM
        #10 MDRin = 1;  //load the value into MDR, no Mdatain which means loads from BusMuxOut
        #10 MDRin = 0;

        //step 3: write MDR value to RAM
        #10 Mdatain = BusMuxOut;
        #10 Write = 1;
        #10 Write = 0;
    end
     
endmodule
