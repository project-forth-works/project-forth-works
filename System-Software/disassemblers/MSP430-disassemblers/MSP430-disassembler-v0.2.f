\ Disassembler for MSP430
\ (C) 2015, 2016, 2021. Albert Nijhof & Willem Ouwerkerk
\ an    -- 05mei12 -- 430 disassembler
\ an jan2016 - XOR> and AND> changed to BIX and BIA
\ an 30mei2017 - stopper per line
\ wo 29oct2021 - adapted for EmbeddingForth

\ This disassembler output uses noForth assembler notation.
\ MSP assembly     disassembles to
\ ------------     ------------      --------------
\ PC TOS           pc tos            Register names
\ PC@              pc )              Indirect addressing
\ @PC+             pc )+             Indirect with autoincrement
\ 430              xx pc x)          xx + pc = 430 (Symbolic mode)
\ 2(R8)            2 r8 x)           Indexed
\ #430             430 #             constant 430 assembled as pc )+
\ &430             430 &             Absolute using SR
\ #4 #8            #4 #8             Constants using RS
\ #0 #1 #2 #-1     #0 #1 #2 #-1      Constants using CG
\
\ Not in Generic Forth: WITHIN  CELL-  1-  @+  <>
\ Note that the check on CFA's 'dasa @ @+ =' is only correct for ITC code.
\ Lines starting with ( ) have implementation specific dependencies.

hex  \ until the end
variable DASA       \ Address to disassemble
variable IDATA      \ Offset to inline assembler data
: PEMIT     ( ch -- )           dup 7F < and  bl max  emit ; \ Output ch as printable char
: @CODE     ( -- opc )          dasa @ cell- @ ;    \ Fetch one machine code
: >MDATA    ( +n -- opc-data )  @code swap rshift ; \ Get data field from machine code
: @IDATA    ( -- inl# )         idata @  dasa @ + @  2 idata +! ; \ Inline opcode data

: .MNEMO    ( reg a u -- )
    drop  swap 2* 2* + 4
    dup 0 do  2dup + 1- c@ bl = +  loopv \ -trailing
    type space ;

:  .W&W     ( -- )                  \ Print where and what
    cr dasa @  dup 5 u.r ." : "     \ Print address
    dup  2 0 do  count pemit  loop  \ Print text
    drop space  @  5 u.r  3 spaces  \ Print content
    2 dasa +! ;

: .DST      ( adr-mode reg -- )     \ Print register name & addressing mode
    over 1 = if 
        @idata u.  dup 2 = if
            2drop  ." & "  exit
    then then
\  R0  R1  R2  R3  R4  R5  R6  R7  R8  R9  R10 R11 R12 R13 R14 R15
    s" pc  rp  sr  cg  sp  ip  w   tos day moonsun xx  yy  zz  dox nxt " .mnemo
    dup 1 = if  ." x) "  then
    dup 2 = if  ." ) "   then
        3 = if  ." )+ "  then ;

: .SRC      ( adr-mode reg -- )
    F and  dup 3 = if           \ cg #-1 #0 #1 #2
        drop  dup 3 = if  4 -  then  ." #" .  exit
    then
    over 2 and  over 2 = and if  ." #"  1- swap lshift .  exit  then \ sr #4 #8
    2dup + 3 = if  2drop  @idata u.  ." # "  exit  then  .dst ;

: B/W       ( -- )      @code 40 and if  ." .b "  then ;

: ONE-OP    ( -- )
    7 >mdata 7 and  dup 6 <>    \ Not reti?
    if  4 >mdata 3 and  @code .src  b/w  then
    s" RRC SWPBRRA SXT PUSHCALLRETI7?  " .mnemo ;

: TWO-OP    ( -- )
    4 >mdata 3 and  8 >mdata .src  space space
    7 >mdata 1 and  @code F and .dst  b/w  C >mdata 4 - 
    s" MOV ADD ADDCSUBCSUB CMP DADDBIT BIC BIS BIX BIA " .mnemo ;

: JMP-OP    ( -- )
    @code 3FF and  dup 1FF >    \ Negative distance?
    if  FC00 or  then  s>d >r   \ Backward?
    2* dasa @ +                 \ Calculate destination
    0A >mdata 7 and  dup
\   J0<>J0= JCC JCS J0< J>= J<  GOTO"
    s" =?  <>? cs? cc? pos?>?  <eq?    " .mnemo
    7 = if
        8 emit  r@ if  ." AGAIN,"  else  ." AHEAD,"  then
    else
        r@ if  ." UNTIL,"  else  ." IF,"  then
    then 
    5 spaces  [char] +  r> 2* - emit  [char] > emit  u. ;

\ Decode one instruction, the address has to be in dasa
: DAS+      ( -- )              \ Disassemble next instruction
( ) dasa @ @+ = if  .w&w ." --- cfa ---"  then
    .w&w   0 idata !
    0C >mdata dup 0= if         \ Invalid opcode type?
        drop  ." ?"
    else
        dup 1 = if              \ One argument opcode?
            drop  one-op
        else
            4 < if              \ Jump opcode?
                jmp-op
            else
                two-op          \ No, two arg. opcode
    then then then
( ) @code 4630 = if ." --->>" cr then   \ Execute?
    begin  idata @ while  -2 idata +!   \ Inline data, yes adjust IDATA
( ) dasa @ @+ <> while  .w&w            \ Stop on new code definition, otherwise print data
    repeat  then 
( ) dasa @ @+ = if cr  then ;           \ New code definition found?

\ ----- User words
: MDAS      ( adr -- )
    FFFE and dasa !  begin  das+  key bl = 0= until ;

: DAS       ( ccc -- )      '  mdas ;

cr .( MSP430 disassembler loaded )

\ ;;;
