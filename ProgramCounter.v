module ProgramCounter (
    input clock, 
    input clear, 
    input enable,
    input IncPC,
    input CON,               // NEW: Branch condition input
    input [31:0] inputPC, 
    input [31:0] C_sign_extended, // NEW: Sign-extended branch offset
    output reg [31:0] newPC
);

    // Set PC to zero on power-up

    always @(posedge clock) begin
        if (clear) 
            newPC <= 32'b0;
        else if (enable)
	    newPC <= inputPC;
	else if (CON)  
            newPC <= newPC + C_sign_extended;
        else if (IncPC)
            newPC <= newPC + 1;       
    end
endmodule
