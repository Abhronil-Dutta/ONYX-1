module io_ctrl (
    input clk,
    input io_read,
    input io_write,
    input [7:0] port_addr,
    input [15:0] write_data,
    output reg [15:0] read_data
);

    reg [15:0] ports [3:0];

    always @(*) begin
        if (io_read) begin
            case (port_addr)
                8'h00: read_data = ports[0];
                8'h01: read_data = ports[1];
                8'h02: read_data = ports[2];
                8'h03: read_data = ports[3];
                default: read_data = 16'b0000000000000000;
            endcase
        end else begin
            read_data = 16'b0000000000000000;
        end
    end

    always @(posedge clk) begin
        if (io_write) begin
            case (port_addr)
                8'h00: ports[0] <= write_data;
                8'h01: ports[1] <= write_data;
                8'h02: ports[2] <= write_data;
                8'h03: ports[3] <= write_data;
                default: ;
            endcase
        end
    end

endmodule
