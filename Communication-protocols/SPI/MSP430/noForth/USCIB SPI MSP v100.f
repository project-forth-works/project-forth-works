(* USCI-B SPI on P1 of MSP430G2553

020 = P1IN      - Input register
021 = P1OUT     - Output register
022 = P1DIR     - Direction register
026 = P1SEL     - Configuration register 1
027 = P1REN     - Resistance on/off
041 = P1SEL2    - Configuration register 2

P1 is used for interfacing the SPI
P1.4  - CS                      \ SPI enable low      x1=Select
P1.5  - CLOCKPULSE              \ Clock               x1=Clock
P1.6  - MISO                    \ Data bitstream in   x0=Miso
P1.7  - MOSI                    \ Data bitstream out  x1=Mosi

  More SPI info on page 444ff of SLAU144J.PDF  
  Configuration of the pins on page 49ff of SLAS735J.PDF

*)

                    ( USCI-B SPI interface )

hex
v: fresh
: B0-SPI-SETUP  ( -- )
    1 69 *bis       \ UCB0CTL1  Reset USCI
    F0 22 c!        \ P1DIR     P1.4, P1.5, P1.6 and P1.7 output
    E0 26 *bis      \ P1SEL     P1.5 P1.6 P1.7 is SPI
    E0 41 *bis      \ P1SEL2
    A9 68 *bis      \ UCB0CTL0  Clk=low, MSB first, Master, Synchroon
    80 69 *bis      \ UCB0CTL1  USCI clock = SMClk
    4 6A c!         \ UCB0BR0   Clock is 8Mhz/4 = 2MHz
    0 6B c!         \ UCB0BR1
    0 6C c!         \ UCB0MCTL  Not used must be zero!
    1 69 *bic       \ UCB0CTL1  Free USCI
    10 21 *bis ;    \ P1OUT     CS = 1

code SPI-I/O    ( b1 -- b2 )            \ Read and write at SPI-bus
    B2F2 , 03 ,         \ begin,  #8 03 & .b bit \ IFG2
    2BFD ,              \ cs? until,
    47C2 , 6F ,         \ tos  6F & .b mov \ UCB0TXBUF
    B2E2 , 03 ,         \ begin,  #4 03 & .b bit \ IFG2
    2BFD ,              \ cs? until,
    4257 , 6E ,         \ 6E &  tos .b mov \ UCB0RXBUF
    next                \ next
end-code

: SPI-OUT       ( b -- )    spi-i/o drop ;  \ Write b to SPI-bus
: SPI-IN        ( -- b )    0 spi-i/o ;     \ Read b from SPI
: SPI}          ( -- )      10 21 *bis ;    \ P1OUT  SPI off CS=high
: {SPI)         ( -- )      10 21 *bic ;    \ P1OUT  SPI on, CS=low
: {SPI          ( b -- )    {spi) spi-out ;

spi-setup
v: fresh  
shield spi\  freeze
