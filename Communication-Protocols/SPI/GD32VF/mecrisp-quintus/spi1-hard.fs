\ Filename: spi1-hard.txt
\ Date: June 2021
\ For Mecrisp-Quintus by Matthias Koch.
\ https://sourceforge.net/projects/mecrisp/
\ Chip: Gigadevices GD32VF103, Board: Longan-Nano
\ Pinout: 48
\ Author: M.B.

\ The GD32VF103 comes with three built-in modules for SPI connections
\ This is for SPI1 module. It is only ment for master mode. Of corse the
\ module it self can run as slave or multi master.
\ It is wired as follow:

\ | Alternate function |      |
\ |--------------------+------|
\ | SPI 1              |      |
\ |--------------------+------|
\ | SPI1_NSS           | PB12 |
\ | SPI1_SCK           | PB13 |
\ | SPI1_MISO          | PB14 |
\ | SPI1_MOSI          | PB15 |
\ |--------------------+------|
\ 

\ Step 1: initialize the clock for this module.
\ Step 2: initialize the GPIO pins for this module.
\ Step 3: initialize the module itself.
\ 
\ All configurations are done by placing a bitmask into register spi1_ctl0.
\ The word spi1-configure is made for this.
\ The CS (SS) line. (CS=Chip select, sometimes also SS=Slave Select. The manual
\ NSS to indicate that it has a negative logig i.e. low means active.)
\ This line decides if the peripheral device is active or not.
\ That allows to use the clockline and MISO, MOSI lines for different
\ devices by just activating a separate CS line for every device (thus: BUS).
\ The module has a built-in CS line called NSS. The module can be configured
\ to use this line or not (SWNSSEN, SWNSS). So you're free to use every
\ other free gpio pin for that.
\ The words {SPI1, SPI1}, are defined in a way that one can configure them
\ to use either the built-in NSS line or to use an other chosen line. For
\ that purpose the words spi1-software-CS, (spi1-CS-hook), (spi1+CS-hook) 
\ were implemented. They allow to switch to a software CS line.
\ I've put an example with instructions for this in sp1-software-CS.fs
\ 
\ The words spi1+dma and spi1-dma allow to invoke the DMA features of
\ the hardware module.

\ --------------------------------------------------------------------------
\ ---------------- code ----------------------------------------------------
\ --------------------------------------------------------------------------


\ registers. Comment out if you have them already installed

$40003800       Constant SPI1_BASE
SPI1_BASE       Constant SPI1_CTL0
SPI1_BASE $04 + Constant SPI1_CTL1
SPI1_BASE $08 + Constant SPI1_STAT
SPI1_BASE $0c + Constant SPI1_DATA
AFIO_BASE $04 + Constant AFIO_PCF0

\ Bitmask of SPIx_CTL0

\  Xaaa.bbbb.cccc.dddd BDEN
\  aXaa.bbbb.cccc.dddd BDOEN
\  aaXa.bbbb.cccc.dddd CRCEN
\  aaaX.bbbb.cccc.dddd CRCNT

\  aaaa.Xbbb.cccc.dddd FF16
\  aaaa.bXbb.cccc.dddd RO
\  aaaa.bbXb.cccc.dddd SWNSSEN
\  aaaa.bbbX.cccc.dddd SWNSS

\  aaaa.bbbb.Xccc.dddd LF
\  aaaa.bbbb.cXcc.dddd SPIEN
\  aaaa.bbbb.ccXX.Xddd PSC
\  aaaa.bbbb.cccc.dXdd MSTMOD
\  aaaa.bbbb.cccc.ddXd CKPL
\  aaaa.bbbb.cccc.dddX CKPH

\ %0000.0011.0100.0111 drop SPI1_CTL0 ! \ clk/2
\ %0000.0011.0100.1111 drop SPI1_CTL0 ! \ clk/4 normfall
\ %0000.0011.0101.0111 drop SPI1_CTL0 ! \ clk/8
\ %0000.0011.0101.1111 drop SPI1_CTL0 ! \ clk/16
\ %0000.0011.0110.0111 drop SPI1_CTL0 ! \ clk/32
\ %0000.0011.0110.1111 drop SPI1_CTL0 ! \ clk/64
\ %0000.0011.0111.0111 drop SPI1_CTL0 ! \ clk/128
\ %0000.0011.0111.1111 drop SPI1_CTL0 ! \ clk/256   

%0000.0000.0100.1111 drop Constant spi1-default
%0000.0011.0100.1111 drop Constant spi1-sw-nss

: spi1-clock-init ( -- )      \ set clock and alternate function
  1 14 lshift RCU_APB1EN bis! \ enable SPI1 clock
  %1101 RCU_APB2EN bis!       \ clock Port A und B, Alternate function
;

: spi1-gpio-init ( -- ) \  15 (AF CS=NSS by hardware)
  ( B = AF output mode push-pull 50MHz )
  ( 7 = output mode push-pull 50MHz )
  ( 4 = floating input)
  $FFFF0000 GPIOB_CTL1  bic!  \ clear pins 12(CS), 13(SCLK), 14(MISO), 15(MOSI) 
  $B4BB0000 GPIOb_CTL1  bis!  \ set pins 12(CS), 13(SCLK), 14(MISO), 15(MOSI)
;

: spi1-disable ( -- )  \ to write to CTL0 spi must be enabled
  %1000000 SPI1_CTL0 bic!
;

: spi1-enable ( -- ) \ switch on spi
  %1000000 SPI1_CTL0 bis!
;

: spi1-config! ( mask -- ) \ write configuration mask to  CTL0
  spi1-disable \ make CTL0 register writeable
  SPI1_CTL0 !  \ store bitmask
  spi1-enable  \ enable spi1
;

: SPI1-conf-ok? ( -- f )
  %100000 SPI1_STAT bit@ 0= \ get conf_error flag \ Just to be shure
;

: spi1-transmit? ( -- f ) \ transmitbuffer ready/empty?
  %10 SPI1_STAT bit@  \ get TBE flag
; 

: spi1-receive? ( -- f ) \ recievebuffer ready/full?
  1 SPI1_STAT bit@ 0<>
;

: spi1-wait-idle ( -- flag ) \ is spi module idle?
  BEGIN
    spi1-transmit? spi1-receive? 0= and
  UNTIL
;

: spi1+dma ( -- ) \ switch on DMA feature
  spi1-wait-idle
  %10 SPI1_CTL1 bis!
;

: spi1-dma ( -- ) \ switch off DMA feature
  spi1-wait-idle
  %10 SPI1_CTL1 bic!
;

: spi1-i/o ( n -- n ) \ send out one byte while reading in one byte
  BEGIN spi1-transmit? UNTIL \ wait for tranmit to be ready
  spi1_data h!               \ send one byte        
  BEGIN spi1-receive? UNTIL  \ wait for receive to be ready
  spi1_data h@               \ read one byte
;

: spi1-in ( -- n ) 0 spi1-i/o ;

: spi1-out ( n -- ) spi1-i/o drop ;



: spi1-CS-software ( -- ) \ set CS managment to software
  %100 SPI1_CTL1 bic! ;

: spi1-CS-hardware ( -- ) \ set CS managment to hardware
  %100 SPI1_CTL1 bis! ;

: spi1-CS-hardware? ( -- flag ) \ is CS managemnet hardware?
  %100 SPI1_CTL1 bit@
;

' spi1-enable  Variable (spi1+CS-hook) \ variable to store cfa (hook)
' spi1-disable Variable (spi1-CS-hook) \ variable to store cfa (hook)

: spi1-soft-CS-set ( cfa cfa -- ) \ store two cfas into CS hook
  (spi1-CS-hook) ! \ hook for CS low
  (spi1+CS-hook) ! \ hook for CS high
;

: {spi1 ( -- ) \ invoke SPI module
  spi1-CS-hardware? \ CS hardware …    
  IF                \ if …             
    spi1-enable     \ use module CS    
  ELSE              \ … if not           
    (spi1+CS-hook) @ execute \ use hook
  THEN
;

: spi1} ( -- )
  spi1-CS-hardware? \ CS hardware …    
  IF                \ if …             
    spi1-disable    \ use module CS    
  ELSE              \ … if not         
    (spi1-CS-hook) @ execute \ use hook
  THEN
;
  
: spi1-setup ( -- ) \ set-up SPI1 module
  spi1-clock-init   \ clock tree
  spi1-gpio-init    \ GPIO pins
  spi1-default spi1-config! \ module
  spi1-CS-hardware  \ set to hardware CS
  spi1-dma          \ disable DMA
;

spi1-setup
 
