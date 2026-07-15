module control_unit (
    input      [15:0] instruction,
    input             zero_flag,    // From the ALU

    // Basic Datapath Controls
    output reg        reg_we,       // Register File Write Enable
    output reg        mem_we,       // Data Memory Write Enable
    output reg        bank_we,      // Update the Bank Register
    output reg [3:0]  alu_funt,     // What operation the ALU does
    output reg        alu_src_mux,  // 0 = Reg2, 1 = Immediate
    output reg [1:0]  reg_write_mux,// 00=ALU, 01=Mem, 10=IO, 11=Stack

    // Program Counter Controls
    output reg        pc_jump,      // Absolute Jump
    output reg        pc_branch,    // Relative Branch
    output reg        pc_return,    // Tell PC to load from Stack (for RETURN)
    output reg        halt,         // Freeze CPU

    // Hardware I/O & Stack Controls
    output reg        io_read,
    output reg        io_write,
    output reg        stack_push,
    output reg        stack_pop
);

    // Extract fields from the 16-bit instruction
    wire [3:0] opcode     = instruction[15:12];
    wire [3:0] funt       = instruction[3:0];
    wire [7:0] sub_opcode = instruction[7:0]; // For Format S

    always @(*) begin
        reg_we        = 1'b0;
        mem_we        = 1'b0;
        bank_we       = 1'b0;
        alu_funt      = 4'b0000;
        alu_src_mux   = 1'b0; 
        reg_write_mux = 2'b00; 
        pc_jump       = 1'b0;
        pc_branch     = 1'b0;
        pc_return     = 1'b0;
        io_read       = 1'b0;
        io_write      = 1'b0;
        stack_push    = 1'b0;
        stack_pop     = 1'b0;
        halt          = 1'b0;
        case (opcode)
            // FORMAT R: Register & ALU Operations
            4'b0000: begin
                if (funt == 4'b1000) begin 
                    // CMP (Compare)
                    alu_funt = 4'b0001; // Force ALU to do SUB
                    reg_we   = 1'b0;    // Do NOT save the result
                end else begin
                    // ADD, SUB, AND, OR, XOR, MOV, SHL, SHR, NOT, INC, DEC
                    alu_funt      = funt;  // Pass 4-bit funct code to ALU
                    reg_we        = 1'b1;  // Save the result
                    reg_write_mux = 2'b00; // Source is ALU
                end
            end

            // FORMAT I: Immediate, Memory, I/O, Branches
            4'b0001: begin // LOADI (Load Immediate)
                alu_src_mux   = 1'b1;   // Route Immediate to ALU
                alu_funt      = 4'b0101;// Tell ALU to "MOV" (pass it through)
                reg_we        = 1'b1;   
                reg_write_mux = 2'b00;  // Save ALU output to Register
            end

            4'b0010: begin // LOAD (Load from Data Memory)
                reg_we        = 1'b1;   
                reg_write_mux = 2'b01;  // Route Memory output to Register
            end

            4'b0011: begin // STORE (Store to Data Memory)
                mem_we = 1'b1;
            end

            4'b0100: begin // SETBANK
                bank_we = 1'b1;
            end

            4'b0101: begin // BR_ZERO
                if (zero_flag == 1'b1) pc_branch = 1'b1;
            end

            4'b0110: begin // BR_NOTZ
                if (zero_flag == 1'b0) pc_branch = 1'b1;
            end

            4'b0111: begin // READ (From I/O Port)
                io_read       = 1'b1;
                reg_we        = 1'b1;
                reg_write_mux = 2'b10; // Route I/O output to Register
            end

            4'b1000: begin // WRITE (To I/O Port)
                io_write = 1'b1;
            end

            4'b1001: begin // ADDI
                alu_src_mux   = 1'b1;    // Route Immediate to ALU
                alu_funt      = 4'b0000; // ADD
                reg_we        = 1'b1;
                reg_write_mux = 2'b00;
            end

            4'b1010: begin // SUBI
                alu_src_mux   = 1'b1;    // Route Immediate to ALU
                alu_funt      = 4'b0001; // SUB
                reg_we        = 1'b1;
                reg_write_mux = 2'b00;
            end

            // FORMAT J: Jumps & Calls
            4'b1011: begin // JUMP
                pc_jump = 1'b1;
            end

            4'b1100: begin // CALL
                pc_jump    = 1'b1; // Jump to the target address
                stack_push = 1'b1; // Push the current PC to the stack
            end

            // FORMAT S: System & Stack Operations
            4'b1111: begin 
                case (sub_opcode)
                    8'b00000001: begin // PUSH
                        stack_push = 1'b1; // Push Register to stack
                    end
                    
                    8'b00000010: begin // POP
                        stack_pop     = 1'b1;
                        reg_we        = 1'b1;
                        reg_write_mux = 2'b11; // Route Stack output to Register
                    end
                    
                    8'b11111101: begin // RETURN
                        stack_pop = 1'b1; // Pop address off stack
                        pc_return = 1'b1; // Tell PC to load this popped address
                    end
                    
                    8'b11111110: begin // NOP
                        // Literally do nothing. The default signals handle this perfectly!
                    end
                    
                    8'b11111111: begin // HALT
                        halt = 1'b1; // Freeze the Program Counter
                    end
                    
                    default: ; // Unknown Format S instruction
                endcase
            end

            default: ; // Unknown Primary Opcode
        endcase
    end

endmodule