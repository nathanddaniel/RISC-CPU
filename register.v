module register (
    input clear, clock, enable, 
    input [31:0]BusMuxOut,
    output reg [31:0]BusMuxIn
);
reg [31:0]q;
always @ (clock)
        begin 
            if (clear) begin
                q <= {31{1'b0}};
            end
            else if (enable) begin
                BusMuxIn <= BusMuxOut;
					 q <= BusMuxIn;
            end
        end

endmodule