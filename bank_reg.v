module bank_reg (
    input clk,
    input reset,
    input bank_we,
    input [7:0] bank_in,
    output reg [7:0] bank_out
);

    always @(posedge clk) begin
        if (reset) begin
            bank_out <= 8'b00000000;
        end else if (bank_we) begin
            bank_out <= bank_in;
        end
    end

endmodule
