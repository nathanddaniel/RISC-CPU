//NOT TESTED
module load (
    input clock, clear,
    input MARin, MDRin, MDRout, Read,
    input [8:0] address,  // Memory address
    input [31:0] BusMuxOut, // Value on BusMuxOut
    output reg [31:0] BusMuxInMDR // Output from MDR to Bus
);

    reg [2:0] state;

    parameter T0 = 3'b000, T1 = 3'b001, T2 = 3'b010, T3 = 3'b011, T4 = 3'b100;

    always @ (posedge clock or posedge clear) begin
        if (clear)
            state <= T0;
        else begin 
            case (state)
                T0: state <= T1;
                T1: state <= T2;
                T2: state <= T3;
                T3: state <= T4;
                T4: state <= T0;
            endcase
        end
    end 

    always @(state) begin
		case (state)
			T0: begin
				MARin = 1;
				BusMuxOut = address; //load the address into the MAR
			end
			T1: begin
				Read = 1; //starting the memory read
			end

			T2: begin
				MDRin = 1; //storing the RAM output into the MDR
			end

			T3: begin
				MDRout = 1; //placing the MDR data onto the bus
			end

            T4: begin
                BusMuxInMDR = BusMuxOut;
            end
		endcase
	end

endmodule