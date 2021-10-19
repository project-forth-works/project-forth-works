\ Assembler for MSP430, 1472 bytes long
\ (C) 2015, 2021. Albert Nijhof & Willem Ouwerkerk
\ 12feb2016 - added: BIX BIA 0=? 0<>? (aliases for =? <>=?)
\ 30mei2017 - NEXT deleted
\ 27feb2018 - test for "distance too large" added in JCODE
\ 02mar2018 - state=smart # in noForth C and CC
\ 05sep2021 - Adapted to minimal Forth
\
\   When state is true, the core word # is compiled,
\   when state is false, the assembler # is executed.
\   In assembler macros
\   the assembler # will produce an error message:
\           : test chere # tos add ;
\   Use -4 in stead
\           : test chere -4 tos add ;
\
\ Assumptions: A cell is 16-bit wide
\ Extra words: CHERE ROM! ?ABORT  STATE POSTPONE IMMEDIATE #

hex     \ until the end
\ ----- Register names & addressing modes
00 constant PC    01 constant RP    02 constant SR    03 constant CG
04 constant SP    05 constant IP    06 constant W     07 constant TOS
08 constant DAY   09 constant MOON  0A constant SUN   0B constant XX
0C constant YY    0D constant ZZ    0E constant DOX   0F constant NXT

-1 constant X)    -2 constant )      3 constant )+
-5 constant -)    40 constant .B     : #0  cg ;
: #2  cg ) ;      : #-1 cg )+ ;      : #1  0 cg x) ; \ no extension!
: #4  sr ) ;      : #8  sr )+ ;      : &   sr x) ;

: #     state @ if  postpone # exit  then  -4 ; immediate

variable EXT?   \ lo-byte:  registerposition in opcode
                \ hi-byte:  bit1set -> ext1, bit2 set -> ext2
variable EXT1
variable EXT2

: PREP      ( ?? a -- ?? opc )
    @  over .b = if or then     \ Byte or Word
    over -) = if                \ -) macro selected
        nip  >r  ext2 !         \ Remove -) save opcode & rd
        r@ 40 and               \ Byte or cell SUB?
        if 8310 else 8320 then  \ Select SUB opcode
        ext2 @ or ,             \ Add dest. reg. & assemble SUB
        ext2 @ )  r>            \ followed by main instruction
    then  0 ext? ! ;

: DST       ( ?? opc -- ?? opc )
    >r s>d 0= if  0  then                               \ reg.direct
    dup ) =   if  drop  0 swap x)  then                 \ reg )  ->  0 reg x)
    dup x) =  if  rot ext2 !  200 ext? **bis  then      \ index>extension
    -2 over < if  negate 7 ( a.pos ) lshift  r> or swap
                  dup 0F u> ?abort                      \ reg error
                  ext? c@ ( r.pos ) lshift or exit      \ reg  and   reg x)
              then  true ?abort ;

: SRC       ( ?? opc -- opc )
    >r s>d 0= if  0  then                       \ reg.direct
    dup x) =  if  rot ext1 !  over cg <>        \ ext ?
                  if  100 ext? **bis  then      \ not for #1
              then
    dup -4 =  if  drop ext1 !  100 ext? **bis pc )+  then   \ xxxx #
    -4 over < if  negate 4 ( a.pos ) lshift  r> or swap
                  dup 0F u> ?abort                          \ reg error
                  ext? c@ ( r.pos ) lshift or  exit         \ all addrmodes
              then
    true ?abort ;

: ,,,       ( opc -- )
    ,  100 ext? bit** if  ext1 @ ,  then \ Write the code & additional data when used
       200 ext? bit** if  ext2 @ ,  then ;

: 1OP    create ,  does> prep src   ,,, ;
: 2OP    create ,  does> prep dst   8 ext? c! src   ,,,  ;

\ ----- Mnemocodes
: RETI 1300 , ;

1000 1op RRC    1080 1op SWPB   1100 1op RRA
1180 1op SXT    1200 1op PUSH   1280 1op CALL
4000 2op MOV    5000 2op ADD    6000 2op ADDC
7000 2op SUBC   8000 2op SUB    9000 2op CMP
A000 2op DADD   B000 2op BIT    C000 2op BIC
D000 2op BIS    E000 2op BIX    F000 2op BIA 

\ ----- Conditions
2000 constant =?        2400 constant <>?
2000 constant 0=?       2400 constant 0<>?
2800 constant CS?       2C00 constant CC?
2800 constant U<EQ?     2C00 constant U>?
3000 constant POS?      3400 constant >?
3800 constant <EQ?      3C00 constant NEVER

: ?COND     ( cond -- )     never invert and ?abort ;

: JCODE     ( to from -- jumpcode ) \ Calculate distance & add condition (ext1).
    cell+ - 2/
    dup 201 -1FF within ?abort      \ 27feb2018
    3FF and  ext1 @ dup ?cond or ;

\ never  = cond for always.jump, see ahead, again
\ never  = masker for condition, see ?cond
\ 3FF    = masker for offset, see then and until
\ Assembler safety numbers:
\ 66 sys\if,     for then, ahead, repeat,
\ 77 sys\begin,  for until, again, repeat,
\ ----- Assembler conditionals

: IF,       ( cond -- ifa ifcond+66 )   dup ?cond 66  or chere swap  -1 , ;
: BEGIN,    ( -- begina 77 )            chere 77 ;

: THEN,     ( ifa ifcond+66 -- )
    never
    2dup and  ext1 !        \ ifa ifcond+66
    invert and 66 - ?abort  \ ifa=from
    chere over              \ ifa=! chere=to ifa=from
    jcode swap              \ jcode ifa!
    rom! ;

: UNTIL,    ( begina 77 cond -- )
    ext1 !                  \ begina 77
    77 - ?abort             \ begina=to
    chere                   \ begina=to chere=from
    jcode , ;

: AHEAD,        never if, ;     
: ELSE,         ahead, 2swap then, ;
: AGAIN,        never until, ;
: REPEAT,       again, then, ;
: WHILE,        if, 2swap ;

: JMP           77 again, ;     \ jump, relative addr in opcode

\ ----- Macros
\ : NEXT  nxt pc mov ;
\ : SETC  #1 sr bis ;   : CLRC  #1 sr bic ;
\ : EINT  #8 sr bis ;   : DINT  #8 sr bic ;

\ Example for ITC code defining word and ending
\ : CODE          header  chere cell+ ,  0  55 ;
\ : END-CODE      55 - ?abort  if exit then  reveal ;

cr .(   MSP430 assembler loaded    )
\ <><>
