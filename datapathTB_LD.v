//NOT TESTED

`timescale 1ns/1ps

//declaring the module, no inputs/outputs needed for a testbench
module datapathTB_LD;

    //declaring control signals...each register (reg) holds value for simulation
    reg Clock, Clear; //these control CPU clock and reset signal
    reg MARin, MDRin, MDRout, Read, Write;
    reg PCout, Zhighout, Zlowout;
    reg R2out, R3
    reg R4in, R5in;
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

        .opcode     (5'b00000),
        
        .R0in       (R0in), 
        .R1in       (R1in), 
        .R2in       (R2in), 
        .R3in       (R3in), 
        .R4in       (R4in),
        .R5in       (R5in), 
        .R6in       (R6in), 
        .R7in       (0), 
        .R8in       (0), 
        .R9in       (0), 
        .R10in      (0),
        .R11in      (0), 
        .R12in      (0), 
        .R13in      (0), 
        .R14in      (0), 
        .R15in      (0),
        .HIin       (0), 
        .LOin       (0), 
        .ZHighIn    (0), 
        .ZLowIn     (0), 
        .Cin        (0),

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
		    T0				:	#40 Present_state = T1;
		    T1				:	#40 Present_state = T2;
		    T2				:	#40 Present_state = T3;
		    T3				:	#40 Present_state = T4;
		    T4				:	#40 Present_state = T5;
		endcase
    end

    always @(Present_state)
    begin
        case (Present_state)
            Default: begin
				PCout <= 0;   Zlowout <= 0; ZHighout <= 0;  MDRout<= 0;
				R2out <= 0;   R3out <= 0;   MARin <= 0;   ZLowIn <= 0;  
				PCin <=0;   MDRin <= 0;   IRin  <= 0;   Yin <= 0;  
				IncPC <= 0;   Read <= 0;   LSHIFT <= 0;
				R1in <= 0; R2in <= 0; R3in <= 0; Mdatain <= 32'h00000000;

                PCout <= 0;     Clock <= 0;     Clear <= 1;
                MARin <= 0;     MDRin <= 0;     MDRout <= 0;
                Read <= 0;      Write <= 0;     R4in <= 0;
                R5in <= 0;      R5out <= 0;     R4out <= 0;
                PCin <= 0;      
                Address <= 9'd0;         
                Mdatain = 32'b0;
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
		    T0: begin
				Mdatain <= 32'h00000007; 
				PCin <= 1; MDRout <=1;
				
				#10 PCout<= 1; MARin <= 1; IncPC <= 1; 
				#10 PCin <= 0; MDRout <=0; PCout<= 0; MARin <= 0; IncPC <= 0;
            end
            T1: begin
                    Mdatain <= 32'h5A1B8000;   // opcode for "shl R4, R3, R7"
                    Read <= 1; MDRin <= 1;		// 0101 1010 0001 1011 1000 0000 0000 0000 (5A1B8000)
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
                    R7out<= 1; LSHIFT <= 5'b01011; ZLowIn <= 1; 
                    #25 R7out<= 0; ZLowIn <= 0; 
            end
            T5: begin
                    Zlowout<= 1; R4in <= 1; 
                    #25 Zlowout<= 0; R4in <= 0;
            end
        endcase

    end

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
