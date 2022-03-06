(* Bitbang SPI interface on P3 or P5 of MSP430F149

Function        P1    P2    P3    P4    P5    P6  Lable name
-------------------------------------------------------------
Input           20    28    18    1C    30    34    PxIN
Output          21    29    19    1D    31    35    PxOUT
Direction       22    2A    1A    1E    32    36    PxDIR
Intrpt flag     23    2B    1B    1F    33    37    PxIFG
Intrpt edge     24    2C    --    --    --    --    PxIES
Intrpt on/off   25    2D    --    --    --    --    PxIE
Select          26    2E    --    --    --    --    PxSEL
---------------------------------------------------------

P3.0/P5.0  - CS         01      \ SPI enable low      x1=Chip select
P3.1/P5.1  - MOSI       02      \ Data bitstream out  x0=Master in
P3.2/P5.2  - MISO       04      \ Data bitstream in   x1=Master out
P3.3/P5.3  - CLK        08      \ Clock               x1=Clock

  Configuration of the pins on page 129ff of SLAU049.PDF

*)

hex
v: fresh
(* Write & read a bit to/from the SPI-bus

: SPI}          ( -- )       1 31 *bis ;             \ P5OUT  SPI off, CS=high
: {SPI          ( -- )       1 31 *bic ;             \ P5OUT  SPI on, CS=low

: READ-BIT      ( b -- b )   4 30 bit* 0<> 1 or ;   \ P5IN
: WRITE-BIT     ( b -- b )   dup 80 and if 2 31 *bis else 2 31 *bic then ; \ P5OUT

: SPI-OUT           ( b -- )            \ Write b to SPI-bus
    8 for   write-bit  8 31 *bis 8 31 *bic  next  drop ; \ P5OUT

: SPI-IN            ( -- b )            \ Read b from SPI-bus
    FF  8 for  2*  8 31 *bis  read-bit  8 31 *bic  next ; \ P5OUT

: SPI-I/O           ( b1 -- b2 )        \ Read and write at SPI-bus
    8 for  write-bit  8 31 *bis  read-bit  8 31 *bic  next  FF and ; \ P5OUT
*)

code SPI}       ( -- )      #1 31 & .b bis  next  end-code \ P5OUT
code {SPI       ( -- )      #1 31 & .b bic  next  end-code \ P5OUT

: SPI-ON        ( -- )
    0B 32 *bis      \ P5DIR  P5.0 to P5.3 for SPI Output
    4 32 *bic       \ P5DIR  P5.2  is Miso input master
    8 31 *bic       \ P5OUT  P5.3  CLK = 0
    spi} ;          \        CS = 1

\ 330 kHz SPI-clock code version for SPI primitives
code SPI-I/O    ( b0 -- b1 ) 
    #8 day mov
    begin,
        80 # tos bit  cs? if,       \           Check Bit-7
            #2 31 & .b bis          \ P5OUT     High,
        else,
            #2 31 & .b bic          \ P5OUT     Low
        then,
        tos tos add  #8 31 & .b bis \ P5OUT     Shift b0 left, clock high
        #4 30 & .b bit  #0 tos addc \ P5IN      Read bit, add to b0
        #8 31 & .b bic              \ P5OUT     Clock low
        #-1 day add
    0=? until,
    #-1 tos .b bia  next            \           Result is b1, the low 8-bits
end-code

: SPI-OUT           ( b -- )    spi-i/o drop ;  \ Write b to SPI-bus
: SPI-IN            ( -- b )    FF spi-i/o ;    \ Read b from SPI-bus

spi-on
v: fresh  
shield spi\  freeze

\ End ;;;
