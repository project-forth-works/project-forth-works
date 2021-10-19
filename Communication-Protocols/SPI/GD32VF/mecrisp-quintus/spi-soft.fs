\ ------------------ wireing -----------------------------------

\ | Name                | Abrivation | Port Pin | Direction |
\ |---------------------+------------+----------+-----------|
\ | Slave Select        | SS         | B8       | output    |
\ | Master In Slave Out | MISO       | B5       | input     |
\ | Master Out slave In | MOSI       | B6       | output    |
\ | Serial Clock        | SCLK       | B7       | output    |
\ |---------------------+------------+----------+-----------|

\ -------------------- register constants ----------------------


$40010C00 
constant GPIOB_Base
GPIOB_BASE $00 + constant GPIOB_CTL0  \ Reset $44444444 Control Register for pins 0 to 7
GPIOB_BASE $04 + constant GPIOB_CTL1  \ Reset $44444444 Control Register for pins 15 to 8
GPIOB_BASE $08 + constant GPIOB_ISTAT \ RO      Input Status Register
GPIOB_BASE $0C + constant GPIOB_OCTL  \ Reset 0 Output Control Register
GPIOB_BASE $10 + constant GPIOB_BOP   \ WO      Bit set/reset register 31:16 Reset 15:0 Set
GPIOB_BASE $14 + constant GPIOB_BC    \ WO      Bit reset register 15:0 Reset

\ ------------- code -------------------------------------------

: spi-setup ( -- ) \ PB4, PB6 & PB7 are outputs, PB8 is input


  ( output mode push-pull 50MHz )
    $FF0F0000 GPIOB_CTL0  bic! \ clear pins 4, 6 und 7
    $33030000 GPIOB_CTL0  bis! \ set pins 4, 6 und 7
    $0000000F GPIOB_CTL1  bic! \ clear pin 8
    $00000003 GPIOB_CTL1  bis! \ set pin 8

    ( input mode floating )
    $00F00000 GPIOB_CTL0  bic! \ clear pin 5
    $00400000 GPIOB_CTL0  bis! \ set pin 5

    %10000000 GPIOB_BC bis!   \ start with clock low     
;

\ -------------- SPI Kommunikation -------------------------

: CLOCK     ( -- )  
  %10000000 GPIOB_BOP bis!   \ Generate rising clock pulse
  %10000000 GPIOB_BC bis!    \ and low again
;

: WRITE-BIT ( b -- )
    80 and if           \ Test if bit-7 high?
      %01000000 GPIOB_BOP bis! \ Yes, write a high bit
    else
       %01000000 GPIOB_BC bis!    \ No, write a low bit
    then
  ;


: READ-BIT  ( b1 -- b2 )
    $20  GPIOB_ISTAT bit@ 0= 0=  \ Read & convert bit-6 to flag
    1 and  or           \ Convert flag to 1 or 0 & add to b1
;

: SPI-I/O   ( b1 -- b2 )
  8 0 do                \ Output 8-bits in a loop
    dup write-bit  2*   \ Send & shift byte left
    read-bit clock
  loop 
  $FF and               \ Leave only received byte
;
: SPI-OUT       ( b -- )    spi-i/o drop ;
: SPI-IN        ( -- b )    0 spi-i/o ;

: {SPI          ( -- )      1 8 lshift GPIOB_BOP bis! ; \ Enable device
: SPI}          ( -- )      1 8 lshift GPIOB_BC bis! ;  \ Disable device

spi-setup
