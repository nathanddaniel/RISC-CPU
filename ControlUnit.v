`timescale 1ns/10ps

module ControlUnit (
    input [31:0] IR,              							
    input Clock, Reset, Stop, CON_FF, Interrupts,

    //control Signals to/from Datapath
    output reg Gra, Grb, Grc, Rin, Rout,
    output reg Run, Clear,
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
    output reg MARin, MDRin, OutPortin,
    output reg Cout, BAout,

    //output control signals
    output reg PCout, MDRout,
    output reg Zhighout, Zlowout,
    output reg HIout, LOout
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

	 //MUL Instruction
    mul3 = 8'b00001010, 
    mul4 = 8'b00001011, 
    mul5 = 8'b00001100, 
    mul6 = 8'b00001101,

	 //DIV Instruction
    div3 = 8'b00001110, 
    div4 = 8'b00001111, 
    div5 = 8'b00010000, 
    div6 = 8'b00010001,

	 //OR Instruction
    or3 = 8'b00010010, 
    or4 = 8'b00010011, 
    or5 = 8'b00010100,

	 //AND Instruction
    and3 = 8'b00010101, 
    and4 = 8'b00010110, 
    and5 = 8'b00010111,

	 //SHL Instruction
    shl3 = 8'b00011000, 
    shl4 = 8'b00011001, 
    shl5 = 8'b00011010,

	 //SHR Instruction
    shr3 = 8'b00011011, 
    shr4 = 8'b00011100, 
    shr5 = 8'b00011101,

	 //ROL Instruction
    rol3 = 8'b00011110, 
    rol4 = 8'b00011111, 
    rol5 = 8'b00100000,

	 //ROR Instruction
    ror3 = 8'b00100001, 
    ror4 = 8'b00100010, 
    ror5 = 8'b00100011,

	 //NEG Instruction
    neg3 = 8'b00100100, 
    neg4 = 8'b00100101, 
    neg5 = 8'b00100110,

	 //NOT Instruction
    not3 = 8'b00100111, 
    not4 = 8'b00101000, 
    not5 = 8'b00101001,

	 //Load (LD) Instruction
    ld3 = 8'b00101010, 
    ld4 = 8'b00101011, 
    ld5 = 8'b00101100, 
    ld6 = 8'b00101101, 
    ld7 = 8'b00101110,

	 //Load Immediate (LDI)
    ldi3 = 8'b00101111, 
    ldi4 = 8'b00110000, 
    ldi5 = 8'b00110001,

	 //Store (ST) Instruction
    st3 = 8'b00110010, 
    st4 = 8'b00110011, 
    st5 = 8'b00110100, 
    st6 = 8'b00110101, 
    st7 = 8'b00110110,

	 //ADDI Instruction
    addi3 = 8'b00110111, 
    addi4 = 8'b00111000, 
    addi5 = 8'b00111001,

	 //ANDI Instruction
    andi3 = 8'b00111010, 
    andi4 = 8'b00111011, 
    andi5 = 8'b00111100,

    //ORI Instruction
    ori3 = 8'b00111101, 
    ori4 = 8'b00111110, 
    ori5 = 8'b00111111,

	 //Branch Instructions (e.g., BRZR, BRNZ, etc.)
    br3 = 8'b01000000, 
    br4 = 8'b01000001, 
    br5 = 8'b01000010, 
    br6 = 8'b01000011, 
    br7 = 8'b01000100,  

	 //Jump Instructions (JR, JAR)
    jr3 = 8'b01000101, 
    jal3 = 8'b01000110, 
    jal4 = 8'b01000111,

	 //Move From HI/LO
    mfhi3 = 8'b01001000, 
    mflo3 = 8'b01001001,

	 //Input and Output Instructions
    in3 = 8'b01001010, 
    out3 = 8'b01001011,

	 //special Instructions
    nop3 = 8'b01001100, 
    halt3 = 8'b01001101;

	// Register to store current state
	reg [3:0] present_state = reset_state;  

	// FSM - State Transition Logic
	always @(posedge Clock or posedge Reset)  
	begin
		 if (Reset) 
			  present_state <= reset_state;
		 else 
			  
			  case (present_state)
					reset_state	: present_state <= fetch0;
					fetch0		: present_state <= fetch1;
					fetch1		: present_state <= fetch2;
					fetch2		: begin
					
							 case (IR[31:27])
								  // ALU and Operation Instructions
								  5'b00011: present_state <= add3;     // ADD
								  5'b00100: present_state <= sub3;     // SUB
								  5'b00101: present_state <= and3;     // AND
								  5'b00110: present_state <= or3;      // OR
								  5'b00111: present_state <= ror3;     // ROR
								  5'b01000: present_state <= rol3;     // ROL
								  5'b01001: present_state <= shr3;     // SHR
								  5'b01010: present_state <= shra3;    // SHRA
								  
								  5'b01011: present_state <= shl3;     // SHL
								  5'b01100: present_state <= addi3;    // ADDI
								  5'b01101: present_state <= andi3;    // ANDI
								  5'b01110: present_state <= ori3;     // ORI
								  5'b01111: present_state <= div3;     // DIV
								  5'b10000: present_state <= mul3;     // MUL
								  5'b10001: present_state <= neg3;     // NEG
								  5'b10010: present_state <= not3;     // NOT

								  // Branch and Jump Instructions
								  5'b10011: present_state <= br3;      // BRZR / BRNZ / BRMI / BRPL (use sub-opcode bits later)
								  5'b10100: present_state <= jal3;     // JAR
								  5'b10101: present_state <= jr3;      // JR

								  // I/O Instructions
								  5'b10110: present_state <= in3;      // IN
								  5'b10111: present_state <= out3;     // OUT

								  // Move from HI/LO
								  5'b11000: present_state <= mflo3;    // MFLO
								  5'b11001: present_state <= mfhi3;    // MFHI

								  // Special Instructions
								  5'b11010: present_state <= nop3;     // NOP
								  5'b11011: present_state <= halt3;    // HALT

								  // Load/Store Instructions
								  5'b00000: present_state <= ld3;      // LD
								  5'b00001: present_state <= ldi3;     // LDI
								  5'b00010: present_state <= st3;      // ST

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
					
					//mul instruction
					mul3: present_state <= mul4;
					mul4: present_state <= mul5;
					mul5: present_state <= mul6;
					mul6: present_state <= reset_state;
					
					//div instruction
					div3: present_state <= div4;
					div4: present_state <= div5;
					div5: present_state <= div6;
					div6: present_state <= reset_state;
					
					//or instruction
					or3: present_state <= or4;
					or4: present_state <= or5;
					or5: present_state <= reset_state;
					
					//and instruction
					and3: present_state <= and4;
					and4: present_state <= and5;
					and5: present_state <= reset_state;
					
					//shl instruction
					shl3: present_state <= shl4;
					shl4: present_state <= shl5;
					shl5: present_state <= reset_state;
					
					//shr instruction
					shr3: present_state <= shr4;
					shr4: present_state <= shr5;
					shr5: present_state <= reset_state;
					
					//rol instruction
					rol3: present_state <= rol4;
					rol4: present_state <= rol5;
					rol5: present_state <= reset_state;
					
					//ror instruction
					ror3: present_state <= ror4;
					ror4: present_state <= ror5;
					ror5: present_state <= reset_state;
					
					//neg instruction
					neg3: present_state <= neg4;
					neg4: present_state <= neg5;
					neg5: present_state <= reset_state;
					
					//not instruction
					not3: present_state <= not4;
					not4: present_state <= not5;
					not5: present_state <= reset_state;
					
					//ld instruction
					ld3: present_state <= ld4;
					ld4: present_state <= ld5;
					ld5: present_state <= ld6;
					ld6: present_state <= ld7;
					ld7: present_state <= reset_state;
					
					//ldi instruction
					ldi3: present_state <= ldi4;
					ldi4: present_state <= ldi5;
					ldi5: present_state <= reset_state;
					
					//st instruction
					st3: present_state <= st4;
					st4: present_state <= st5;
					st5: present_state <= st6;
					st6: present_state <= st7;
					st7: present_state <= reset_state;
					
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

					// MFHI / MFLO
					mfhi3: present_state <= reset_state;
					mflo3: present_state <= reset_state;

					// IN / OUT
					in3: present_state <= reset_state;
					out3: present_state <= reset_state;

					// NOP
					nop3: present_state <= reset_state;

					// HALT
					halt3: present_state <= halt3; // Loop forever in HALT

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
		 Run <= 0; 			Clear <= 0;		 ADD <= 0; 			SUB <= 0; 			AND <= 0; 
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
					
				PCin <= 1;        //setting PC to 0
				Clear <= 1;       //clearing internal register states, if needed
				Run <= 1;         //enabling operation		  
			end

			// Fetch cycle
			fetch0: begin
				PCout <= 1;   //outputting the PC onto the bus
				MARin <= 1;   //loading the bus value into MAR
				IncPC <= 1;   //incrementing the PC internally
			end
			  
			fetch1: begin
				Read <= 1;    // Read from memory
				MDRin <= 1;   // Store fetched data in MDR
			end

			fetch2: begin
				MDRout <= 1; // Put MDR contents on the bus
				IRin <= 1;   // Load instruction into IR
			end

            //Executing the ADD instruction
			add3: begin
				Grb <= 1;           // selecting register B
				Rout <= 1;          // outputting register B onto the bus
				Yin <= 1;           // storing in Y register
			end
			
            add4: begin
				Grc <= 1;           // selecting register C
				Rout <= 1;          // outputting register C onto the bus
				ADD <= 1;           // performing addition
				Zin <= 1;           // storing result in Z register
			end

            add5: begin
                Zlowout <= 1;
                Gra <= 1;
                Rin <= 1;
            end

            // Execution: SUB instruction
            sub3: begin
                Grb <= 1;
                Rout <= 1;
                Yin <= 1;
            end

            sub4: begin
                Grc <= 1;     // Select Rc
                Rout <= 1;     // Put Rc on bus
                SUB <= 1;     // Perform subtraction in ALU
                Zin <= 1;     // Store result into Z
            end

            sub5: begin
                Zlowout <= 1;   // Output from Zlow
                Gra <= 1;   // Select Ra (destination)
                Rin <= 1;   // Store result in Ra
            end
            
			// Execution: AND instruction
			and3: begin
				Grb <= 1;  // Select register B
				Rout <= 1; // Output register B onto the bus
				Yin <= 1;  // Store in Y register
			end
			
            and4: begin
				Grc <= 1;  // Select register C
				Rout <= 1; // Output register C onto the bus
				AND_op <= 1; // Perform AND operation
				Zin <= 1;   // Store result in Z register
			end

            and5: begin
                Zlowout <= 1;   // Output result from Zlow
                Gra <= 1;   // Select destination register Ra
                Rin <= 1;   // Store result into Ra
            end

            //Executing the OR instruction
            or3: begin
                Grb <= 1;    // Select Rb (R1)
                Rout <= 1;    
                Yin <= 1;    // Store R1 into Y
            end

            or4: begin
                Grc <= 1;    // Select Rc (R0)
                Rout <= 1;
                OR <= 1;    // Trigger OR operation in ALU
                Zin <= 1;    // Store result in Z
            end

            or5: begin
                Zlowout <= 1; // Output from Zlow
                Gra <= 1; // Select Ra (R5)
                Rin <= 1; // Store result into R5
            end   

            //Execution: ROR instruction
            ror3: begin
                Grb <= 1;    // Select Rb (R0)
                Rout <= 1;    
                Yin <= 1;    // Store into Y
            end

            ror4: begin
                Grc <= 1;    // Select Rc (R1)
                Rout <= 1;
                ROR <= 1;    // Trigger Rotate Right in ALU
                Zin <= 1;    // Store result in Z register
            end

            ror5: begin
                Zlowout <= 1; // Output from Zlow
                Gra <= 1; // Select destination Ra (R2)
                Rin <= 1; // Write into Ra
            end

            //Execution: ROL instruction 
            rol3: begin
                Grb <= 1;     // Select Rb (R0)
                Rout <= 1;     
                Yin <= 1;     // Store R0 into Y register
            end

            rol4: begin
                Grc <= 1;     // Select Rc (R1)
                Rout <= 1;
                ROL <= 1;     // Enable ROL control line in ALU
                Zin <= 1;     // Store result from ALU into Z
            end

            rol5: begin
                Zlowout <= 1;  // Output lower 32 bits from Z
                Gra <= 1;  // Select Ra (R3)
                Rin <= 1;  // Load result into R3
            end

            //Execution: SHR instruction
            shr3: begin
                Grb <= 1;     // Select Rb (R3)
                Rout <= 1;
                Yin <= 1;     // Load R3 into Y register
            end

            shr4: begin
                Grc <= 1;     // Select Rc (R1) — shift amount
                Rout <= 1;
                SHR <= 1;     // Trigger SHR in ALU
                Zin <= 1;     // Store result in Z
            end

            shr5: begin
                Zlowout <= 1;  // Output lower half of Z
                Gra <= 1;  // Select Ra (R3)
                Rin <= 1;  // Store result into R3
            end

            //Execution: SHRA instruction
            shra3: begin
                Grb <= 1;     // Select Rb (R4)
                Rout <= 1;
                Yin <= 1;     // Store value in Y
            end

            shra4: begin
                Grc <= 1;     // Select Rc (R1)
                Rout <= 1;
                SHRA <= 1;     // Activate Arithmetic Shift Right
                Zin <= 1;     // Store ALU output in Z
            end
            
            shra5: begin
                Zlowout <= 1;  // Output result from Zlow
                Gra <= 1;  // Select Ra (R2)
                Rin <= 1;  // Store into destination register
            end

            //Execution: SHL instruction
            shl3: begin
                Grb <= 1;     // Select Rb (R3)
                Rout <= 1;
                Yin <= 1;     // Store into Y
            end

            shl4: begin
                Grc <= 1;     // Select Rc (R1)
                Rout <= 1;
                SHL <= 1;     // Trigger shift-left logic in ALU
                Zin <= 1;     // Store result in Z register
            end

            shl5: begin
                Zlowout <= 1;  // Output Zlow to bus
                Gra <= 1;  // Select Ra (R2)
                Rin <= 1;  // Load result into destination
            end

            //Execution: ADDI instruction
            addi3: begin
                Grb <= 1;     // Select R4
                Rout <= 1;
                Yin <= 1;     // Load R4 into Y register
            end

            //Execution: ANDI instruction
            addi4: begin
                Cout <= 1;     // Output constant C (from sign-extended immediate)
                ADD <= 1;     // Trigger addition operation
                Zin <= 1;     // Store result in Z
            end

            addi5: begin
                Zlowout <= 1;  // Output Zlow to the bus
                Gra <= 1;  // Select Ra (R4)
                Rin <= 1;  // Store result into R4
            end

            //Execution: ORI instruction
            ori3: begin
                Grb <= 1;     // Select R2
                Rout <= 1;
                Yin <= 1;     // Store R2 into Y
            end

            ori4: begin
                Cout <= 1;     // Output sign-extended constant
                OR <= 1;     // Trigger bitwise OR in ALU
                Zin <= 1;     // Store result in Z register
            end

            ori5: begin
                Zlowout <= 1;  // Output result from Zlow
                Gra <= 1;  // Select Ra (R4)
                Rin <= 1;  // Load result into R4
            end

            //Execution: DIV instruction
            div3: begin
                Grb <= 1;    // Rb = dividend (R6)
                Rout <= 1;    
                Yin <= 1;    // Store into Y
            end

            div4: begin
                Grc <= 1;    // Rc = divisor (R5)
                Rout <= 1;
                DIV <= 1;    // Trigger division
                Zin <= 1;    // Store result in Z (Z = {rem, quot})
            end

            div5: begin
                Zhighout <= 1; // Z[63:32] = remainder
                HIin <= 1; // Store in HI
            end

            div6: begin
                Zlowout <= 1;  // Z[31:0] = quotient
                LOin <= 1;  // Store in LO
            end

            //Execution: MUL instruction
            mul3: begin
                Grb   <= 1;     // Select source Rb
                Rout  <= 1;     // Output Rb
                Yin   <= 1;     // Store into Y
            end

            mul4: begin
                Grc <= 1;     // You may still need to select Rc, even if it's zero
                Rout <= 1;     // Output Rc (value = 0)
                MUL <= 1;     // Trigger ALU multiplication
                ZLowIn <= 1;   // Store result into Zlow
                ZHighIn <= 1;   // You must still capture Zhigh (to clear it), but won't use it
            end

            mul5: begin
                Zlowout <= 1;   // Output result from Zlow
                Gra <= 1;   // Select destination register Ra
                Rin <= 1;   // Load result into Ra
            end

            //Execution: NEG instruction
            neg3: begin
                Grb  <= 1;     // Select source register R4
                Rout <= 1;
                Yin  <= 1;     // Load into Y register
            end

            neg4: begin
                NEG  <= 1;     // Trigger NEG operation in ALU
                Zin  <= 1;     // Store result in Z
            end

            neg5: begin
                Zlowout <= 1;  // Output result from Zlow
                Gra     <= 1;  // Select destination register (R4)
                Rin     <= 1;  // Store result into R4
            end

            //Execution: NOT instruction
            not3: begin
                Grb  <= 1;     // Select R4 (source)
                Rout <= 1;
                Yin  <= 1;     // Store R4 into Y register
            end

            not4: begin
                NOT  <= 1;     // Enable NOT operation in ALU
                Zin  <= 1;     // Store result into Z
            end

            not5: begin
                Zlowout <= 1;  // Output from Zlow register
                Gra     <= 1;  // Select Ra (R4)
                Rin     <= 1;  // Load result into R4
            end

            //Execution: BRZR instruction (not needed)
            //Execution: BRNZ instruction (not needed)
            //Execution: INPUT/OUTPUT instruction (not needed)

            //Execution: BRMI instruction
            br3: begin
                Gra    <= 1;    // Select Ra (R3)
                Rout   <= 1;    // Output R3 to bus
                CONin  <= 1;    // Trigger CON_FF evaluation
            end

            br4: begin
                // No control signals; transition state only
            end

            br5: begin
                PCin    <= 1;    // Enable PC update
                Cout    <= 1;    // Output constant offset
            end

            br6: begin
                // Can be a pause state to allow PC update
            end

            br7: begin
                // Transition to fetch0 handled in FSM transition logic
            end
            
            //Execution: BRPL instruction
            br3: begin
                Gra    <= 1;     // Select R4 (Ra)
                Rout   <= 1;     // Output R4 onto bus
                CONin  <= 1;     // Trigger evaluation in CON_FF
            end

            br4: begin
                // No control signals needed
            end

            br5: begin
                Cout  <= 1;     // Output sign-extended constant
                PCin  <= 1;     // Update Program Counter
            end

            br6: begin
                // Idle state for safe update
            end

            br7: begin
                // Transition to fetch0 handled in FSM controller
            end

		 endcase
	end

endmodule