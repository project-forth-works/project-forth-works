\ BME280 example
\
\ Datasheet: 
\ Don't forget to revoke spi-setup at start!
\ If your examing the raw spi datas, be aware that in case of 'answers' you have
\ to set the MSB to null .i.e. $70 (spi answer) becomes $60 (answer byte from BME280).
\
\ The measurements are all raw data. To get the real values one has to do some
\ complex calculations. For these calculations calibrations dates are needed
\ you find them in the constants T1…T3, P1…P9 and H1…H6.

\ --------------------- wiring ---------------------------------

\ | BMP280 | Name    | SPI  | Port Pin |
\ |--------+---------+------+----------|
\ |      1 | gnd     |      | gnd      |
\ |      2 | nv      |      |          |
\ |      3 | vcc     |      | 3.3V     |
\ |      4 | scl/sck | SCLK | B7       |
\ |      5 | sda/sdi | MOSI | B6       |
\ |      6 | sdo     | MISO | B5       |
\ |      7 | cs      | SS   | B8       |


spi-setup

: bme-read ( n -- n ) $80 or ;
: bme-write ( n -- n) $7f and ;

: bme-b! ( n n -- ) \ value reg 
   bme-write  
   {spi spi-out spi-out spi} ;

: bme-burst-read ( reg n -- ) \ reads n registers starting at reg
  {spi
  swap bme-read spi-out 
  0 DO spi-in LOOP
  spi}
;

: BME-ID. ( -- )
  $d0 1 bme-burst-read .
;

: bme-reset ( -- )
  $B6 $e0 bme-b!
;

\ set BME to normal mode; rates = 1 

: rate-1-1-1-normal ( -- )
  1 $f2 bme-b!  \ humidity oversampling = 1
  %00100111     \ temperature and pressure oversampling = 1
  $f4 bme-b!
;


\ ------------------------------------------------------------
\ ------- BME read values words ------------------------------
\ ------------------------------------------------------------

\ with rates set to one, the values for temperature and pressure are 16bit wide


: @press ( -- n )  \ read out two of three registers  
  $F7 2 bme-burst-read 
  swap 8 lshift or ;

: @hum ( -- n ) \ read out two of three registers  
  $FD 2 bme-burst-read 
  swap 8 lshift or ;

: @temp ( -- n ) \ read out two of three registers  
  $FA 2 bme-burst-read 
  swap 8 lshift or ;

: @tp ( -- t p ) \ read out six registers, use 4 registers  
  $F7 6 bme-burst-read
  drop swap 8 lshift or >r
  drop swap 8 lshift or r> ; 



\ ------------------------------------------------------------
\ ----- init BME ---------------------------------------------
\ ------------------------------------------------------------

:  init-bme ( -- ) \ init BME to highest speed, lowest resolution  
   spi-setup
   rate-1-1-1-normal \ see: BST-BME280-DS002.pdf p28
;


init-bme

\ calibration values for temperature und pressure are in consecutive registers

: get_calibration_datas ( -- )
   12 0 DO
     I 2 * $88 + 2 bme-burst-read
     u. \ 8 lshift or
     u. \ ,
   LOOP ;

\ Create calibration_data get_calibration_datas     

\ Solange wir noch keinen Heap haben, eben handcoded

: w@reg 2 bme-burst-read 8 lshift or <builds , does> @ ;



  $88 w@reg T1
  $8a w@reg T2
  $8c w@reg T3

  $8e w@reg P1
  $90 w@reg P2
  $92 w@reg P3
  $94 w@reg P4
  $96 w@reg P5
  $98 w@reg P6
  $9a w@reg P7
  $9c w@reg P8
  $9e w@reg P9

  $a1 1 bme-burst-read              Constant H1
  $e1 w@reg                         H2
  $e3 1 bme-burst-read              Constant H3
  $e4 1 bme-burst-read 4 lshift
  $e5 1 bme-burst-read %1111 and or Constant H4
  $e5 1 bme-burst-read 4 rshift \ … 
  $e6 1 bme-burst-read 4 lshift or  Constant H5
  $e7 1 bme-burst-read              Constant H6

