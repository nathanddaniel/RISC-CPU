`timescale 1ns/10ps

module ControlUnit (
    output reg Gra, Grb, Grc, Rin, Rout, 
    Yin, Zin, PCout, IncPC, MARin, MDRin, Read, Write, Clear,
    ADD, AND_op, SHR, // Sample ALU operations
    input [31:0] IR,  // Instruction Register
    input Clock, Reset, Stop, Con_FF
);

// Define state parameters for FSM
parameter reset_state = 4'b0000, fetch0 = 4'b0001, fetch1 = 4'b0010, fetch2 = 4'b0011,
          add3 = 4'b0100, add4 = 4'b0101, and3 = 4'b0110, and4 = 4'b0111, shr3 = 4'b1000, shr4 = 4'b1001;

// Register to store current state
reg [3:0] present_state = reset_state;  

// FSM - State Transition Logic
always @(posedge Clock or posedge Reset)  
begin
    if (Reset) 
        present_state <= reset_state;
    else 
        case (present_state)
            reset_state: present_state <= fetch0;
            fetch0: present_state <= fetch1;
            fetch1: present_state <= fetch2;
            fetch2: 
                case (IR[31:27]) // Opcode decoding to determine execution states
                    5'b00011: present_state <= add3;  // ADD instruction
                    5'b00100: present_state <= and3;  // AND instruction
                    5'b00101: present_state <= shr3;  // SHR instruction
                    default: present_state <= reset_state; // Default case
                endcase
            add3: present_state <= add4;
            add4: present_state <= reset_state;
            and3: present_state <= and4;
            and4: present_state <= reset_state;
            shr3: present_state <= shr4;
            shr4: present_state <= reset_state;
        endcase
end

// FSM - Control Signal Assignments
always @(present_state)  
begin
    // Default de-assert all signals
    Gra <= 0; Grb <= 0; Grc <= 0; Rin <= 0; Rout <= 0; 
    Yin <= 0; Zin <= 0; PCout <= 0; IncPC <= 0; MARin <= 0; MDRin <= 0; 
    Read <= 0; Write <= 0; Clear <= 0;
    ADD <= 0; AND_op <= 0; SHR <= 0;

    case (present_state)
        // Reset state: initialize everything
        reset_state: begin
            Gra <= 0; Grb <= 0; Grc <= 0; Yin <= 0; 
            Rin <= 0; Rout <= 0; Zin <= 0;
        end

        // Fetch cycle
        fetch0: begin
            PCout <= 1;   // Put PC address on the bus
            MARin <= 1;   // Store it in MAR
            IncPC <= 1;   // Increment PC
            Zin <= 1;     // Store incremented PC in Z register
        end
        
        fetch1: begin
            Zlowout <= 1; // Put Zlow (incremented PC) on the bus
            PCin <= 1;    // Load incremented PC back into PC
            Read <= 1;    // Read from memory
            MDRin <= 1;   // Store fetched data in MDR
        end

        fetch2: begin
            MDRout <= 1; // Put MDR contents on the bus
            IRin <= 1;   // Load instruction into IR
        end

        // Execution: ADD instruction
        add3: begin
            Grb <= 1;  // Select register B
            Rout <= 1; // Output register B onto the bus
            Yin <= 1;  // Store in Y register
        end
        add4: begin
            Grc <= 1; // Select register C
            Rout <= 1; // Output register C onto the bus
            ADD <= 1;  // Perform addition
            Zin <= 1;  // Store result in Z register
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

        // Execution: SHR instruction (Shift Right Logical)
        shr3: begin
            Grb <= 1;  // Select register B
            Rout <= 1; // Output register B onto the bus
            SHR <= 1;  // Perform SHR operation
            Zin <= 1;  // Store result in Z register
        end
        shr4: begin
            Grc <= 1;  // Select register C
            Rout <= 1; // Output register C onto the bus
            Zin <= 1;  // Store shifted result in Z register
        end

    endcase
end

endmodule