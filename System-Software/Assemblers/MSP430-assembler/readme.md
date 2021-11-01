# MSP430 assembler

## The idea:
A compact universal MSP430 assembler

## Implementation
The example asumes a 16-bit machine and compile actions.
Also a Flash environment is assumed, for RAM only systems `ROM!` can be replaced by `!` and `CHERE` by `HERE`.
Examples of macros are in the source file. An implementation example for `CODE` and `END-CODE` is showed too.
Missing words are:  
```
CHERE ROM! ?ABORT

: CHERE  ( -- a )    Leave flash or FRAM address on the stack ; 
: {W     ( -- )      enable write access to flash or FRAM ;
: W}     ( -- )      disable write access to flash or FRAM ;
: ROM!   ( x -- )    {W  !  W} ;       \ Store 'x' in flash or FRAM
: ?ABORT ( f -- )    if  quit  then ;  \ Replace noForth style compact error message

``` 


**27 instructions (16b, .B = 8b)**
```
✦ 6 instructions with 1 operand
   RRA RRC SWPB SXT PUSH CALL
  
✦ 12 instructions with 2 operands
   MOV CMP ADD SUB ADDC SUBC DADD
   BIT BIS BIC BIA (AND) BIX (XOR)
  
✦ 8 jump instructions with relative inline addresses
   JNZ JZ JNC JC JN JGE JL JMP
  
✦ return from interrupt
   RETI
```

Example of it's use:
```
code LSHIFT ( x1 n -- x2 )
  tos w mov
  sp )+ tos mov
  #0 w cmp  <>? if, 
    begin, 
      tos tos add
      #1 w sub
  =? until,
then, 
next  end-code
```
