`timescale 1ns / 1ps

module control_unit_tb;

    // 1. Inputs (reg)
    reg [15:0] instruction;
    reg        zero_flag;

    // 2. Outputs (wire)
    wire       reg_we;
    wire       mem_we;
    wire       bank_we;
    wire [3:0] alu_funt;
    wire       alu_src_mux;
    wire [1:0] reg_write_mux;
    wire       pc_jump;
    wire       pc_branch;
    wire       pc_return;
    wire       halt;
    wire       io_read;
    wire       io_write;
    wire       stack_push;
    wire       stack_pop;

    // 3. Instantiate the Control Unit (DUT)
    control_unit uut (
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

    // 4. Test Stimulus
    initial begin
        $display("===============================================================");
        $display("                 ONIX-1 Control Unit Tests                     ");
        $display("===============================================================");
        
        // $monitor prints any time one of these variables changes
        $monitor("Time=%0t | Inst=%b | Z=%b | WE:R=%b M=%b | ALU_F=%b Mux=%b | PC_J=%b PC_B=%b | Halt=%b | Stk_Psh=%b", 
                 $time, instruction, zero_flag, reg_we, mem_we, alu_funt, alu_src_mux, pc_jump, pc_branch, halt, stack_push);

        // TEST 1: Format R - ADD R1, R2 (Opcode 0000, Funct 0000)
        // Instruction Layout: [Opcode:4] [Dest:4] [Src:4] [Funct:4]
        // 0000_0001_0010_0000
        $display("\n--- Test 1: ADD R1, R2 ---");
        instruction = 16'b0000_0001_0010_0000;
        zero_flag   = 1'b0;
        #10; 
        // Expected: reg_we=1, alu_funt=0000, everything else 0

        // TEST 2: Format R - CMP R1, R2 (Opcode 0000, Funct 1000)
        // 0000_0001_0010_1000
        $display("\n--- Test 2: CMP R1, R2 ---");
        instruction = 16'b0000_0001_0010_1000;
        #10;
        // Expected: reg_we=0 (don't save), alu_funt=0001 (SUB)

        // TEST 3: Format I - LOADI R3, 5 (Opcode 0001)
        // Instruction Layout: [Opcode:4] [Reg:4] [Imm:8]
        // 0001_0011_00000101
        $display("\n--- Test 3: LOADI R3, 5 ---");
        instruction = 16'b0001_0011_00000101;
        #10;
        // Expected: reg_we=1, alu_src_mux=1, alu_funt=0101 (MOV)

        // TEST 4: Format I - BR_ZERO (Opcode 0101)
        // 0101_0000_00001010
        $display("\n--- Test 4: BR_ZERO (Z=0 then Z=1) ---");
        instruction = 16'b0101_0000_00001010;
        zero_flag   = 1'b0; // Should NOT branch
        #10;
        zero_flag   = 1'b1; // SHOULD branch
        #10;
        // Expected: pc_branch=0, then pc_branch=1

        // TEST 5: Format J - CALL (Opcode 1100)
        // Instruction Layout: [Opcode:4] [Addr:12]
        // 1100_111111111111
        $display("\n--- Test 5: CALL ---");
        instruction = 16'b1100_111111111111;
        #10;
        // Expected: pc_jump=1, stack_push=1

        // TEST 6: Format S - HALT (Opcode 1111, Sub-Opcode 11111111)
        // Instruction Layout: [Opcode:4] [Reg:4] [Sub:8]
        // 1111_0000_11111111
        $display("\n--- Test 6: HALT ---");
        instruction = 16'b1111_0000_11111111;
        #10;
        // Expected: halt=1

        $display("\n===============================================================");
        $display("                        TESTS COMPLETE                         ");
        $display("===============================================================");
        $finish;
    end

endmodule