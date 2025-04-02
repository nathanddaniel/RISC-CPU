
`timescale 1ns/10ps

module ControlUnit (
    input [31:0] IR,              							
    input Clock, Reset, 
	input Run, Stop, CON_FF, Interrupts,

    //control Signals to/from Datapath
    output reg Gra, Grb, Grc, Rin, Rout,
    output reg Clear,
    output reg InPortout,         
    output reg Read, Write,

    //ALU and Operation Control Signals
    output reg ADD, SUB, AND, OR,
    output reg ROR, ROL, SHR, SHRA, SHL,
    output reg ADDI, ANDI, ORI,
    output reg DIV, MUL, NEG, NOT,

    //Branch and Jump Instructions
    output reg BRZR, BRNZ, BRMI, BRPL,
    output reg JAR, JR,

    //I/O Instructions
    output reg IN, OUT,

    //Move from HI/LO
    output reg MFLO, MFHI,

    //Special Instructions
    output reg NOP, HALT,

    //control Signals for Registers
    output reg HIin, LOin, CONin,
    output reg PCin, IRin, Yin, Zin,
    output reg ZHighIn, ZLowIn,
    output reg MARin, MDRin, OutPortin,
    output reg Cout, BAout,

    //output control signals
    output reg PCout, MDRout,
    output reg Zhighout, Zlowout,
    output reg HIout, LOout,
	 output reg IncPC
);

	//defining state parameters for FSM
	//basically creating set of states for each part of the instruction processing
	//provides a framework for the FSM to transition between states and helps assign control signals cleanly in a case(present_state) block
	parameter 
    reset_state = 8'b00000000, 
    fetch0 = 8'b00000001, 
    fetch1 = 8'b00000010, 
    fetch2 = 8'b00000011,

	//ADD Instruction
    add3 = 8'b00000100,
    add4 = 8'b00000101,
    add5 = 8'b00000110,

	//SUB Instruction
    sub3 = 8'b00000111,
    sub4 = 8'b00001000,
    sub5 = 8'b00001001,

    //AND Instruction
    and3 = 8'b00001010, 
    and4 = 8'b00001011, 
    and5 = 8'b00001100,

    //OR Instruction
    or3 = 8'b00001101, 
    or4 = 8'b00001110, 
    or5 = 8'b00001111,

    //ROR Instruction
    ror3 = 8'b00010000, 
    ror4 = 8'b00010001, 
    ror5 = 8'b00010010,

    //ROL Instruction
    rol3 = 8'b00010011, 
    rol4 = 8'b00010100, 
    rol5 = 8'b00010101,

    //SHR Instruction
    shr3 = 8'b00010110, 
    shr4 = 8'b00010111, 
    shr5 = 8'b00011000,

    //SHRA Instruction
    shra3 = 8'b00011001,
    shra4 = 8'b00011010,
    shra5 = 8'b00011011,

    //SHL Instruction
    shl3 = 8'b00011100, 
    shl4 = 8'b00011101, 
    shl5 = 8'b00011110,

    //ADDI Instruction
    addi3 = 8'b00011111, 
    addi4 = 8'b00100000, 
    addi5 = 8'b00100001,

    //ANDI Instruction
    andi3 = 8'b00100010, 
    andi4 = 8'b00100011, 
    andi5 = 8'b00100100,

    //ORI Instruction
    ori3 = 8'b00100101, 
    ori4 = 8'b00100110, 
    ori5 = 8'b00100111,

    //DIV Instruction
    div3 = 8'b00101000, 
    div4 = 8'b00101001,
    div5 = 8'b00101010, 
    div6 = 8'b00101011,

	//MUL Instruction
    mul3 = 8'b00101100, 
    mul4 = 8'b00101101, 
    mul5 = 8'b00101110, 

	//NEG Instruction
    neg3 = 8'b00101111, 
    neg4 = 8'b00110000, 
    neg5 = 8'b00110001,

	//NOT Instruction
    not3 = 8'b00110010, 
    not4 = 8'b00110011, 
    not5 = 8'b00110100,

    //Branch Instructions
    br3 = 8'b00110101, 
    br4 = 8'b00110110, 
    br5 = 8'b00110111, 
    br6 = 8'b00111000, 
    br7 = 8'b00111001,  

    //Jump Instructions (JR, JAR)
    jr3 = 8'b00111010, 
    jal3 = 8'b00111011, 
    jal4 = 8'b00111100,

	//Load (LD) Instruction
    ld3 = 8'b00111101, 
    ld4 = 8'b00111110, 
    ld5 = 8'b00111111, 
    ld6 = 8'b01000000, 
    ld7 = 8'b01000001,

	//Load Immediate (LDI)
    ldi3 = 8'b01000010, 
    ldi4 = 8'b01000011, 
    ldi5 = 8'b01000100,
    ldi6 = 8'b01000101, 
    ldi7 = 8'b01000110,

	//Store (ST) Instruction
    st3 = 8'b01000111, 
    st4 = 8'b01001000, 
    st5 = 8'b01001001, 
    st6 = 8'b01001010, 
    st7 = 8'b01001011,

	//Move From HI/LO
    mfhi3 = 8'b01001100, 
    mflo3 = 8'b01001101,

	//Input and Output Instructions
    in3 = 8'b01001110, 
    out3 = 8'b01001111,

    // Special Instructions
    nop3  = 8'b01010000, 
    halt3 = 8'b01010001; 

	// Register to store current state
	reg [8:0] present_state = reset_state;  

	// FSM - State Transition Logic
	always @(posedge Clock or posedge Reset)  
	begin
		 if (Reset) 
			  present_state <= reset_state;
		 else 
			  
			  case (present_state)
					reset_state	: present_state <= fetch0;
					fetch0 : present_state <= fetch1;
					fetch1 : present_state <= fetch2;
					fetch2 : begin
					
							 case (IR[31:27])
								  // ALU and Operation Instructions
								  5'b00011: present_state <= add3; //ADD
								  5'b00100: present_state <= sub3; //SUB
								  5'b00101: present_state <= and3; //AND
								  5'b00110: present_state <= or3;  //OR
								  5'b00111: present_state <= ror3; //ROR
								  5'b01000: present_state <= rol3; //ROL
								  5'b01001: present_state <= shr3; //SHR
								  5'b01010: present_state <= shra3; //SHRA
								  5'b01011: present_state <= shl3; //SHL

								  5'b01100: present_state <= addi3; //ADDI
								  5'b01101: present_state <= andi3; //ANDI
								  5'b01110: present_state <= ori3; //ORI

								  5'b01111: present_state <= div3; //DIV
								  5'b10000: present_state <= mul3; //MUL
								  5'b10001: present_state <= neg3; //NEG
								  5'b10010: present_state <= not3; //NOT

								  // Branch and Jump Instructions
								  5'b10011: present_state <= br3; //Branch
								  5'b10100: present_state <= jal3; //JAR
								  5'b10101: present_state <= jr3; //JR

								  // I/O Instructions
								  5'b10110: present_state <= in3; //IN
								  5'b10111: present_state <= out3; //OUT

								  // Move from HI/LO
								  5'b11000: present_state <= mflo3; //MFLO
								  5'b11001: present_state <= mfhi3; //MFHI

								  // Load/Store Instructions
								  5'b00000: present_state <= ld3; //LD
								  5'b00001: present_state <= ldi3; //LDI
								  5'b00010: present_state <= st3; //ST

								  default: present_state <= reset_state;
							 endcase
					end
					
					//add instruction
					add3: present_state <= add4;
					add4: present_state <= add5;
					add5: present_state <= reset_state;
					
					//sub instruction
					sub3: present_state <= sub4;
					sub4: present_state <= sub5;
					sub5: present_state <= reset_state;

                    //and instruction
					and3: present_state <= and4;
					and4: present_state <= and5;
					and5: present_state <= reset_state;

                    //or instruction
					or3: present_state <= or4;
					or4: present_state <= or5;
					or5: present_state <= reset_state;

                    //ror instruction
					ror3: present_state <= ror4;
					ror4: present_state <= ror5;
					ror5: present_state <= reset_state;

                    //rol instruction
					rol3: present_state <= rol4;
					rol4: present_state <= rol5;
					rol5: present_state <= reset_state;

                    //shr instruction
					shr3: present_state <= shr4;
					shr4: present_state <= shr5;
					shr5: present_state <= reset_state;

                    //shra instruction
                    shra3: present_state <= shra3;
                    shra4: present_state <= shra4;
                    shra5: present_state <= reset_state;
					
					//shl instruction
					shl3: present_state <= shl4;
					shl4: present_state <= shl5;
					shl5: present_state <= reset_state;

                    //addi instruction
					addi3: present_state <= addi4;
					addi4: present_state <= addi5;
					addi5: present_state <= reset_state;

					//andi instruction
					andi3: present_state <= andi4;
					andi4: present_state <= andi5;
					andi5: present_state <= reset_state;

					//ori instruction
					ori3: present_state <= ori4;
					ori4: present_state <= ori5;
					ori5: present_state <= reset_state;

                    //div instruction
					div3: present_state <= div4;
					div4: present_state <= div5;
					div5: present_state <= div6;
					div6: present_state <= reset_state;
					
					//mul instruction
					mul3: present_state <= mul4;
					mul4: present_state <= mul5;
					mul5: present_state <= reset_state;
								
					//neg instruction
					neg3: present_state <= neg4;
					neg4: present_state <= neg5;
					neg5: present_state <= reset_state;
					
					//not instruction
					not3: present_state <= not4;
					not4: present_state <= not5;
					not5: present_state <= reset_state;

                    //branching instructions
					br3: present_state <= br4;
					br4: present_state <= br5;
					br5: present_state <= br6;
					br6: present_state <= br7;
					br7: present_state <= reset_state;

					// JR Instruction
                    jr3: present_state <= reset_state;

                    // JAL Instruction
                    jal3: present_state <= jal4;
                    jal4: present_state <= reset_state;
					
					//ld instruction
					ld3: present_state <= ld4;
					ld4: present_state <= ld5;
					ld5: present_state <= ld6;
					ld6: present_state <= ld7;
					ld7: present_state <= reset_state;
					
					//ldi instruction
					ldi3: present_state <= ldi4;
					ldi4: present_state <= ldi5;
                    ldi5: present_state <= ldi6;
                    ldi6: present_state <= ldi7;
					ldi7: present_state <= reset_state;
					
					//st instruction
					st3: present_state <= st4;
					st4: present_state <= st5;
					st5: present_state <= st6;
					st6: present_state <= st7;
					st7: present_state <= reset_state;
					
					// MFHI / MFLO
					mfhi3: present_state <= reset_state;
					mflo3: present_state <= reset_state;

					// IN / OUT
					in3: present_state <= reset_state;
					out3: present_state <= reset_state;

					// NOP
					nop3: present_state <= reset_state;

					// HALT
					halt3: present_state <= halt3; //looping forever in HALT

					default: present_state <= reset_state;
			  endcase
	end

	// FSM - Control Signal Assignments
	always @(present_state)  
	begin
		 // Default de-assert all signals
		 Gra <= 0; 			Grb <= 0; 		 Grc <= 0; 			Rin <= 0; 			Rout <= 0;
		 BAout <= 0; 		Cout <= 0;		 Read <= 0; 		Write <= 0; 		MARin <= 0; 
		 MDRin <= 0; 		MDRout <= 0;	 PCin <= 0; 		PCout <= 0; 		IRin <= 0; 
		 IncPC <= 0;		Yin <= 0; 		 Zin <= 0; 			Zhighout <= 0; 	Zlowout <= 0;
		 HIin <= 0; 		LOin <= 0; 		 HIout <= 0; 		LOout <= 0;			CONin <= 0; 
		 Clear <= 0;		ADD <= 0; 		 SUB <= 0; 			AND <= 0; 
		 OR <= 0;			SHR <= 0; 		 SHRA <= 0; 		SHL <= 0; 			ROL <= 0; 
		 ROR <= 0;			ADDI <= 0; 		 ANDI <= 0; 		ORI <= 0;			DIV <= 0; 
		 MUL <= 0; 			NEG <= 0; 		 NOT <= 0;			BRZR <= 0; 			BRNZ <= 0; 
		 BRMI <= 0; 		BRPL <= 0;		 JAR <= 0; 			JR <= 0;				IN <= 0; 
		 OUT <= 0; 			InPortout <= 0; OutPortin <= 0;	MFLO <= 0; 			MFHI <= 0; 
		 NOP <= 0; 			HALT <= 0;

		 case (present_state)
			  // Reset state: initialize everything
			reset_state: begin
				Gra <= 0; 	Grb <= 0;	Grc <= 0; 
				Rin <= 0;	Rout <= 0; 
				Yin <= 0;	Zin <= 0;
					
				PCin <= 1; //setting PC to 0
				Clear <= 1; //clearing internal register states, if needed	  
			end

			// Fetch cycle
			fetch0: begin
				PCout <= 1; //outputting the PC's value onto the bus
				MARin <= 1; //loading the bus value into MAR
				IncPC <= 1; //incrementing the PC internally
			end
			  
			fetch1: begin
				PCout <= 0;
				MARin <= 0;
				IncPC <= 0;
				
				Read <= 1; //reading from memory at the MAR address
				MDRin <= 1; //storing the fetched data into MDR
			end

			fetch2: begin
				Read <= 0;
				MDRin <= 0;
			
				MDRout <= 1; //put the value (the instruction) in MDR onto the bus
				IRin <= 1; //load instruction into the IR
			end

            //Executing the ADD instruction
			add3: begin
				MDRout <= 0;
				IRin <= 0;
			
				Grb <= 1; //selecting the register Rb
				Rout <= 1; //outputting its value onto the bus
				Yin <= 1; //storing the bus value in the Y reg
			end
			
            add4: begin
				Grb <= 0;
				Rout <= 0;
				Yin <= 0;
				
				Grc <= 1; //selecting register Rc 
				Rout <= 1; //outputting its value onto the bus
				ADD <= 1; //calling the ADD operation in the ALU
				Zin <= 1; //the ALU result (Rb + Rc) is stored in the Z register
			end

            add5: begin
				Grc <= 0;
				Rout <= 0;
				ADD <= 0;
				Zin <= 0;
			
                Zlowout <= 1; //outputting the result 
                Gra <= 1; //selected the destination register (Ra)
                Rin <= 1; //storing the value (ALU result) on the bus into Ra
            end

            // Execution: SUB instruction
            sub3: begin
			    MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the register Rb
                Rout <= 1; //outputting its value onto the bus
                Yin <= 1; //storing the bus value in the Y reg
            end

            sub4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                Grc <= 1; //selecting the register Rc 
                Rout <= 1; //outputting its value onto the bus
                SUB <= 1; //calling the SUB operation in the ALU
                Zin <= 1; //the ALU result is stored in the Z register
            end

            sub5: begin
                Grc <= 0;
                Rout <= 0;
                SUB <= 0;
                Zin <= 0;

                Zlowout <= 1; //outputting the result
                Gra <= 1; //selected the destination register (Ra)
                Rin <= 1; //storing the value (ALU result) on the bus into Ra
            end
            
			// Execution: AND instruction
			and3: begin
				MDRout <= 0;
				IRin <= 0;
			
				Grb <= 1; //selecting the register Rb
				Rout <= 1; //outputting its value onto the bus
				Yin <= 1;  //storing the bus value in the Y reg
			end
			
            and4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

				Grc <= 1; //selecting the register Rc
				Rout <= 1; //outputting its value onto the bus
				AND <= 1; //calling the AND operation in the ALU
				Zin <= 1; //the ALU result is stored in the Z register
			end

            and5: begin
                Grc <= 0;
                Rout <= 0;
                AND <= 0;
                Zin <= 0;

                Zlowout <= 1; //outputting the result
                Gra <= 1; //selected the destination register (Ra)
                Rin <= 1; //storing the value (ALU result) on the bus into Ra
            end

            //Executing the OR instruction
            or3: begin
			    MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the register Rb
                Rout <= 1; //outputting its value onto the bus    
                Yin <= 1; //storing the bus value in the Y reg
            end

            or4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                Grc <= 1; //selecting the register Rc
                Rout <= 1; //outputting its value onto the bus
                OR <= 1; //calling the OR operation in the ALU
                Zin <= 1; //the ALU result is stored in the Z register
            end

            or5: begin
                Grc <= 0;
                Rout <= 0;
                OR <= 0;
                Zin <= 0;

                Zlowout <= 1; //outputting the result
                Gra <= 1; //selected the destination register (Ra)
                Rin <= 1; //storing the value (ALU result) on the bus into Ra
            end   

            //Execution: ROR instruction
            ror3: begin
				MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the register Rb
                Rout <= 1; //outputting its value onto the bus  
                Yin <= 1; //storing the bus value in the Y reg
            end

            ror4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                Grc <= 1; //selecting the register Rc
                Rout <= 1; //outputting its value onto the bus
                ROR <= 1; //calling the ROR operation in the ALU
                Zin <= 1; //the ALU result is stored in the Z register
            end

            ror5: begin
                Grc <= 0;
                Rout <= 0;
                ROR <= 0;
                Zin <= 0;

                Zlowout <= 1; //outputting the result
                Gra <= 1; //selected the destination register (Ra)
                Rin <= 1; //storing the value (ALU result) on the bus into Ra
            end

            //Execution: ROL instruction 
            rol3: begin
				MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the register Rb
                Rout <= 1; //outputting its value onto the bus   
                Yin <= 1; //storing the bus value in the Y reg
            end

            rol4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                Grc <= 1; //selecting the register Rc
                Rout <= 1; //outputting its value onto the bus
                ROL <= 1; //calling the ROL operation in the ALU
                Zin <= 1; //the ALU result is stored in the Z register
            end

            rol5: begin
                Grc <= 0;
                Rout <= 0;
                ROL <= 0;
                Zin <= 0;

                Zlowout <= 1; //outputting the result
                Gra <= 1; //selected the destination register (Ra)
                Rin <= 1; //storing the value (ALU result) on the bus into Ra
            end

            //Execution: SHR instruction
            shr3: begin
			    MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the register Rb
                Rout <= 1; //outputting its value onto the bus
                Yin <= 1; //storing the bus value in the Y reg
            end

            shr4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                Grc <= 1; //selecting the register Rc
                Rout <= 1; //outputting its value onto the bus 
                SHR <= 1; //calling the SHR operation in the ALU
                Zin <= 1; //the ALU result is stored in the Z register
            end

            shr5: begin
                Grc <= 0;
                Rout <= 0;
                SHR <= 0;
                Zin <= 0;

                Zlowout <= 1; //outputting the result
                Gra <= 1; //selected the destination register (Ra)
                Rin <= 1; //storing the value (ALU result) on the bus into Ra
            end

            //Execution: SHRA instruction
            shra3: begin
				MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the register Rb
                Rout <= 1; //outputting its value onto the bus
                Yin <= 1; //storing the bus value in the Y reg
            end

            shra4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                Grc <= 1; //selecting the register Rc
                Rout <= 1; //outputting its value onto the bus
                SHRA <= 1; //calling the SHR operation in the ALU
                Zin <= 1; //the ALU result is stored in the Z register
            end
            
            shra5: begin
                Grc <= 0;
                Rout <= 0;
                SHRA <= 0;
                Zin <= 0;

                Zlowout <= 1; //outputting the result
                Gra <= 1; //selected the destination register (Ra)
                Rin <= 1; //storing the value (ALU result) on the bus into Ra
            end

            //Execution: SHL instruction
            shl3: begin
				MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the register Rb
                Rout <= 1; //outputting its value onto the bus
                Yin <= 1; //storing the bus value in the Y reg
            end

            shl4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                Grc <= 1; //selecting the register Rc
                Rout <= 1; //outputting its value onto the bus
                SHL <= 1; //calling the SHL operation in the ALU
                Zin <= 1; //the ALU result is stored in the Z register
            end

            shl5: begin
                Grc <= 0;
                Rout <= 0;
                SHL <= 0;
                Zin <= 0;

                Zlowout <= 1; //outputting the result
                Gra <= 1; //selected the destination register (Ra)
                Rin <= 1; //storing the value (ALU result) on the bus into Ra
            end

            //Execution: ADDI instruction
            addi3: begin
				MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the register Rb
                Rout <= 1; //outputting its value onto the bus
                Yin <= 1; //storing the bus value in the Y reg
            end

            addi4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                Cout <= 1; //outputting the constant 
                ADD <= 1; //calling the ADD operation in the ALU
                Zin <= 1; //the ALU result is stored in the Z register
            end

            addi5: begin
                Cout <= 0;
                ADD <= 0;
                Zin <= 0;

                Zlowout <= 1; //outputting the result
                Gra <= 1; //selected the destination register (Ra)
                Rin <= 1; //storing the value (ALU result) on the bus into Ra
            end

            //Execution: ANDI instruction
            andi3: begin
		  		MDRout <= 0;
			    IRin <= 0;
				
                Grb <= 1; //selecting the register Rb
                Rout <= 1; //outputting its value onto the bus
                Yin <= 1; //storing the bus value in the Y reg
            end

            andi4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                Cout <= 1; //outputting the constant
                AND <= 1; //calling the AND operation in the ALU
                Zin <= 1; //the ALU result is stored in the Z register
            end

            andi5: begin
                Cout <= 0;
                AND <= 0;
                Zin <= 0;

                Zlowout <= 1; //outputting the result
                Gra <= 1; //selected the destination register (Ra)
                Rin <= 1; //storing the value (ALU result) on the bus into Ra
            end

            //Execution: ORI instruction
            ori3: begin
				MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the register Rb
                Rout <= 1; //outputting its value onto the bus
                Yin <= 1; //storing the bus value in the Y reg
            end

            ori4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                Cout <= 1; //outputting the constant
                OR <= 1; //calling the OR operation in the ALU
                Zin <= 1; //the ALU result is stored in the Z register
            end

            ori5: begin
                Cout <= 0;
                OR <= 0;
                Zin <= 0;

                Zlowout <= 1; //outputting the result
                Gra <= 1; //selected the destination register (Ra)
                Rin <= 1; //storing the value (ALU result) on the bus into Ra
            end

            //Execution: DIV instruction
            div3: begin
				MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the register Rb
                Rout <= 1; //outputting its value onto the bus   
                Yin <= 1; //storing the bus value in the Y reg
            end

            div4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                Grc <= 1; //selecting the register Rc
                Rout <= 1; //outputting its value onto the bus
                DIV <= 1; //calling the DIV operation in the ALU
                ZHighIn <= 1;
                ZLowIn <= 1;
            end

            div5: begin
                Grc <= 0;
                Rout <= 0;
                DIV <= 0;
                ZHighIn <= 0;
                ZLowIn <= 0;
                
                Zhighout <= 1; //the division remainder is being output onto the bus 
                HIin <= 1; //storing this value into the HI reg
            end

            div6: begin
                Zhighout <= 0;
                HIin <= 0;

                Zlowout <= 1; //the division quotient is being output onto the bus
                LOin <= 1; //storing this value into the LO reg
            end

            //Execution: MUL instruction
            mul3: begin
			    MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the register Rb
                Rout <= 1; //outputting its value onto the bus
                Yin <= 1; //storing the bus value in the Y reg
            end

            mul4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                Grc <= 1; //selecting the register Rc
                Rout <= 1; //outputting its value onto the bus
                MUL <= 1; //calling the MUL operation in the ALU
                ZLowIn <= 1; 
                ZHighIn <= 1;
            end

            mul5: begin
                Grc <= 0;
                Rout <= 0;
                MUL <= 0;
                ZLowIn <= 0;
                ZHighIn <= 0;

                Zlowout <= 1; //outputting the result from Zlow
                Gra <= 1; //select destination register Ra
                Rin <= 1; //loading the result into Ra
            end

            //Execution: NEG instruction
            neg3: begin
				MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the register Rb
                Rout <= 1; //outputting its value onto the bus
                Yin <= 1; //storing the bus value in the Y reg
            end

            neg4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                NEG <= 1; //calling the NEG operation in the ALU
                Zin <= 1; //the ALU result is stored in the Z register
            end

            neg5: begin
                NEG <= 0;
                Zin <= 0;

                Zlowout <= 1; //outputting the result from Zlow
                Gra <= 1; //select the destination register Ra
                Rin <= 1; //loading the result into Ra
            end

            //Execution: NOT instruction
            not3: begin
				MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the register Rb
                Rout <= 1; //outputting its value onto the bus
                Yin <= 1; //storing the bus value in the Y reg
            end

            not4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                NOT <= 1; //calling the NOT operation in the ALU
                Zin <= 1; //the ALU result is stored in the Z register
            end

            not5: begin
                NOT <= 0;
                Zin <= 0;

                Zlowout <= 1; //outputting the result from Zlow
                Gra <= 1; //select the destination register Ra
                Rin <= 1; //loading the result into Ra
            end

            //The following instructions aren't needed: BRZR, BRNZ, Input/Output 

            //Execution: Branch instruction (brpl and brmi)
            br3: begin
				MDRout <= 0;
				IRin <= 0;
				
                Gra <= 1; //selecting the register Ra
                Rout <= 1; //outputting the value onto the bus
                CONin <= 1; //triggering the CON_FF evaluation
            end

            br4: begin
                Gra <= 0; 
                Rout <= 0;
                CONin <= 0;

                PCout <= 1; //outputing the PC value onto the bus
                Yin <= 1; //taking the value from the bus into Y
            end

            br5: begin
                PCout <= 0; 
                Yin <= 0;

                Cout <= 1; //outputing the constant value onto the bus
                ADD <= 1; //calling the ADD operation in the ALU
                Zin <= 1; //the ALU result is stored in the Z register
            end

            br6: begin
                Cout <= 0;
                ADD  <= 0;
                Zin  <= 0;

                if (CON_FF)
                    Zlowout <= 1; //branch taken
                else
                    IncPC <= 1; //branch not taken
            end

            br7: begin
                Zlowout <= 0;
                IncPC   <= 0;

                if (CON_FF)
                    PCin <= 1;
            end
            
            //Execution: JR instruction
            jr3: begin
				MDRout <= 0;
				IRin <= 0;
				
                Gra <= 1; //selecting the source register
                Rout <= 1; //outputting its value onto the bus
                PCin <= 1; //loading its value into the PC
            end

            //Execution: JAL instruction
            jal3: begin
				MDRout <= 0;
				IRin <= 0;
				
                PCout <= 1; //outputting the current PC 
                Grb <= 1; //selecting Rb for the return address
                Rin <= 1; //saving this return address at R8
            end

            jal4: begin
                PCout <= 0;
                Grb <= 0;
                Rin <= 0;

                Gra <= 1; //selecting Ra from the instruction
                Rout <= 1; //output the selected register's contents onto bus
                PCin <= 1; //loading the PC with the new subroutine address
            end

            //Execution: MFHI instruction
            mfhi3: begin
				MDRout <= 0;
				IRin <= 0;
				
                HIout <= 1; //placing the HI register value onto the bus
                Gra <= 1; //selecting the destination register 
                Rin <= 1; //loading the bus value into the destination reg
            end

            //Execution: MFLO instruction
            mflo3: begin
				MDRout <= 0;
				IRin <= 0;
				
                LOout <= 1; //outputting LO register onto the bus
                Gra <= 1; //selecting the destination register
                Rin <= 1; //writing the bus value into the destination reg
            end

            //Execution: LD instruction
            ld3: begin
			    MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the base register
                Rout <= 1; //putting the register Rb on bus
                Yin <= 1; //loading the value of Rb into Y register
            end

            ld4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                Cout <= 1; //outputting the constant
                ADD <= 1; //the ALU will add Y + C
                Zin <= 1; //storing the ADD result into Z
            end

            ld5: begin
                Cout <= 0;
                ADD <= 0;
                Zin <= 0;

                Zlowout <= 1; //outputting the lower 32 bits of address (result)
                MARin <= 1; //loading the MAR with resultling address
            end

            ld6: begin
                Zlowout <= 0;
                MARin <= 0;

                Read <= 1; //start the memory read cycle
                MDRin <= 1; //loading the value from RAM into MDR
            end

            ld7: begin
                Read <= 0;
                MDRin <= 0;

                MDRout <= 1; //outputting the MDR value onto the bus
                Gra <= 1; //selecting the destination register
                Rin <= 1; //storing memory value into the destination reg
            end

            //Execution: LDI instruction
            ldi3: begin
				MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the base register: Rb
                Rout <= 1; //outputting Rb's value onto the bus
                Yin <= 1; //store it's value into Y
            end

            ldi4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                Cout <= 1; //outputting the constant
                ADD <= 1; //perform the ADD operation on Y + C
                Zin <= 1; //storing the result in Z
            end

            ldi5: begin
                Cout <= 0;
                ADD <= 0;
                Zin <= 0;

                Zlowout <= 1; //output computed address
                MARin <= 1; //loading it into MAR
            end

            ldi6: begin
                Zlowout <= 0;
                MARin <= 0;

                Read <= 1; //triggering the read operation
                MDRin <= 1; //loading the value at that address from memory into MDR
            end

            ldi7: begin
                Read <= 0;
                MDRin <= 0;

                MDRout <= 1; //outputting the value of MDR
                Gra <= 1; //selecting the destination register
                Rin <= 1; //storeing the value on the bus into the destination reg
            end

            //Execution: ST instruction
            st3: begin
				MDRout <= 0;
				IRin <= 0;
				
                Grb <= 1; //selecting the base register (Rb)
                Rout <= 1; //outputting the base register's value onto the bus
                Yin <= 1; //storing the value in the Y reg
            end

            st4: begin
                Grb <= 0;
                Rout <= 0;
                Yin <= 0;

                Cout <= 1; //outputting the offset
                ADD <= 1; //using the ADD operation in the ALU to compute Y + C
                Zin <= 1; //storing this new computed address in Z
            end

            st5: begin
                Cout <= 0;
                ADD <= 0;
                Zin <= 0;

                Zlowout <= 1; //outputting the calculated address onto the bus
                MARin <= 1; //loading into MAR
            end

            st6: begin
                Zlowout <= 0;
                MARin <= 0;

                Gra <= 1; //selecting the source register
                Rout <= 1; //outputting its value to bus
                MDRin <= 1; //loading the value from the bus into MDR
            end

            st7: begin
                Gra <= 0;
                Rout <= 0;
                MDRin <= 0;

                Write <= 1; //writing the MDR value to RAM at computed address
            end

		 endcase
	end

endmodule
