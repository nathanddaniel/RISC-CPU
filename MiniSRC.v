
module MiniSRC (

	input Clock, Reset

);

	wire [31:0] IR;
	wire CON_FF;
	
	//put in all the wires between the Control Unit and the DataPath
	
	ControlUnit CU (
		.IR(IR),
      .Clock(Clock),
      .Reset(Reset),
      .Stop(Stop),
      .CON_FF(CON_FF),
      .Interrupts(Interrupts),
      .Gra(Gra),
      .Grb(Grb),
      // all other outputs and inputs...
	);
	
	
	
	DataPath DP (
		.Clock(Clock),
      .Reset(Reset),
      .IR(IR),
      .CON_FF(CON_FF),
      .Gra(Gra),
      .Grb(Grb),
      // all other shared wires...	
	);
	
endmodule
