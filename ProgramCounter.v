
/*

This is the ProgramCounter.v module. This module implements the Program Counter for the 
Mini SRC CPU. It controls instruction sequencing by holding the address of the next 
instruction to fetch. The PC can either be directly loaded (through jumps or branching), 
incremented with normal execution, or it can be offset with sign-extended branch displacement

*/

module ProgramCounter (
    input clock,                  
    input clear, 
    input enable, //enables loading a new address
    input IncPC,  //increments PC by 1 (for normal execution flow)
    input CON,    // branch condition signal (1 = branch is taken)
    input [31:0] inputPC, //the address to load into PC 
    input [31:0] C_sign_extended, // sign-extended offset for branch instructions

    output reg [31:0] newPC //the current value of the Program Counter
);

    //the always block triggered on the rising edge of the clock
    always @(posedge clock) begin
        if (clear)
            newPC <= 32'b0; //reset PC to 0 when clear is high
        else if (enable)
            newPC <= inputPC; //loading external address into PC
        else if (CON)
            newPC <= newPC + C_sign_extended; //branch taken...add offset to current PC
        else if (IncPC)
            newPC <= newPC + 1; //incrementing PC for sequential execution
    end
endmodule
