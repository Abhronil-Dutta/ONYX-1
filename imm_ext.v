module imm_ext (
    input [7:0] imm_in,
    input [3:0] opcode,
    output reg [15:0] imm_out
);

    always @(*) begin
        case (opcode)
            4'b1001, // ADDI
            4'b1010, // SUBI
            4'b0101, // BR_ZERO
            4'b0110:  // BR_NOTZ
                imm_out = {{8{imm_in[7]}}, imm_in};

            default:
                imm_out = {8'b00000000, imm_in};
        endcase
    end

endmodule