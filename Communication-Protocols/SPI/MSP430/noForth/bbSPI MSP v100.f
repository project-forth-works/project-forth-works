(* Bitbang SPI interface on P1 & P2 

P1.4  - CLK             10      \ Clock               x1=Clock
P2.0  - CS              01      \ SPI enable low      x1=Chip select
P2.1  - MISO            02      \ Data bitstream out  x0=Master in
P2.2  - MOSI            04      \ Data bitstream in   x1=Master out

  More SPI info on page 444ff of SLAU144J.PDF  
  Configuration of the pins on page 49ff of SLAS735J.PDF


*)

hex
v: fresh
: SPI-SETUP         ( -- )
    03 2A *bis      \ P2DIR  P2.0 & P2.1 for SPI Output
    02 2A *bic      \ P2DIR  P2.2  is Miso input master
    02 2F *bis      \ P2REN  P2.2 with pullup resistor
    02 29 *bis      \ P2OUT
    10 22 *bis      \ P1DIR  P1.4  CLK output
    01 29 *bis      \ P1OUT  P2.0   CS = 1
    10 21 *bic ;    \ P1OUT  P1.4  CLK = 0

\ Code version for SPI primitives
code READ-BIT   ( -- 0|1 )  tos sp -) mov  #0 tos mov  #2 28 & .b bia  
                            0<>? if,  #1 tos mov  then,  next  end-code
code WRITE-BIT  ( b -- )    tos day mov  sp )+ tos mov  80 # day bia  0<>?
                            if,  #4 29 & .b bis  else,  #4 29 & .b bic  then,
                            next  end-code
code CLOCK      ( -- )      10 # 21 & .b bis 0 # day add  10 # 21 & .b bic
                            next  end-code
code SPI}       ( -- )      #1 29 & .b bis  next  end-code
code {SPI)      ( -- )      #1 29 & .b bic  next  end-code

(* Write a bit to the SPI-bus, read abit from the SPI-bus

: WRITE-BIT     ( b -- )    80 and if 4 29 *bis else 4 29 *bic then ; \ P2OUT
: READ-BIT      ( -- 0|1 )  2 28 bit* 0<> 1 and ;           \ P2IN
: CLOCK         ( -- )      10 21 *bis  10 21 *bic ;        \ P1OUT  SPI clock
: SPI}          ( -- )      1 29 *bis ;                     \ P2OUT  SPI off, CS=high
: {SPI)         ( -- )      1 29 *bic ;                     \ P2OUT  SPI on, CS=low

*)

: SPI-OUT           ( b -- )            \ Write b to SPI-bus
    8 for   dup write-bit  2*  clock  next  drop ;

: SPI-IN            ( -- b )            \ Read b from SPI-bus
    0  8 for  2*  read-bit or  next ;

: SPI-I/O           ( b1 -- b2 )        \ Read and write at SPI-bus
    8 for
        dup write-bit  2*   read-bit or  clock
    next
    FF and ;

: {SPI          ( b -- )        {spi) spi-out ;

spi-setup
v: fresh  
shield spi\  freeze

\ End ;;;
