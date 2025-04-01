
module DataPath_tb;

  reg clock, clear;
  reg Run, Interrupts;
  reg [31:0] InPortData;
  wire [31:0] OutPortData;

  // Instantiate the datapath
  DataPath uut (
    .clock(clock),
    .clear(clear),
    .Run(Run),
    .Interrupts(Interrupts),
    .InPortData(InPortData),
    .OutPortData(OutPortData)
  );

  initial begin
    clock = 0;
    forever #10 clock = ~clock;  // 20ns clock period
  end

  initial begin
    // Reset the CPU
    clear = 1; Run = 0; Interrupts = 0;
    #25 clear = 0;

    // Start running the program
    Run = 1;

    // Allow some cycles to pass
    #1000;

    // Halt the simulation
    $finish;
  end

endmodule
