(* Bit array for compact noting of precence or on/off state

   The origimal idea of this is from Albert Nijhof,
   this implementation (c) 2021 Willem Ouwerkerk.
   This code assumes that the dataspace is reserved & addressed in
   words. To keep track of 64 entries one only needs 8 bytes.

This variant which calculates the sizes from a system value!
With out of bounds detection for this version.

Note that: The defining word BITARRAY has two entries. The first line
   is for a forth system with seprate SRAM, the second for a RAM only system.

\ Word version of bit set, bit clear & bit test instructions
: **BIS  ( mask addr -- )       tuck @ or  swap ! ;
: **BIC  ( mask addr -- )       >r  invert  r@ @ and  r> ! ;
: BIT**  ( mask addr -- 0|b )   @ and ;

: @+     ( a1 -- a2 x )         dup cell+  swap @ ;

*)

hex
8 cells  constant #BITS \ Bits in a cell
: >LEN      ( a1 -- #n )    @ #bits * ; \ Length in bits of bit array a1
: >ADR      ( a1 -- a2 )    cell+ @ ;   \ Start address of bit array a1

: LOC           ( nr a1 -- bit a2 )     \ Bit location in word-addr
    2dup >len < 0= ?abort   \ Valid bit flag check
    @+ 1- >r  @             \ nr adr 
    >r  dup #bits 1- and    \ nr bit-nr
    1 swap lshift           \ nr bit-mask 
    swap #bits /            \ nr / bits in a cell
    r> swap  r> and cells + ; \ Mask excess bits, leave bit-array offset
                            \ Leave bit & word-adr
: BITARRAY
    create      ( +n "name"-- )  ( exec: -- a )
        #bits /mod                  \ Calculate length in cells & remainder
        swap if 1+ then  dup ,      \ Round length to the next cell
        here , cells allot ;        \ Save RAM pointer, reserve RAM in ROM Forth
\       here cell+ , cells allot ;  \ Save pointer, reserve RAM in RAM Forth

: *SET      ( nr a -- )       loc **bis ; \ Set bit nr in array a
: *CLR      ( nr a -- )       loc **bic ; \ Erase bit nr from array a
: GET*      ( nr a -- 0|msk ) loc bit** ; \ Bit nr set in array a?
: ZERO      ( a -- )          dup >adr  swap >len 8 /  0 fill ; \ Erase bit-map a



\ Additional routines:
\ COPY any bit array to another, use the length of the shortest array!
: COPY      ( a1 a2 -- )    \ Copy array a1 to array a2
    dup zero  >r            \ Erase target array a2
    dup >adr  swap >len     \ Get address & length of origin array
    r@ >len  min  8 /       \ Use shortest length in bytes
    r> >adr  swap move ;    \ Move to destination array

\ Leave number of bits set in bit array a
: COUNT*    ( a -- +n )     \ Counted noted high bits
    0  over >len 0 ?do
        over i swap get*    \ Bits present?
        if  1+  then        \ Add 1 when found
    loop  nip ;

\ Leave the number of the first used item in bit array a on the stack and erase it!
: UP?       ( a -- false | nr true )
    dup >len 0 ?do              \ Test all bits
        i over get* if          \ Bit set?
            i swap *clr         \ Yes clear bit
            i true unloop exit  \ Leave bit-nr & true, ready
        then
    loop  drop  false ;         \ Nothing found



\ An example:

40 bitarray BITMAP  \ Demo bit arrays
13 bitarray SIGNALS \ Note that this one is rounded to one cell (32 bits)
                    \ or two cells on a system with 16-bit cells.

BITMAP zero         \ Clear whole bit array
3 BITMAP *set       \ Set bit 3, 11, 24 & 33
11 BITMAP *set
1F BITMAP *set
24 BITMAP *set
33 BITMAP *set

3 BITMAP *clr       \ Clear bit 3
11 BITMAP get* .    \ Leave status of bit 11 & 3
3 BITMAP get* .

BITMAP SIGNALS copy \ Copy BITMAP to SIGNALS


: .BITARRAY ( a -- )    \ Show whole contents of bit array a
    cr  dup >len 0 do
        i 8 mod 0= if  cr  then
        i 2 .r space   i over get*
        if ." Set" else ." -- " then
        space space
    loop  drop ;

: SHOW      ( a -- )  \ Display the contents of bit array a & empty it
    dup count*
    ?dup 0= if drop ." bit array empty " exit then
    2 .r ."  bit flags set "  cr        \ Used, show how many bits
    dup .bitarray
    cr  ." Used bits "                  \ Show & consume only
    dup >len 0 do
        dup up? if  .  then             \ the bits set in array a
    loop  drop ;

\ End ;;;
