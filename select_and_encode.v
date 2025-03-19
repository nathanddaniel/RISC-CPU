module select_and_encode(
   input  [31:0] IR,
   input         Gra, Grb, Grc,		// Determines which register
   input         Rin, Rout,			// Determines if in or out signal
   input         BAout,          	// For output if its a base address
   output [15:0] Rin_decoded,    	// R0in–R15in
   output [15:0] Rout_decoded,   	// R0out–R15out
   output [31:0] C_sign_extended 	// Sign-extended constant from IR
);

	 
   // IR[26:23] = RA
   // IR[22:19] = RB
   // IR[18:15] = RC
	wire [3:0] RA = IR[26:23];
   wire [3:0] RB = IR[22:19];
	wire [3:0] RC = IR[18:15];

   // Only one of Gra, Grb, Grc is asserted for a given instruction
   wire [3:0] decode_in = ({4{Gra}} & RA) | ({4{Grb}} & RB) | ({4{Grc}} & RC);

	// Decoder for One-hot encoding (selecting the reg)
   reg [15:0] decoder_out;
   always @(*) begin
		decoder_out = 16'b0;
			case (decode_in)
				4'b0000: decoder_out[0]  = 1'b1;
            4'b0001: decoder_out[1]  = 1'b1;
            4'b0010: decoder_out[2]  = 1'b1;
            4'b0011: decoder_out[3]  = 1'b1;
            4'b0100: decoder_out[4]  = 1'b1;
            4'b0101: decoder_out[5]  = 1'b1;
            4'b0110: decoder_out[6]  = 1'b1;
            4'b0111: decoder_out[7]  = 1'b1;
            4'b1000: decoder_out[8]  = 1'b1;
            4'b1001: decoder_out[9]  = 1'b1;
            4'b1010: decoder_out[10] = 1'b1;
            4'b1011: decoder_out[11] = 1'b1;
            4'b1100: decoder_out[12] = 1'b1;
            4'b1101: decoder_out[13] = 1'b1;
            4'b1110: decoder_out[14] = 1'b1;
            4'b1111: decoder_out[15] = 1'b1;
            default: decoder_out      = 16'b0;
			endcase
		end

	// For the “in” signals, we just AND each decoded line with Rin.
   assign Rin_decoded = decoder_out & {16{Rin}};

   wire [15:0] rout_masked = decoder_out & {16{Rout}};
	assign Rout_decoded[15:1]  = rout_masked[15:1];  // R1..R15
   assign Rout_decoded[0]     = decoder_out[0] & (Rout | BAout); // Check if this needs to be seperate (May not be needed)
    
	// Sign-Bit extender (Built-in) 
	// Seperate function also exists	(not used for simplicity)
   assign C_sign_extended = {{13{IR[18]}}, IR[18:0]};

endmodule