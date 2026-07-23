module onyx1_top (
    input clk,
    input reset
);

    // Internal Wires & Registers

    // Program Counter & Instruction
    reg  [15:0] pc;
    wire [15:0] instruction;

    // Control Unit Signals
    wire        reg_we;
    wire        mem_we;
    wire        bank_we;
    wire [3:0]  alu_funt;
    wire        alu_src_mux;
    wire [1:0]  reg_write_mux;
    wire        pc_jump;
    wire        pc_branch;
    wire        pc_return;
    wire        halt;
    wire        io_read;
    wire        io_write;
    wire        stack_push;
    wire        stack_pop;

    // Register File (R0-R15)
    reg  [15:0] registers [15:0];
    wire [3:0]  dest_addr = instruction[11:8];
    wire [3:0]  src_addr  = instruction[7:4];
    
    // Register outputs (R0 is hardwired to 0)
    wire [15:0] reg_dest_val = (dest_addr == 4'b0000) ? 16'b0 : registers[dest_addr];
    wire [15:0] reg_src_val  = (src_addr  == 4'b0000) ? 16'b0 : registers[src_addr];

    // Sub-module connections
    wire [15:0] imm_ext_out;
    wire [15:0] alu_result;
    wire        zero_flag;
    wire [7:0]  bank_out;
    wire [15:0] mem_read_data;
    wire [15:0] io_read_data;

    // Multiplexers & Routing Logic

    // ALU Source B Mux: 0 = Reg Src, 1 = Immediate Ext
    wire [15:0] alu_operand_b = alu_src_mux ? imm_ext_out : reg_src_val;

    // Data Memory Address Mux: Stack Pointer (R15) or {Bank, Imm8}
    wire [15:0] sp = registers[4'b1111]; 
    wire [15:0] mem_addr = (stack_push || stack_pop) ? sp : {bank_out, instruction[7:0]};

    // Data Memory Write Data Mux: PC (for CALL) or Dest Reg (for PUSH/STORE)
    wire [15:0] mem_write_data = (instruction[15:12] == 4'b1100) ? pc : reg_dest_val;

    // Register Write Data Mux: 00=ALU, 01=Mem, 10=IO, 11=Stack(Mem)
    wire [15:0] reg_write_data = (reg_write_mux == 2'b00) ? alu_result :
                                 (reg_write_mux == 2'b01) ? mem_read_data :
                                 (reg_write_mux == 2'b10) ? io_read_data :
                                 mem_read_data; // 2'b11 pulls from memory (stack pop)
    
    // Module Instantiations
    inst_mem imem (
        .pc_addr(pc),
        .instruction(instruction)
    );

    control_unit cu (
        .instruction(instruction),
        .zero_flag(zero_flag),
        .reg_we(reg_we),
        .mem_we(mem_we),
        .bank_we(bank_we),
        .alu_funt(alu_funt),
        .alu_src_mux(alu_src_mux),
        .reg_write_mux(reg_write_mux),
        .pc_jump(pc_jump),
        .pc_branch(pc_branch),
        .pc_return(pc_return),
        .halt(halt),
        .io_read(io_read),
        .io_write(io_write),
        .stack_push(stack_push),
        .stack_pop(stack_pop)
    );

    imm_ext iext (
        .imm_in(instruction[7:0]),
        .opcode(instruction[15:12]),
        .imm_out(imm_ext_out)
    );

    alu alu_inst (
        .dest_reg(reg_dest_val),
        .src_reg(alu_operand_b),
        .funt(alu_funt),
        .result(alu_result),
        .zero_flag(zero_flag)
    );

    bank_reg breg (
        .clk(clk),
        .reset(reset),
        .bank_we(bank_we),
        .bank_in(instruction[7:0]),
        .bank_out(bank_out)
    );

    data_mem dmem (
        .clk(clk),
        .mem_we(mem_we || stack_push),
        .addr(mem_addr),
        .write_data(mem_write_data),
        .read_data(mem_read_data)
    );

    io_ctrl io (
        .clk(clk),
        .io_read(io_read),
        .io_write(io_write),
        .port_addr(instruction[7:0]),
        .write_data(reg_src_val), 
        .read_data(io_read_data)
    );

    // Synchronous Logic (PC, Register File, Stack Pointer)
    integer i;
    
    always @(posedge clk) begin
        if (reset) begin
            pc <= 16'h0000;
            // Initialize Registers
            for (i = 0; i < 16; i = i + 1) begin
                registers[i] <= 16'h0000;
            end
            // Initialize Stack Pointer to top of memory
            registers[15] <= 16'hFFFF; 
        end else if (!halt) begin
            
            // --- Program Counter Logic ---
            if (pc_jump) begin
                // Format J Provides 12-bit absolute jump within current bank
                pc <= {bank_out[3:0], instruction[11:0]}; 
            end else if (pc_branch) begin
                pc <= pc + imm_ext_out;
            end else if (pc_return) begin
                pc <= mem_read_data; // Pop PC from Stack
            end else begin
                pc <= pc + 1;
            end

            // --- Stack Pointer Management ---
            if (stack_push) begin
                registers[15] <= registers[15] - 1; // Decrement SP on push
            end else if (stack_pop) begin
                registers[15] <= registers[15] + 1; // Increment SP on pop
            end

            // --- Register File Write Logic ---
            // Ensure we never write to R0 (Zero Register) and handle standard writes
            if (reg_we && dest_addr != 4'b0000) begin
                registers[dest_addr] <= reg_write_data;
            end

        end
    end

endmodule