
/*

This is the select_and_encode.v module. This file implements select and encoding logic for the Datapath.
It selects one of the register fields (Ra, Rb, or Rc) from the instruction placed in the IR and decodes
it into a one-hot control signal for register input or output. This file also implements sign extension
for C for branch instructions as well as immediate operations

*/


module select_and_encode (

    //control signals that will be set in each instruction testbench
	input Gra, Grb, Grc,          
	input Rin, Rout, BAout,     
	                            
    //register fields that were extracted from the IR module
	input [3:0] Ra, Rb, Rc,

    //the immediate constant from IR
	input [18:0] C,

    //outputs to control datapath operations
	output reg [15:0] RinSignals,     
	output reg [15:0] RoutSignals,    

	//the 32-bit sign-extended constant value
	output reg [31:0] C_sign_extended 
);

	//the module's internal register to hold selected index
	reg [3:0] select_reg;
	
	/* 
	This is the register selection logic. Depending on whether Gra, Grb, or Grc is high, 
	the logic is able to seelect its corresponding register field
	*/
	always @(*) begin
		if (Gra)
			select_reg = Ra; //use the Ra field
		else if (Grb)
			select_reg = Rb; //use the Rb field
		else if (Grc)
			select_reg = Rc; //use the Rc field
		else
			select_reg = 4'b0000; //defaulting situation
	end
	
	//decoder will converts 4-bit register index to 1-hot control signals
	//enables the register input or output based on the control signal
	always @(*) begin
		RinSignals = 16'b0;          
		RoutSignals = 16'b0;      
		
		if (Rin)
			RinSignals = (1 << select_reg);  
		else if (Rout || BAout)
			RoutSignals = (1 << select_reg);
	end
	
	//sign-extending the constant to 32 bits
	always @(*) begin
		C_sign_extended = {{13{C[18]}}, C};  
	end
	
endmodule
