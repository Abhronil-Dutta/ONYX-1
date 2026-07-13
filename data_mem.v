module data_mem (
    input clk,
    input mem_we,
    input [15:0] addr,

    input [15:0] write_data,
    output reg [15:0] read_data
);

    reg [15:0] data_memory [65535:0];

    always @(*) begin
        read_data = data_memory[addr];
    end

    always @(posedge clk) begin
        if (mem_we) begin
            data_memory[addr] <= write_data;
        end
    end

endmodule
