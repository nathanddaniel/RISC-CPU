
module CON_FF (
    input Clock, 
    input Clear, 
    input CONin,            // Control signal from Control Unit
    input [31:0] BusMuxOut, // The value of R[Ra] on the bus
    input [3:0] C2,         // C2 field from IR 
    output reg CON          // The output flag (1 = branch taken, 0 = not taken)
);

	 wire [1:0] C2_selected = C2[1:0];
	 
    always @(posedge Clock or posedge Clear) begin
        if (Clear)
            CON <= 0;
        else if (CONin) begin
            case (C2)
                2'b00:  CON <= (BusMuxOut == 32'b0) ? 1 : 0;  						// brzr (Branch if Zero)
                2'b01:  CON <= (BusMuxOut != 32'b0) ? 1 : 0;  						// brnz (Branch if Non-Zero)
                2'b10:  CON <= (~BusMuxOut[31] & (BusMuxOut != 0)) ? 1 : 0;  	// brpl (Branch if Positive)
                2'b11:  CON <= (BusMuxOut[31]) ? 1 : 0;  							// brmi (Branch if Negative)
                default: CON <= 0;  														// Default case (shouldn't happen)
            endcase
        end
    end

endmodule
