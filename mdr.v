
/*

This is the mdr.v module. This module implemented the MDR for the Mini SRC CPU. The MDR acts like
a temporary register between the CPU and memory. It can be loaded data from the RAM or from the bus.
It can also output data back to memory or to the bus as well.

*/

module mdr(
    input Clear, 
    input Clock,                  
    input MDRin, //enable signal for MDR
    input Read, //indicates the memory read operation

    input [31:0] BusMuxOut, //data coming in from the bus
    input [31:0] Mdatain, //data coming in from the RAM

    output wire [31:0] BusMuxIn, //output to bus (when MDRout is enabled externally)
    output wire [31:0] MDR_data_out //output to RAM (for memory write operations)
);

	//internal register to hold MDR data
    reg [31:0] q;  

    //loading MDR on the rising edge of the clock
    always @(posedge Clock) begin
        if (Clear)
            q <= 32'b0; //clearing the MDR contents
        else if (MDRin) begin
            if (Read)
                q <= Mdatain; //loading the data from RAM (read operation)
            else
                q <= BusMuxOut; //loading data from bus (write to memory)
        end
    end

    //the outputs
    assign BusMuxIn = q; //data to go onto the bus
    assign MDR_data_out = q; //data to send to RAM for writing

endmodule
