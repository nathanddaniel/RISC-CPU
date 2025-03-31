
/*

This is the IR.v module. This file implements the Instruction Register for 
the Mini SRC datapath. It captures the 32-bit instruction from the bus and 
extracts relevant fields based on the instructions opcode (which is always 
the same bits in the instruction field).

*/

module IR (
    input Clock, 
    input Clear, 
    input IRin, //the enable signal for IR
    input [31:0] BusMuxOut, //instruction fetched from memory via the bus

    output reg [31:0] IR, //the full 32-bit instruction stored in IR
    output reg [4:0] Opcode, //the opcode field (bits 31–27)
    output reg [3:0] Ra, Rb, Rc, // register fields
    output reg [18:0] C, // immediate constant for I-format instructions
    output reg [3:0] C2, // condition field for B-format (e.g., brzr, brnz, etc.)
    output reg [22:0] Jaddr //the jump address for J-format instructions
);

    //capturing the instruction on the rising edge of the clock if IRin is high
	always @(posedge Clock) begin
        if (Clear)
            IR <= 32'b0;      
        else if (IRin)
            IR <= BusMuxOut; //loading the instruction from the bus into IR
    end
	
    //decoding instruction fields whenever the clock changes
	always @(Clock) begin
        //extracting the opcode (always the same bits: 31–27)
        Opcode = IR[31:27];

        //default field values
        Ra = 4'b0000;
        Rb = 4'b0000;
        Rc = 4'b0000;
        C  = 19'b0;
        C2 = 4'b0;
        Jaddr = 23'b0;

        //the instruction decoding logic
		case (Opcode)
            // I-Format Instructions: ld, ldi, st: 
            5'b00000, 5'b00001, 5'b00010: begin
                Ra = IR[26:23];
                Rb = IR[22:19];
                C  = IR[18:0];
            end
		
            // R-Format Instructions: add, sub, and, or, shr, shra, shl, ror, rol
            5'b00011, 5'b00100, 5'b00101, 5'b00110, 5'b00111, 
            5'b01000, 5'b01001, 5'b01010, 5'b01011: begin
                Ra = IR[26:23];
                Rb = IR[22:19];
                Rc = IR[18:15];  
            end
            
            // I-Format Instructions: addi, andi, ori
            5'b01100, 5'b01101, 5'b01110: begin
                Ra = IR[26:23];
                Rb = IR[22:19];
                C  = IR[18:0];
            end

            // I-Format Instructions: mul, div, neg, not
            5'b01111, 5'b10000, 5'b10001, 5'b10010: begin
                Ra = IR[26:23];
                Rb = IR[22:19];
            end
            
            // B-Format Instructions: brzr, brnz, brmi, brpl
            5'b10011: begin
                Ra = IR[26:23];      // Condition register
                C2 = IR[22:19];      // Branch condition selector
                C  = IR[18:0];       // Offset or branch target
            end
            
            // J-Format Instructions: jr, jal
            5'b10100, 5'b10101: begin
                Ra = IR[26:23];      // Return or base register
                Jaddr = IR[22:0];    // Jump address field
            end
            
            // in, out, mfhi, mflo
            5'b10110, 5'b10111, 5'b11000, 5'b11001: begin
                Ra = IR[26:23];      // Target or source register
            end

            // Misc Instructions: nop, halt
            // No decoding necessary
            // 5'b11010, 5'b11011

            default: begin
                // Invalid or unhandled opcode — keep defaults
            end
        endcase
	end
endmodule
