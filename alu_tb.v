`timescale 1ns / 1ps // Sets the simulation time units

module alu_tb;

    reg  [15:0] dest_reg;
    reg  [15:0] src_reg;
    reg  [3:0]  funt;

    wire [15:0] result;
    wire        zero_flag;

    alu uut (
        .dest_reg(dest_reg),
        .src_reg(src_reg),
        .funt(funt),
        .result(result),
        .zero_flag(zero_flag)
    );

    initial begin
        $monitor("Time=%0t | Funt=%b | Dest=%h, Src=%h | Result=%h | Zero=%b",
                 $time, funt, dest_reg, src_reg, result, zero_flag);

        $display("Tests Starting");

        dest_reg = 16'h0005;
        src_reg  = 16'h0003;
        funt     = 4'b0000;
        #10;
        if (result == 16'h0008 && zero_flag == 1'b0)
            $display("PASS: ADD");
        else
            $display("FAIL: ADD");

        dest_reg = 16'h0005;
        src_reg  = 16'h0003;
        funt     = 4'b0001;
        #10;
        if (result == 16'h0002 && zero_flag == 1'b0)
            $display("PASS: SUB");
        else
            $display("FAIL: SUB");

        dest_reg = 16'h0005;
        src_reg  = 16'h0003;
        funt     = 4'b0010;
        #10;
        if (result == 16'h0001 && zero_flag == 1'b0)
            $display("PASS: AND");
        else
            $display("FAIL: AND");

        dest_reg = 16'h0005;
        src_reg  = 16'h0003;
        funt     = 4'b0011;
        #10;
        if (result == 16'h0007 && zero_flag == 1'b0)
            $display("PASS: OR");
        else
            $display("FAIL: OR");

        dest_reg = 16'h0005;
        src_reg  = 16'h0003;
        funt     = 4'b0100;
        #10;
        if (result == 16'h0006 && zero_flag == 1'b0)
            $display("PASS: XOR");
        else
            $display("FAIL: XOR");

        dest_reg = 16'h0005;
        src_reg  = 16'h0003;
        funt     = 4'b0101;
        #10;
        if (result == 16'h0003 && zero_flag == 1'b0)
            $display("PASS: MOV");
        else
            $display("FAIL: MOV");

        dest_reg = 16'h0001;
        src_reg  = 16'h0004;
        funt     = 4'b0110;
        #10;
        if (result == 16'h0010 && zero_flag == 1'b0)
            $display("PASS: SHL");
        else
            $display("FAIL: SHL");

        dest_reg = 16'h0010;
        src_reg  = 16'h0004;
        funt     = 4'b0111;
        #10;
        if (result == 16'h0001 && zero_flag == 1'b0)
            $display("PASS: SHR");
        else
            $display("FAIL: SHR");

        dest_reg = 16'h0005;
        src_reg  = 16'h0005;
        funt     = 4'b1000;
        #10;
        if (result == 16'h0000 && zero_flag == 1'b1)
            $display("PASS: CMP zero flag");
        else
            $display("FAIL: CMP zero flag");

        dest_reg = 16'h0000;
        src_reg  = 16'h0000;
        funt     = 4'b1001;
        #10;
        if (result == 16'hFFFF && zero_flag == 1'b0)
            $display("PASS: NOT");
        else
            $display("FAIL: NOT");

        dest_reg = 16'h0000;
        src_reg  = 16'h0000;
        funt     = 4'b1010;
        #10;
        if (result == 16'h0001 && zero_flag == 1'b0)
            $display("PASS: INC");
        else
            $display("FAIL: INC");

        dest_reg = 16'h0001;
        src_reg  = 16'h0000;
        funt     = 4'b1011;
        #10;
        if (result == 16'h0000 && zero_flag == 1'b1)
            $display("PASS: DEC zero flag");
        else
            $display("FAIL: DEC zero flag");

        $display("End of Tests");
        $finish;
    end

endmodule
