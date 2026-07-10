module reg_file (
    input clk,
    input we,

    input [3:0] read_addr_1,
    input [3:0] read_addr_2,
    input [3:0] write_addr,
    input [15:0] write_data,

    output reg [15:0] read_data_1,
    output reg [15:0] read_data_2
);

    reg [15:0] registers [15:0];

    always @(*) begin
        if (read_addr_1 == 4'b0000) begin
            read_data_1 = 16'b0000000000000000;
        end else begin
            read_data_1 = registers[read_addr_1];
        end

        if (read_addr_2 == 4'b0000) begin
            read_data_2 = 16'b0000000000000000;
        end else begin
            read_data_2 = registers[read_addr_2];
        end

    end

    always @(posedge clk) begin
        if (we == 1'b1 && write_addr != 4'b0000) begin
            registers[write_addr] <= write_data;
        end
    end


endmodule
