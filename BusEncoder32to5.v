
module BusEncoder32to5 (
    input [15:0] RoutSignals,
    input HIout, LOout, Zhighout, Zlowout, PCout, MDRout, InPortout, Cout, Yout,
    output reg [4:0] select
);

    always @(*) begin
    casez (1'b1) 
        RoutSignals[0]  : select = 5'd0;    // R0
        RoutSignals[1]  : select = 5'd1;    // R1
        RoutSignals[2]  : select = 5'd2;    // R2
        RoutSignals[3]  : select = 5'd3;    // R3
        RoutSignals[4]  : select = 5'd4;    // R4
        RoutSignals[5]  : select = 5'd5;    // R5
        RoutSignals[6]  : select = 5'd6;    // R6
        RoutSignals[7]  : select = 5'd7;    // R7
        RoutSignals[8]  : select = 5'd8;    // R8
        RoutSignals[9]  : select = 5'd9;    // R9
        RoutSignals[10] : select = 5'd10;   // R10
        RoutSignals[11] : select = 5'd11;   // R11
        RoutSignals[12] : select = 5'd12;   // R12
        RoutSignals[13] : select = 5'd13;   // R13
        RoutSignals[14] : select = 5'd14;   // R14
        RoutSignals[15] : select = 5'd15;   // R15
        HIout           : select = 5'd16;   // HI
        LOout           : select = 5'd17;   // LO
        Yout            : select = 5'd18;   // Y
        Zhighout        : select = 5'd19;   // Zhigh
        Zlowout         : select = 5'd20;   // Zlow
        PCout           : select = 5'd21;   // PC
        MDRout          : select = 5'd22;   // MDR
        InPortout       : select = 5'd23;   // InPort
        Cout            : select = 5'd24;   // CSignOut
        default         : select = 5'b00000; // Default case
    endcase
	end
endmodule