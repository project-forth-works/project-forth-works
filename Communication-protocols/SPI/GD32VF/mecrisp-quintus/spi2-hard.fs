\ Filename: spi1-hard.txt
\ Date: June 2021
\ For Mecrisp-Quintus by Matthias Koch.
\ https://sourceforge.net/projects/mecrisp/
\ Chip: Gigadevices GD32VF103, Board: Longan-Nano
\ Pinout: 48
\ Author: M.B.


\ The GD32VF103 comes with three built-in modules for SPI connections
\ This is for SPI2 module. It is only ment for master mode. Of corse the
\ module it self can run as slave or multi master.
\ It is wired as follow:


\ | Alternate function | SPI2_REMAP = 0 | SPI2_REMAP = 1 |
\ |--------------------+----------------+----------------|
\ | SPI2_NSS           | PA15 JTDI      | PA4 --         |
\ | SPI2_SCK           | PB3  JTDO      | --             |
\ | SPI2_MISO          | PB4  NJTRST    | --             |
\ | SPI2_MOSI          | PB5  --        | --             |
\ |                    |                |                |
\ |--------------------+----------------+----------------|


\ Step 1: initialize the clock for this module.
\ Step 2: initialize the GPIO pins for this module.
\ Step 3: initialize the module itself.
\
\ This module (SPI2) uses GPIOB4, GPIOB3, GPIOB5, GPIOA15. some of thise pins
\ are set to JTAG debug interface after boot. To use them with the SPI2 module
\ they must be released.
\ All configurations are done by placing a bitmask into register SPI2_CTL0.
\ The word spi1-configure is made for this.
\ The CS (SS) line. (CS=Chip select, sometimes also SS=Slave Select. The manual
\ uses NSS to indicate that it has a negative logig i.e. low means active.)
\ This line decides if the peripheral device is active or not.
\ That allows to use the clockline and MISO, MOSI lines for different
\ devices by just activating a separate CS line for every device (thus: BUS).
\ The module has a built-in CS line called NSS. The module can be configured
\ to use this line or not (SWNSSEN, SWNSS). So you're free to use every
\ other free gpio pin for that.
\ I've put an example with instructions for this in sp1-software-CS.fs
\ Also in spi1-hard.fs there is shown how to eable DMA use with SPIx.

\ --------------------------------------------------------------------------
\ ---------------- code ----------------------------------------------------
\ --------------------------------------------------------------------------

\ registers. comment out if you have them already installed

$40003C00       Constant SPI2_BASE
SPI2_BASE       Constant SPI2_CTL0
SPI2_BASE $04 + Constant SPI2_CTL1
SPI2_BASE $08 + Constant SPI2_STAT
SPI2_BASE $0c + Constant SPI2_DATA
AFIO_BASE $04 + Constant AFIO_PCF0


\  Bitmask of SPIx_CTL0
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

\ %0010.0011.0100.0111 drop SPI2_CTL0 ! \ clk/2
\ %0010.0011.0100.1111 drop SPI2_CTL0 ! \ clk/4 normfall
\ %0010.0011.0101.0111 drop SPI2_CTL0 ! \ clk/8
\ %0010.0011.0101.1111 drop SPI2_CTL0 ! \ clk/16
\ %0010.0011.0110.0111 drop SPI2_CTL0 ! \ clk/32
\ %0010.0011.0110.1111 drop SPI2_CTL0 ! \ clk/64
\ %0010.0011.0111.0111 drop SPI2_CTL0 ! \ clk/128
\ %0010.0011.0111.1111 drop SPI2_CTL0 ! \ clk/256   

%0000.0000.0100.1111 drop Constant spi2-default
%0000.0011.0100.1111 drop Constant spi2-sw-nss


: spi2-clock-init ( -- )             \ set clock and alternate function
  1 15 lshift RCU_APB1EN bis! \ enable SPI2 clock
  %1101 RCU_APB2EN bis!       \ clock Port A und B, Alternate function
;

: spi2-gpio-init ( -- )
  ( B = AF output mode push-pull 50MHz )
  ( 7 = output mode push-pull 50MHz )
  ( 4 = floating input)
  $00FFF000 GPIOB_CTL0  bic!  \ clear pins 3(SCLK), 4(MISO), 5(MOSI) 
  $00B4B000 GPIOB_CTL0  bis!  \ set   pins 3,4, 5 
  $F0000000 GPIOA_CTL1  bic!  \ clear pin 15(CS)
  $B0000000 GPIOA_CTL1  bis!  \ set pin 15 (AF CS=NSS by hardware)
  7 24 lshift AFIO_PCF0 bic!  \ clear jtag pin wich is on after boot
  4 24 lshift AFIO_PCF0 bis!  \ disable jtag pins (typo at p119 see p107)
;

: spi2-disable ( -- )  \ to write to CTL0 spi must be enabled
  %1000000 SPI2_CTL0 bic!
;

: spi2-enable ( -- ) \ switch on spi
  %1000000 SPI2_CTL0 bis!
;

: spi2-config! ( mask -- ) \ write configuration mask to  CTL0
  spi2-disable \ make CTL0 register writeable
  SPI2_CTL0 !  \ store bitmask
  spi2-enable  \ enable spi2
;


: SPI2-conf-ok? ( -- f )
  %100000 SPI2_STAT bit@ 0= \ get conf_error flag \ Just to be shure
;

: spi2-transmit? ( -- f ) \ transmitbuffer ready/empty?
  %10 SPI2_STAT bit@  \ get TBE flag
; 

: spi2-receive? ( -- f ) \ recievebuffer ready/full?
  1 SPI2_STAT bit@ 0<>
;

: {spi2 ( -- ) %1000000 SPI2_CTL0 bis! ;  \ in NSS hardware mode 
: spi2} ( -- ) %1000000 SPI2_CTL0 bic! ;  \ in NSS hardware


: SPI2-I/O ( n -- n )
  BEGIN spi2-transmit? UNTIL 
  SPI2_data h!
  BEGIN spi2-receive? UNTIL
  SPI2_data h@ 
;

: spi2-out ( n -- ) SPI2-I/O drop ;
: spi2-in  ( -- n ) 0 SPI2-I/O ; 
  
: spi2-setup ( -- ) \ set-up SPI1 module
  spi2-clock-init           \ clock tree
  spi2-gpio-init            \ GPIO pins
  spi2-default spi2-config! \ module
  %100 SPI2_CTL1 bis!       \ set to hardware CS
;

spi2-setup

\ wiring the BME280

| Signal | BME280 | SPI2      |      |
|        |   Pins |           |      |
| gnd    |      1 |           |      |
| nc     |      2 |           |      |
| 3v3    |      3 |           |      |
| SCLK   |      4 | GD_PB3    | JTDO |
| MOSI   |      5 | GD_PB5    |      |
| MISO   |      6 | GD_PB4    |      |
| CS     |      7 | GD_PA15/4 | JTDI |

\ »--- STOPPER -------------------------------------------------«

\ testing the lines -  useful to prove the wiring
\ don't forget to call spi-setup after these tests
: treset ( -- )  \ reset to 'normal' IO
  $F0F000 gpiob_ctl0 bic! $F0000000 gpioa_ctl1 bic!
  $303000 gpiob_ctl0 bis! $30000000 gpioa_ctl1 bis!
;        
: tclock ( -- ) begin 8 gpiob_bc bis! 8 gpiob_bop bis! key? until ;         \ pb3 jtdo 
: tSS    ( -- ) begin $8000 gpioa_bc bis! $8000 gpioa_bop bis! key? until ; \ pa15 jtdi
: tmosi  ( -- ) begin $20 gpiob_bc bis! $20 gpiob_bop bis! key? until ;     \ pb5
: spi.
  cr ." SPI2_CTL0: " SPI2_CTL0 dup hex. @ dup hex. bin. 
  cr ." SPI2_CTL1: " SPI2_CTL1 dup hex. @ dup hex. bin. 
  cr ." SPI2_STAT: " SPI2_STAT dup hex. @ dup hex. bin. 
  cr ." SPI2_DATA: " SPI2_DATA dup hex. @ dup hex. bin.
;

\ »--- STOPPER -------------------------------------------------«
