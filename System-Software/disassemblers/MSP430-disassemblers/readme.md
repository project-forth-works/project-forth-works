# Disassemblers

- [MSP430 disassembler  ](MSP430-disassembler-v0.2.f)  
Compact universal MSP430 disassembler (the 27 basic opcodes). 
Note that the check on CFA's `dasa @ @+ =` is only correct for ITC code. 
For other systems these lines need adaptation.  
Not in SimpleForth: `WITHIN  CELL-  1-  @+  <>`  

An example of its use disassemble `DUP`, `?DUP` & `DROP` in noForth:
```
das dup
 4BF0:  K  4BF2   --- cfa ---
 4BF2: $   8324   #2   sp SUB
 4BF4:  G  4784   tos   0 sp x) MOV
 4BF6:        0
 4BF8:  O  4F00   nxt   pc MOV
 4BFA:  H  48B0   day )+   8481 pc x) MOV
 4BFC:     8481
 4BFE: ?D  443F   sp )+   nxt MOV
 4C00: UP  5055   4C04 pc x)   ip .b ADD

 4C02:  L  4C04   --- cfa ---
 4C04:     9307   #0   tos CMP
 4C06:  #  23F5   =? UNTIL,     ->4BF2
 4C08:  O  4F00   nxt   pc MOV
 4C0A: 6K  4B36   xx )+   w MOV
 4C0C:     8481   sp   5244 rp x) SUB
 4C0E: DR  5244
 4C10: OP  504F   pc   nxt .b ADD

 4C12:  L  4C14   --- cfa ---
 4C14: 7D  4437   sp )+   tos MOV
 4C16:  O  4F00   nxt   pc MOV
 ```
 | Command | Example | Purpose |
 | ------- | ------- | ------- |
 | `DAS`   | `DAS DUP` | Disassemble from the word `DUP` |
 | `MDAS`  | `<addr> MDAS` | Disassemble from `<addr>` |
 
 Each time the space bar is hit, a new line is disassembled. When any other key is hit the disassembly stops!
 
