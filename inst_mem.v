module inst_mem (
    input [15:0] pc_addr,
    output reg [15:0] instruction
);

    reg [15:0] memory [255:0];     // Program memory, 256 for now

    always @(*) begin
        instruction = memory[pc_addr[7:0]];
    end

    initial begin
        $readmemh("program.hex", memory);    // Load program.hex into memory
    end

endmodule
