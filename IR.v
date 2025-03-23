
module IR (
    input Clock,
    input Clear,
    input IRin,
    input [31:0] BusMuxOut,  		//instruction from the bus
    output reg [31:0] IR, 			//full instruction storage
    output wire [4:0] Opcode,
    output wire [3:0] Ra, Rb, Rc,
    output wire [14:0] C
);


	always @(posedge Clock) 
	begin
        if (Clear)
            IR <= 32'b0;
        else if (IRin)
            IR <= BusMuxOut; // Load new instruction
   end
	
	assign Opcode = IR[31:27];
   assign Ra = IR[26:23];
   assign Rb = IR[22:19];
   assign Rc = IR[18:15];
   assign C = IR[14:0];
	
endmodule