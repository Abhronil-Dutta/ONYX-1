`timescale 1ns / 1ps

module onyx1_top_tb;

    // Inputs to the top module
    reg clk;
    reg reset;

    // Instantiate the Unit Under Test (UUT)
    onyx1_top uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock Generation: 10ns period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $display("=========================================================================");
        $display("                         ONYX-1 CPU SIMULATION                           ");
        $display("=========================================================================");
        $display("Time |  PC  | Inst | Bank |   R1   |   R2   |   R4   |  [0x0308] (RAM) ");
        $display("-------------------------------------------------------------------------");

        // Use hierarchical referencing to spy on internal signals.
        // We will monitor whenever the PC changes to see the state after each instruction executes.
        $monitor("%4t | %h | %h |  %h  |  %h  |  %h  |  %h  |      %h      ", 
                 $time, 
                 uut.pc, 
                 uut.instruction, 
                 uut.bank_out, 
                 uut.registers[1], 
                 uut.registers[2], 
                 uut.registers[4],
                 uut.dmem.data_memory[16'h0308]); // Spying directly into the RAM address we write to

        // Initialize Inputs
        clk = 0;
        reset = 1;

        // Hold reset high for a few clock cycles
        #15;
        reset = 0;

        // Wait dynamically for the CPU to issue the HALT command internally
        // (uut.halt is the internal wire from the control unit)
        wait(uut.halt == 1'b1);
        
        // Wait one more clock cycle to let the halt register print
        #10;
        
        $display("=========================================================================");
        $display("                        CPU HALTED. TESTS COMPLETE.                      ");
        $display("=========================================================================");
        
        $finish;
    end

endmodule