module pc (
    input clk,
    input reset,
    input halt,
    input load_jump,
    input load_branch,

    input [15:0] jump_target,
    input [15:0] branch_offset,

    output reg [15:0] pc_out
);

    always @(posedge clk) begin
        if (reset) begin
            pc_out <= 16'b0000;
        end 
        else if (halt) begin
            pc_out <= pc_out;
        end 
        else if (load_jump) begin
            pc_out <= jump_target;
        end
        else if (load_branch) begin
            pc_out <= pc_out + branch_offset;
        end
        else begin
            pc_out <= pc_out + 16'b1;
        end
    end

endmodule