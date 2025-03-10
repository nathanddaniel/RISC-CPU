//NOT TESTED

`timescale 1ns/1ps

module datapathTB_LD;

    reg Clock, Clear;         
    reg MARin, MDRin, MDRout;   // Control signals
    reg Read, Write;            // Memory Read/Write control
    reg R4in;
    reg [31:0] BusMuxOut;       // Data from Bus
    wire [31:0] BusMuxInMDR;   // Data from MDR to Bus
    wire [8:0] Address;         // Address to RAM
    wire [31:0] Data;           // Data from RAM

    // Instantiate MAR
    //memory subsystem file where we initialize the MAR, RAM and MDR all in one.

    // Clock Generation
    initial 
        begin 
            Clock = 0;
            forever #10 Clock = ~Clock;
    end

    // State Machine Declaration
    parameter Default = 3'b000, Reg_load1 = 3'b001, T0 = 3'b010, 
              T1 = 3'b011, T2 = 3'b100, T3 = 3'b101, T4 = 3'b110;

    // State Transition Logic
    always @(posedge Clock) begin
        case (Present_state)
            Default:    Present_state = Reg_load1;
            Reg_load1a:  Present_state = Reg_load1a;
            Reg_load1b:  Present_state = T0;
            T0:         Present_state = T1;
            T1:         Present_state = T2;
            T2:         Present_state = T3;
            T3:         Present_state = T4;
            T4:         Present_state = Default; 
        endcase
    end
    
    always @(Present_state)
    begin   
        case (Present_state)
            Default: begin
                MARin = 0; MDRin = 0; MDRout = 0;
                Read = 0; Write = 0; R4in = 0;
                BusMuxOut = 32'b0;
            end

            Reg_load1a: begin
                Mdatain <= 32'h00000012;
                Read = 0; MDRin = 0;
                #10 Read <= 1; MDRin <= 1;
                #15 Read <= 0; MDRin <= 0;
            end
            Reg_load1b: begin
                Clear <= 1; MARin <= 0; MDRin <= 0;
                BusMuxOut <= 32'b0; Clear <= 0;
            end
            Reg_load1b: begin
                #10 MDRout <= 1; R4in <= 1;
                #15 MDRout <= 0; R4in <= 0;
            end

            T0: begin 
                #10 Address = 9'd5;
                #10 BusMuxOut = 32'h1245678;
                #10 Write = 1;
                #10 Write = 0;
            end

            T1: begin
                Clear <= 1; MARin <= 0; MDRin <= 0;
                BusMuxOut <= 32'b0;
            end

            T2: begin
                // Step 2: Load from memory (ld instruction simulation)
                #10 MARin = 1; BusMuxOut = 9'd5;  // Load Address 5 into MAR
                #10 MARin = 0;

                #10 Read = 1;  // Trigger Read Signal
                #10 Read = 0;
            end

            T3: begin
                #10 MDRin = 1;  //loading the MDR with data from RAM
                #10 MDRin = 0;
            end

            T4: begin
                #10 MDRout = 1;  R4in <= 1; // Place MDR data onto Bus and then putting the value into the R4 register
                #10 MDRout = 0;  R4in <= 1;
            end
        endcase
    end 
endmodule
