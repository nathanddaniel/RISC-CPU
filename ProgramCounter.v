module ProgramCounter (
	input enable, clock, IncPC,
	input [31:0] inputPC,
	output reg[31:0] newPC
);
	
always @ (posedge clock)
	begin
		if(IncPC == 1 && enable ==1)
			newPC <= newPC + 1;
		else if (enable == 1)
			newPC <= inputPC;
	end
				
endmodule