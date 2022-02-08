(* Bitbang SPI interface on P2 

        IN   OUT  DIR  REN  SEL0 SEL1
P1      200  202  204  206  20A  20C
P2      201  203  205  207  20B  20D
P3      220  222  224  226  22A  22C
P4      221  223  225  227  22B  22D
PJ      320  322  324  326  32A  32C

P2 is used for interfacing the SPI with eUSCI-A1
P2.3  - CS                      \ SPI enable low      x1=Select
P2.4  - CLOCKPULSE              \ Clock               x1=Clock
P2.5  - MOSI                    \ Data bitstream out  x1=Mosi
P2.6  - MISO                    \ Data bitstream in   x0=Miso

  More SPI info on page 444ff of SLAU144J.PDF  
  Configuration of the pins on page 49ff of SLAS735J.PDF

*)

hex
v: fresh
: SPI-ON        ( -- )
    70 20B *bic     \ P2SEL0    P2.4 P2.5 P2.6 are I/O
    70 20D *bic     \ P2SEL1    3-wire SPI off!
    38 205 *bis     \ P2DIR  P2.3 to P2.5 are SPI Output
    40 205 *bic     \ P2DIR  P2.6  is Miso input master
    40 207 *bis     \ P2REN  P2.6 with pullup resistor
    40 203 *bis     \ P2OUT
     8 203 *bis     \ P2OUT  P2.3   CS = 1
    10 203 *bic ;   \ P2OUT  P2.4  CLK = 0

\ Code version for SPI primitives
code READ-BIT   ( -- 0|1 )  tos sp -) mov  #0 tos mov  40 # 201 & .b bia
                            0<>? if,  #1 tos mov  then,  next  end-code
code WRITE-BIT  ( b -- )    tos day mov  sp )+ tos mov  80 # day bia  0<>?
                            if,  20 # 203 & .b bis
                            else,  20 # 203 & .b bic  then,
                            next  end-code
code CLOCK-HI   ( -- )      10 # 203 & .b bis  next  end-code
code CLOCK-LOW  ( -- )      10 # 203 & .b bic  next  end-code
code SPI}       ( -- )      #8 203 & .b bis  next  end-code
code {SPI       ( -- )      #8 203 & .b bic  next  end-code

(* Write a bit to the SPI-bus, read abit from the SPI-bus

: WRITE-BIT     ( b -- )    80 and if 20 203 *bis else 20 203 *bic then ; \ P2OUT
: READ-BIT      ( -- 0|1 )  40 201 bit* 0<> 1 and ; \ P2IN
: CLOCK-HI      ( -- )      10 203 *bis ;           \ P2OUT  SPI clock
: CLOCK-LOW     ( -- )      10 203 *bic ;           \ P2OUT  SPI clock
: CLOCK         ( -- )      clock-hi  clock-low ;
: SPI}          ( -- )      8 203 *bis ;            \ P2OUT  SPI off, CS=high
: {SPI          ( -- )      8 203 *bic ;            \ P2OUT  SPI on, CS=low

*)
: CLOCK         ( -- )      clock-hi clock-low ;

: SPI-OUT           ( b -- )            \ Write b to SPI-bus
    8 for   dup write-bit  2*  clock  next  drop ;

: SPI-IN            ( -- b )            \ Read b from SPI-bus
    0  8 for  2*  clock-hi  read-bit or  clock-low  next ;

: SPI-I/O           ( b1 -- b2 )        \ Read and write at SPI-bus
    8 for
        dup write-bit  2*   clock-hi
        read-bit or  clock-low
    next
    FF and ;

spi-on
v: fresh  
shield spi\  freeze

\ End ;;;
