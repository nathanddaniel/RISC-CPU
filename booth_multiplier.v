module booth_multiplier (
    input signed [31:0] a, b,
    output [63:0] Z
);
    reg [2:0] cc[15:0];              
    reg [33:0] pp[15:0];             
    reg signed [63:0] spp[15:0];     
    reg signed [63:0] product;       

    integer i, j;

    wire signed [32:0] inv_a;
    assign inv_a = {~a[31], ~a} + 1;  

    always @(*) begin
        
        cc[0] = {b[1], b[0], 1'b0}; 
        for (j = 1; j < 16; j = j + 1) 
            cc[j] = {b[2*j+1], b[2*j], b[2*j-1]}; 
        
        for (j = 0; j < 16; j = j + 1) begin
            case (cc[j])
                3'b001, 3'b010: pp[j] = {a[31], a};       
                3'b011:         pp[j] = {a, 1'b0};        
                3'b100:         pp[j] = {inv_a[31:0], 1'b0}; 
                3'b101, 3'b110: pp[j] = inv_a;            
                default:        pp[j] = 34'b0;            
            endcase

            spp[j] = $signed(pp[j]);   
            spp[j] = spp[j] << (2 * j); 
        end

        product = spp[0];
        for (j = 1; j < 16; j = j + 1)
            product = product + spp[j];
    end

    assign Z = product;

endmodule
