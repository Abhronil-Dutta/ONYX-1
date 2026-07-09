# ONIX - 1
### 16 Bit 
  

## Instruction Formats

### 1. Format R: Register & ALU Operations
Used for data manipulation between registers.
* **Layout:** `[Primary Opcode: 4b] [Dest Reg: 4b] [Src Reg: 4b] [Funct: 4b]`
* **Primary Opcode:** `0000`

### 2. Format I: Immediate, Memory & Branching
Used for memory access, loading constants, and conditional branching.
* **Layout:** `[Primary Opcode: 4b] [Reg: 4b] [Immediate/Address: 8b]`
* **Primary Opcodes:** `0001` to `1000`

### 3. Format J: Jumps & Calls
Used for unconditional absolute control flow.
* **Layout:** `[Primary Opcode: 4b] [Address: 12b]`
* **Primary Opcodes:** `1001` to `1010`

### 4. Format S: System & Stack Operations
Used for stack management and hardware state control.
* **Layout:** `[Primary Opcode: 4b] [Reg: 4b] [System Sub-Opcode: 8b]`
* **Primary Opcode:** `1111` (Escape Opcode)

**1101 to 1110 Opcodes are unused**

---

## Instruction Set Reference

### Format R (ALU Operations) - Opcode `0000`
*The ALU performs the operation using the registers, dictated by the 4-bit `Funct` field.*

| Instruction | Dest (11-8) | Src (7-4) | Funct (3-0) | Description |
| :--- | :--- | :--- | :--- | :--- |
| `ADD` | Dest | Src | `0000` | Dest = Dest + Src |
| `SUB` | Dest | Src | `0001` | Dest = Dest - Src |
| `AND` | Dest | Src | `0010` | Dest = Dest & Src |
| `OR`  | Dest | Src | `0011` | Dest = Dest \| Src |
| `XOR` | Dest | Src | `0100` | Dest = Dest ^ Src |
| `MOV` | Dest | Src | `0101` | Dest = Src |
| `SHL` | Dest | Src | `0110` | Dest = Dest << Src |
| `SHR` | Dest | Src | `0111` | Dest = Dest >> Src |
| `CMP` | Dest | Src | `1000` | Flags = Dest - Src (Discard Result) |
| `NOT` | Dest | `----` | `1001` | Dest = ~Dest (Bitwise Invert) |
| `INC` | Dest | `----` | `1010` | Dest = Dest + 1 |
| `DEC` | Dest | `----` | `1011` | Dest = Dest - 1 |

### Format I (Memory, I/O, Branches & ALU Immediate)
*Uses an 8-bit immediate value, an 8-bit memory address, or an 8-bit signed branch offset.*

| Instruction | Opcode (15-12) | Reg (11-8) | Imm/Addr (7-0) | Description |
| :--- | :--- | :--- | :--- | :--- |
| `LOADI` | `0001` | Dest | `Imm8` | Load 8-bit immediate into Reg |
| `LOAD` | `0010` | Dest | `Addr8` | Load from Memory[Addr8] to Reg |
| `STORE` | `0011` | Src | `Addr8` | Store Reg into Memory[Addr8] |
| `SETBANK` | `0100` | Bank | `00000000` | Set active memory bank/page |
| `BR_ZERO` | `0101` | `0000` (unused) | `Offset8` | if (zero_flag) PC = PC + Offset8 |
| `BR_NOTZ` | `0110` | `0000` (unused) | `Offset8` | if (!zero_flag) PC = PC + Offset8 |
| `READ` | `0111` | Dest | `Port8` | Read from Hardware I/O Port8 |
| `WRITE` | `1000` | Src | `Port8` | Write to Hardware I/O Port8 |
| `ADDI` | `1001` | Dest | `Imm8` | Dest = Dest + Imm8 (signed) |
| `SUBI` | `1010` | Dest | `Imm8` | Dest = Dest - Imm8 (signed) |

### Format J (Unconditional Control Flow)
*Provides a 12-bit address space for absolute jumps within the current bank.*

| Instruction | Opcode (15-12) | Address (11-0) | Description |
| :--- | :--- | :--- | :--- |
| `JUMP` | `1011` | `Addr12` | PC = Addr12 |
| `CALL` | `1100` | `Addr12` | Push PC to Stack, PC = Addr12 |

### Format S (System & Stack Expansion) - Opcode `1111`
*Uses the Escape Opcode `1111` and an 8-bit sub-opcode to define stack and hardware state instructions.*

| Instruction | Reg (11-8) | Sub-Opcode (7-0) | Description |
| :--- | :--- | :--- | :--- |
| `PUSH` | Src | `00000001` | Push Reg onto the Stack |
| `POP` | Dest | `00000010` | Pop from Stack into Reg |
| `RETURN` | `0000` | `11111101` | Pop PC from Stack |
| `NOP` | `0000` | `11111110` | No Operation |
| `HALT` | `0000` | `11111111` | Stop execution / Wait for Interrupt |