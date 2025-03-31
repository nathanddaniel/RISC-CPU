/*

This is the BusEncoder32to5.v module. This file carries our the 32-to-5 priority encoder for the bus.
It takes the encodeded control signals and then outputs a 5-bit select signal to control which source
is being routed to the bus

*/

module BusEncoder32to5 (
    
    input [15:0] RoutSignals, //one-hot signals from general-purpose registers (R0-R15)
    input HIout, LOout, //output control for HI and LO special registers
    input Zhighout, Zlowout, //output control for Zhigh and Zlow registers
    input PCout, MDRout, //output control for PC and MDR registers 
    input InPortout, Cout, //output control for Input Port and constants
    input Yout, //output control for the Y register

    output reg [4:0] select //5-bit encoded selector output
);

    /* 
    this is the priority encoder, where we are checking for the first active 'out' 
    signal. Then once that's done, we assignt eh corresponding 5-bit value to 'select'
    */
    always @(*) begin
        casez (1'b1) 
            RoutSignals[0] : select = 5'd0; //corresponds to register R0
            RoutSignals[1] : select = 5'd1; //corresponds to register R1
            RoutSignals[2] : select = 5'd2; //corresponds to register R2
            RoutSignals[3] : select = 5'd3; //corresponds to register R3
            RoutSignals[4] : select = 5'd4; //corresponds to register R4
            RoutSignals[5] : select = 5'd5; //corresponds to register R5
            RoutSignals[6] : select = 5'd6; //corresponds to register R6
            RoutSignals[7] : select = 5'd7; //corresponds to register R7
            RoutSignals[8] : select = 5'd8; //corresponds to register R8
            RoutSignals[9] : select = 5'd9; //corresponds to register R9
            RoutSignals[10] : select = 5'd10; //corresponds to register R10
            RoutSignals[11] : select = 5'd11; //corresponds to register R11
            RoutSignals[12] : select = 5'd12; //corresponds to register R12
            RoutSignals[13] : select = 5'd13; //corresponds to register R13
            RoutSignals[14] : select = 5'd14; //corresponds to register R14
            RoutSignals[15] : select = 5'd15; //corresponds to register R15
            HIout : select = 5'd16; //corresponds to register HI
            LOout : select = 5'd17; //corresponds to register LO
            Yout : select = 5'd18; //corresponds to register Y
            Zhighout : select = 5'd19; //corresponds to register Zhigh
            Zlowout : select = 5'd20; //corresponds to register Zlow
            PCout : select = 5'd21; //Program Counter
            MDRout : select = 5'd22; //Memory Data Register
            InPortout : select = 5'd23; //Input Port
            Cout : select = 5'd24; //Constant (the sign-extended immediate)
            default : select = 5'b00000; //Default case
        endcase
	end
endmodule