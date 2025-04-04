/* 

Testbench for verifying the full DataPath module in Phase 3. This module 
instantiates the DataPath, generates a clock signal, and triggers the 
control FSM by asserting the Run signal. 

*/

module DataPath_tb;

  //signal declarations
  reg clock, clear;
  reg Run, Interrupts;
  reg [31:0] InPortData;
  wire [31:0] OutPortData;

  //instantiate the datapath
  DataPath uut (
    .clock(clock),
    .clear(clear),
    .Run(Run),
    .Interrupts(Interrupts),
    .InPortData(InPortData),
    .OutPortData(OutPortData)
  );

  //clock generator (20ns clock period, 50MHz)
  initial begin
    clock = 0;
    forever #10 clock = ~clock; 
  end

  //test sequence
  initial begin
    // Reset the CPU
    clear = 1; Run = 0; Interrupts = 0;
    #25 clear = 0;

    Run = 1;  //start running the program

    #20000;   //allow some cycles to pass

    $finish;  //halting the simulation
  end

endmodule
