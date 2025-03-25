
module select_and_encode (

	input Gra, Grb, Grc, Rin, Rout, BAout,		    //control signals
	input [3:0] Ra, Rb, Rc,							//register fields from IR
	input [18:0] C,									//immediate constant from IR
	output reg [15:0] RinSignals,					//one-hot encoded register write enable
	output reg [15:0] RoutSignals,				//one-hot encoded register read enable
	output reg [31:0] C_sign_extended			//sign extended constant

);

	reg [3:0] select_reg;
	
	//determining which register to select based on Gra, Grb, Grc
	always @(*) begin
		if (Gra)
			select_reg = Ra;
		else if (Grb)
			select_reg = Rb;
		else if (Grc)
			select_reg = Rc;
		else
			select_reg = 4'b0000;							//defaulting to R0 if theres no selection
	end
	
	//decode the selected 4-bit register address into a one-hot 16-bit input
	always @(*) begin
		RinSignals = 16'b0;
		RoutSignals = 16'b0;
		
		if (Rin)
			RinSignals = (1 << select_reg);
		if (Rout) begin
		
         if (BAout && (select_reg == 4'b0000)) 
             RoutSignals = 16'b0;  						// If BAout is asserted & Rb = R0, force Rout to zero
         else
             RoutSignals = (1 << select_reg);
      end
	end
	
	always @(*) begin
		C_sign_extended = {{13{C[18]}}, C};  // Correctly extends the MSB (C[18]) to all higher-order bits		
	end
	
endmodule