/*
This is the CON_FF.v module. This module implements the Condition Flip-Flop for the Mini SRC CPU.
It checks the condition of a register value (R[Ra]) on the bus and determines whether a conditional 
branch should be taken based on the C2 field from the instruction. If CONin is asserted, it evaluates 
the condition and sets the CON flag accordingly
*/

module CON_FF (
    input Clock,                 
    input Clear, 
    input CONin, //control signal that will be set in instrucition testbenches
    input [31:0] BusMuxOut, //the register value to check (usually R[Ra])
    input [3:0] C2, //condition selector field from instruction

    output reg CON //the output flag: 1 = branch taken, 0 = not taken
);

    //extracting only the lowest 2 bits of C2
    wire [1:0] C2_selected = C2[1:0];

    //evaluating condition on rising clock edge or clear
    always @(posedge Clock or posedge Clear) begin
        if (Clear)
            CON <= 0; //resetting CON flag
        else if (CONin) begin
            //evaluating the condition based on C2 field
            case (C2_selected)
                2'b00:  CON <= (BusMuxOut == 32'b0) ? 1 : 0; // brzr: Branch if zero
                2'b01:  CON <= (BusMuxOut != 32'b0) ? 1 : 0; // brnz: Branch if non-zero
                2'b10:  CON <= (~BusMuxOut[31] && (BusMuxOut != 0)) ? 1 : 0; // brpl: Branch if positive
                2'b11:  CON <= (BusMuxOut[31]) ? 1 : 0; // brmi: Branch if negative
                default: CON <= 0; //default case
            endcase
        end
    end
endmodule


