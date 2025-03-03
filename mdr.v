module mdr(
    input clear, clock, enable, read,
    input [31:0] BusMuxOut,
    input [31:0] Mdatain, 
    output wire [31:0] BusMuxIn
); 

reg [31:0]q;
always @ (posedge clock) begin
         if (clear) 
              q <= 32'b0;
         else if (enable) begin
              case (read)
                    1'b1: q <= Mdatain;   // reading from memory
                    1'b0: q <= BusMuxOut; // reading from bus
              endcase
         end
    end
    assign BusMuxIn = q[31:0];
endmodule