\ -------------- SPI Kommunikation -------------------------
\ This shows an example of SPI-comunication to a BME280 sensor chip.
\ Using the words from the simple-spi example doesnt't fit the needs of the BME280.
\ The BME280 expects bundles of Bytes to read or write via SPI. The begin and end
\ of such a bundle is signaled by setting the SS signal to low or high.
\ - Chipselect is low active. So {spi spi} are defined in opposit way.
\ - After a transmission of one bit to the BME280 one have to wait for
\   clocksignal go down before read a bit.
\
\ I've put all definitions in here. On most mecrisp systems it should run ot of the box.
\ If you heve the registernames defined in your systems comment them out here.
\ Don't forget to revoke spi-setup at start!


\ --------------------- wiring ---------------------------------



\ | Name (MCU side)     | Abrivation | Port Pin | BME280 Pin |
\ |---------------------+------------+----------+------------|
\ | Slave Select        | SS         | B8       |            |
\ | Master In Slave Out | MISO       | B5       |            |
\ | Master Out slave In | MOSI       | B6       |            |
\ | Serial Clock        | sclk       | B7       |            |
\ |---------------------+------------+----------+------------|

\ | BMP280 | Name    | SPI  | Port Pin |
\ |--------+---------+------+----------|
\ |      1 | gnd     |      | gnd      |
\ |      2 | nv      |      |          |
\ |      3 | vcc     |      | 3.3V     |
\ |      4 | scl/sck | SCLK | B7       |
\ |      5 | sda/sdi | MOSI | B6       |
\ |      6 | sdo     | MISO | B5       |
\ |      7 | cs      | SS   | B8       |




$40010C00 constant GPIOB_Base
GPIOB_BASE $00 + constant GPIOB_CTL0  \ Reset $44444444 Control Register for pins 0 to 7
GPIOB_BASE $04 + constant GPIOB_CTL1  \ Reset $44444444 Control Register for pins 15 to 8
GPIOB_BASE $08 + constant GPIOB_ISTAT \ RO      Input Status Register
GPIOB_BASE $0C + constant GPIOB_OCTL  \ Reset 0 Output Control Register
GPIOB_BASE $10 + constant GPIOB_BOP   \ WO      Bit set/reset register 31:16 Reset 15:0 Set
GPIOB_BASE $14 + constant GPIOB_BC    \ WO      Bit reset register 15:0 Reset


hex
: spi-setup ( -- ) \ PB4, PB6 & PB7 are outputs, PB5 is input
  ( output mode push-pull 50MHz )
    $FF0F0000 GPIOB_CTL0  bic! \ clear pins 4, 6 und 7
    $33030000 GPIOB_CTL0  bis! \ set pins 4, 6 und 7
    $0000000F GPIOB_CTL1  bic! \ clear pin 8
    $00000003 GPIOB_CTL1  bis! \ set pin 8
  ( input mode floating )
    $00F00000 GPIOB_CTL0  bic! \ clear pin 5
    $00400000 GPIOB_CTL0  bis! \ set pin 5

    %10000000 GPIOB_BOP bis!   \ start with clock high     
;


: CLOCK     ( -- )  
  %10000000 GPIOB_BC bis!    \ and low again
  %10000000 GPIOB_BOP bis!   \ Generate rising clock pulse

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
    1 and  or                    \ Convert flag to 1 or 0 & add to b1
;

: SPI-I/O   ( b1 -- b2 )
  8 0 do                \ Output 8-bits in a loop
    dup write-bit  2*   \ Send & shift byte left
    clock read-bit      \ !!!
  loop
  $FF and               \ Leave only received byte
;

: SPI-OUT       ( b -- )    spi-i/o drop ;
: SPI-IN        ( -- b )    0 spi-i/o ;

: {SPI          ( -- )      1 8 lshift GPIOB_BC bis! ; \ Enable device
: SPI}          ( -- )      1 8 lshift GPIOB_BOP bis! ; \ Disable device

spi-setup
