(* USCI-A SPI on P2 of MSP430FR59x9

        IN   OUT  DIR  REN  SEL0 SEL1
P1      200  202  204  206  20A  20C
P2      201  203  205  207  20B  20D
P3      220  222  224  226  22A  22C
P4      221  223  225  227  22B  22D
PJ      320  322  324  326  32A  32C

      UCxyCTLW  UCxyBRW  UCx0ySTAT UCxyIFG  UCxyTXBUF  UCxyRXBUF
UCA0    5C0       5C6      5C8      5DC      5CE        5CC
UCA1    5E0       5E6      5E8      5FC      5EE        5EC
UCB0    640       646      648      66C      64E        64C

P2 is used for interfacing the SPI with eUSCI-A1
P2.3  - CS                      \ SPI enable low      x1=Select
P2.4  - CLOCKPULSE              \ Clock               x1=Clock
P2.5  - MOSI                    \ Data bitstream out  x1=Mosi
P2.6  - MISO                    \ Data bitstream in   x0=Miso

  More SPI info on page 794ff of SLAU367O.PDF  
  Configuration of the pins on page 94ff of SLAS704G.PDF

*)

                    ( eUSCI-A1 SPI interface )

hex
: SPI-ON        ( -- )
    01 5E0 **bis    \ UCA1CTLW  Reset eUSCI
    08 205 *bis     \ P2DIR     P2.3 is CS output
    70 20B *bic     \ P2SEL0    P2.4 P2.5 P2.6 is SPI
    70 20D *bis     \ P2SEL1    3-wire SPI on
    A981 5E0 !      \ UCA1CTLW  Clk=low, MSB first, Master, Synch, 3-wire, SMClk
    08 5E6 !        \ UCA1BRW   Clock is 16Mhz/4 = 2 MHz
    01 5E0 **bic    \ UCA1CTLW  Free eUSCI
    08 203 *bis ;   \ PJOUT     CS high

code SPI-I/O    ( b1 -- b2 )            \ Read and write at SPI-bus
    tos 5EE & .b mov        \ UCA1TXBUF
    begin,  #2 5FC & bit    \ UCA1IFG
    cs? until,
    begin,  #1 5FC & bit    \ UCA1IFG
    cs? until,
    5EC & tos .b mov  next  \ UCA1RXBUF
    next
end-code

: SPI-OUT       ( b -- )    spi-i/o drop ;  \ Write b to SPI-bus
: SPI-IN        ( -- b )    0 spi-i/o ;     \ Read b from SPI
: SPI}          ( -- )      8 203 *bis ;    \ P2OUT  SPI off CS=high
: {SPI          ( -- )      8 203 *bic ;    \ P2OUT  SPI on, CS=low

spi-on  
shield spi\  freeze
