# ONYX-1

ONYX-1 is a custom 16-bit CPU implemented in Verilog. It is designed as a compact reference implementation for a future machine :).

## 1. Project Overview

- 16-bit custom instruction set architecture (ISA)
- 64KB RAM accessed through an 8-bit banked addressing model
- 16 general-purpose registers, `R0` through `R15`
- `R0` is hardwired to zero
- `R15` is the stack pointer and is managed natively in hardware
- Memory-mapped I/O is integrated through a dedicated controller
- The control unit stores flags in dedicated state, avoiding combinatorial flag glitches in branch and compare paths

## 2. Architecture Summary

- Instruction width: 16 bits
- Memory model: `physical_address = {bank[7:0], offset[7:0]}`
- Active bank register: `8-bit`
- Jump model: 12-bit absolute target within the active bank
- Stack model: hardware stack pointer mapped directly onto main RAM
- Key modules:
  - Top-level datapath
  - ALU
  - Control unit
  - Bank register
  - Instruction memory
  - Data memory
  - I/O controller
  - Immediate extender

## 3. Instruction Set Reference

### Format R: Register and ALU Operations

Encoding: `[opcode:4] [dest:4] [src:4] [funct:4]`

- `ADD` `0000` - `dest = dest + src`
- `SUB` `0001` - `dest = dest - src`
- `AND` `0010` - `dest = dest & src`
- `OR` `0011` - `dest = dest | src`
- `XOR` `0100` - `dest = dest ^ src`
- `MOV` `0101` - `dest = src`
- `SHL` `0110` - `dest = dest << src`
- `SHR` `0111` - `dest = dest >> src`
- `CMP` `1000` - compare only, update flags and discard the result
- `NOT` `1001` - bitwise invert `dest`
- `INC` `1010` - increment `dest`
- `DEC` `1011` - decrement `dest`

### Format I: Immediate, Memory, I/O, and Branching

Encoding: `[opcode:4] [reg:4] [imm_or_addr:8]`

- `LOADI` `0001` - load an 8-bit immediate into a register
- `LOAD` `0010` - load from banked memory into a register
- `STORE` `0011` - store a register to banked memory
- `SETBANK` `0100` - update the active 8-bit memory bank
- `BR_ZERO` `0101` - branch relative if zero flag is set
- `BR_NOTZ` `0110` - branch relative if zero flag is clear
- `READ` `0111` - read from a memory-mapped I/O port
- `WRITE` `1000` - write to a memory-mapped I/O port
- `ADDI` `1001` - add a signed immediate to a register
- `SUBI` `1010` - subtract a signed immediate from a register

### Format J: Unconditional Control Flow

Encoding: `[opcode:4] [address:12]`

- `JUMP` `1011` - absolute jump within the active bank
- `CALL` `1100` - push return state and branch to the target address

### Format S: System and Stack Operations

Encoding: `[opcode:4] [reg:4] [sub_opcode:8]`

- `PUSH` `1111 0000 0000 0001` - push a register onto the stack
- `POP` `1111 0000 0000 0010` - pop the stack into a register
- `RETURN` `1111 0000 1111 1101` - return to the popped program counter
- `NOP` `1111 0000 1111 1110` - no operation
- `HALT` `1111 0000 1111 1111` - stop execution

## 4. Memory Map and Register Design

### Memory

- Total data memory: 64KB
- Addressing is banked by design:
  - bank selects the upper 8 bits
  - instruction or data offset provides the lower 8 bits
- `LOAD` and `STORE` use the active bank plus the 8-bit address field
- `CALL`, `PUSH`, `POP`, and `RETURN` reuse RAM as the native stack storage path

### Registers

- `R0` - hardwired zero register
- `R1` - argument register 1
- `R2` - argument register 2
- `R3` - argument register 3
- `R4` - return value register
- `R5` through `R13` - general-purpose registers
- `R14` - frame pointer
- `R15` - stack pointer

### I/O

- Memory-mapped I/O is handled by the `io_ctrl` module
- Ports are addressed through the 8-bit port field in the instruction
- Current implementation exposes four 16-bit ports

## 5. Simulation and Build Instructions

ONYX-1 is tested with Icarus Verilog and `vvp`.

Build and run:

```bash
iverilog -o onyx_sim.vvp alu.v bank_reg.v control_unit.v data_mem.v imm_ext.v inst_mem.v io_ctrl.v onyx1_top.v onyx1_top_tb.v
vvp onyx_sim.vvp
```

Notes:

- `inst_mem.v` loads the program image from `program.hex` at simulation start
- The top-level testbench exercises a custom multiplication subroutine and halts when the program completes
- The testbench also monitors the stack pointer, arithmetic registers, and selected RAM locations to verify execution flow
