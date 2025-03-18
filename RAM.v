//not tested
module RAM (

	input read, write, clock,
	input [31:0] data,
	input [8:0] address,
	output reg [31:0] data_output
);

	//creating the 512 x 32-bit array in memory
	reg [31:0] ram [0:511];
	
	//Initialize RAM contents to zero
	initial begin
        integer i;
        for (i = 0; i < 512; i = i + 1) 
            ram[i] = 32'b0;
    end
	
	always @ (posedge clock) begin
	
		if (write) begin
		
			//if write signal is high, we will write data to that address
			ram[address] <= data;
		end
		
		else if (read) begin
			//if read signal is high we will read data from that address
			data_output <= ram[address];
		end
	end
	
endmodule