module alu (
    input [15:0] dest_reg,
    input [15:0] src_reg,
    input [3:0] funt,
    output reg [15:0] result,
    output reg zero_flag
);

    always @(*) begin
        case (funt)
            4'b0000: result = dest_reg + src_reg;
            4'b0001: result = dest_reg - src_reg;
            4'b0010: result = dest_reg & src_reg;
            4'b0011: result = dest_reg | src_reg;
            4'b0100: result = dest_reg ^ src_reg;
            4'b0101: result = src_reg;
            4'b0110: result = dest_reg << src_reg;
            4'b0111: result = dest_reg >> src_reg;
            4'b1000: result = dest_reg - src_reg;
            4'b1001: result = ~dest_reg;
            4'b1010: result = dest_reg + 16'd1;
            4'b1011: result = dest_reg - 16'd1;

            default: result = 16'b0;
        endcase

        zero_flag = (result == 16'b0);
    end


endmodule
