(* USART-0/1 SPI on P3 or P5 of MSP430F149

Function        P1    P2    P3    P4    P5    P6  Lable name
-------------------------------------------------------------
Input           20    28    18    1C    30    34    PxIN
Output          21    29    19    1D    31    35    PxOUT
Direction       22    2A    1A    1E    32    36    PxDIR
Intrpt flag     23    2B    1B    1F    --    --    PxIFG
Intrpt edge     24    2C    --    --    --    --    PxIES
Intrpt on/off   25    2D    --    --    --    --    PxIE
Select          26    2E    --    --    33    37    PxSEL
---------------------------------------------------------

P3.0/P5.0  - CS         01      \ SPI enable low      x1=Chip select
P3.1/P5.1  - MOSI       02      \ Data bitstream out  x0=Master in
P3.2/P5.2  - MISO       04      \ Data bitstream in   x1=Master out
P3.3/P5.3  - CLK        08      \ Clock               x1=Clock

  More SPI info on page 444ff of SLAU144J.PDF  
  Configuration of the pins on page 129ff of SLAU049.PDF

USART - Ucontrol - Tcontrol - Rcontrol - Mcontrol - B0 - B1 - RB - TB
----------------------------------------------------------------------
  0        70         71         72         73      74   75   76   77
  1        78         79         7A         7B      7C   7D   7E   7F

*)

                    ( UART-0/1 SPI interface )

hex  
v: fresh
: SPI}          ( -- )      1 31 *bis ;     \ P5OUT  SPI off CS=high
: {SPI          ( -- )      1 31 *bic ;     \ P5OUT  SPI on, CS=low

: SPI-ON        ( -- )
    0B 32 c!        \ P5DIR     Outputs P5.0, P5.2, P5.3 & P5.1 input
    0E 33 *bis      \ P5SEL     SPI out is P5.2, P5.3 & P5.1 input
    10 05 *bis      \ ME2       Enable SPI1
    1 78 *bis       \ UCTL21    Reset USART
    17 78 c!        \ UCTL1     SPI mode on, Master mode, 8 -bit wide
    32 79 *bis      \ UTCTL1    3-wire mode, SMCLK, Clk low, Normal
    4 7C c!         \ UBR10     Clock is 8Mhz/4 = 2MHz
    0 7D c!         \ UBR11  
    0 7B c!         \ UMCTL1    Not used must be zero!
    1 78 *bic       \ UCB1CTL1  Free USCI
    spi} ;          \           CS = 1

code SPI-I/O    ( b1 -- b2 )            \ Read and write at SPI-bus
    tos 7F & .b mov         \ UTXBUF1, write
    begin,  10 # 3 & .b bit \ IFG2.4
    cs? until,
    7E & tos .b mov         \ URXBUF1, read
    next
end-code

: SPI-OUT       ( b -- )    spi-i/o drop ;  \ Write b to SPI-bus
: SPI-IN        ( -- b )    0 spi-i/o ;     \ Read b from SPI

\ : TEST          ( -- )
\    spi-on  8 78 *bis  0    \ Activate SPI with internal feedback 
\    begin
\        spi-i/o  dup .      \ Send & receive, show result
\        1+  100 ms          \ Increase data & wait
\    key? until 
\    8 78 *bic ;             \ Remove internal feedback

spi-on
v: fresh  
shield spi\  freeze
