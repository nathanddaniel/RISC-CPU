
module IR (
    input Clock,
    input Clear,
    input IRin,
    input [31:0] BusMuxOut,  // Instruction from the bus
    
    output reg [31:0] IR,    // Full instruction storage
    output reg [4:0] Opcode,
    output reg [3:0] Ra, Rb, Rc,
    output reg [18:0] C,     // Immediate constant for I-format
    output reg [3:0] C2,     // Condition field for B-Format (branching) (Fixed from 2 bits to 4 bits)
    output reg [22:0] Jaddr  // Jump address for a J-format instruction
);


	always @(posedge Clock) begin
        if (Clear)
            IR <= 32'b0;
        else if (IRin)
            IR <= BusMuxOut; // Load new instruction
    end
	
	
	always @(posedge Clock) begin
      Opcode = IR[31:27];

      //default values
      Ra = 4'b0000;
      Rb = 4'b0000;
      Rc = 4'b0000;
      C = 19'b0000000000000000000;
      C2 = 4'b0000;
      Jaddr = 23'b00000000000000000000000;
		
		case (Opcode)
				// I-Format Instructions: ld, ldi, st
				5'b00000, 5'b00001, 5'b00010: begin
					Ra = IR[26:23];
					Rb = IR[22:19];
					C = IR[18:0];
				end
		
            // **R-Format Instructions**: add, sub, and, or, shr, shra, shl, ror, rol
            5'b00011, 5'b00100, 5'b00101, 5'b00110, 5'b00111, 
            5'b01000, 5'b01001, 5'b01010, 5'b01011: begin
                Ra = IR[26:23];
                Rb = IR[22:19];
                Rc = IR[18:15];
            end
            
            // **I-Format Instructions**: addi, andi, ori
            5'b01100, 5'b01101, 5'b01110: begin
                Ra = IR[26:23];
                Rb = IR[22:19];
                C = IR[18:0];  
            end

            // **I-Format Instructions**: mul, div, neg, not 
            5'b01111, 5'b10000, 5'b10001, 5'b10010: begin
                Ra = IR[26:23];
                Rb = IR[22:19];
            end
            
            // **Branch Instructions (B-Format)**: brzr, brnz, brmi, brpl
            5'b10011: begin
                Ra =  IR[26:23];
                C2 = IR[22:19]; 
                C = IR[18:0];   
            end
            
            // **Jump Instructions (J-Format)**: jr, jal
            5'b10100, 5'b10101: begin
                Ra = IR[26:23];
                Jaddr = IR[22:0]; // Jump Address
            end
            
            // **Input/Output & MFHI/MFLO Instructions**: in, out, mfhi, mflo
            5'b10110, 5'b10111, 5'b11000, 5'b11001: begin
                Ra = IR[26:23];
            end
            
            // **Miscellaneous Instructions**: nop, halt
            // 5'b11010, 5'b11011: begin
            //     // No registers used
            // end
            
            default: begin
                // Do nothing; default values remain
            end
      endcase
	end
endmodule