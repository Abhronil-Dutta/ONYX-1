module alu (
    input [15:0] dest_reg,              // Destination register
    input [15:0] src_reg,               // Source Register
    input [3:0] funt,                   // Funtion for ALU Funtions (Read Design.md)
    output reg [15:0] result,           // Result
    output reg zero_flag                
);

    always @(*) begin
        case (funt)
            4'b0000: result = dest_reg + src_reg;       // ADD
            4'b0001: result = dest_reg - src_reg;       // SUB
            4'b0010: result = dest_reg & src_reg;       // AND
            4'b0011: result = dest_reg | src_reg;       // OR
            4'b0100: result = dest_reg ^ src_reg;       // XOR
            4'b0101: result = src_reg;                  // MOV
            4'b0110: result = dest_reg << src_reg;      // SHL
            4'b0111: result = dest_reg >> src_reg;      // SHR
            4'b1000: result = dest_reg - src_reg;       // CMP
            4'b1001: result = ~dest_reg;                // NOT
            4'b1010: result = dest_reg + 16'd1;         // INC
            4'b1011: result = dest_reg - 16'd1;         // DEC

            default: result = 16'b0;
        endcase

        zero_flag = (result == 16'b0);
    end


endmodule
