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
        $display("Time |  PC  | Inst |   SP   |   R1   |   R2   |   R3   |   R4   |  [0x0255]: Product  [0x0256]: Dummy");
        $display("------------------------------------------------------------------------------------------------------");

        $monitor("%4t | %h | %h |  %h  |  %h  |  %h  |  %h  |  %h  |      %h               %h", 
                 $time, 
                 uut.pc, 
                 uut.instruction, 
                 uut.registers[15], // Spying on the Stack Pointer
                 uut.registers[1],  // Multiplicand
                 uut.registers[2],  // Multiplier (Watch this count down)
                 uut.registers[3],  // Product Accumulator (Watch this go up by 7)
                 uut.registers[4],  // Preserved State (Watch this pop back to AA)
                 uut.dmem.data_memory[16'h0255],
                 uut.dmem.data_memory[16'h0256]); // Spying directly into the RAM address we write to

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
        
        $display("CPU HALTED. TESTS COMPLETE.");
        
        $finish;
    end

endmodule