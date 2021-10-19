\ Filename: spi1-set-software-CS.fs
\ Date: June 2021
\ For Mecrisp-Quintus by Matthias Koch.
\ https://sourceforge.net/projects/mecrisp/
\ Chip: Gigadevices GD32VF103, Board: Longan-Nano
\ Pinout: 48
\ Example how to use GPIOB pin 5 as CS line within SPI1 hardware
\ module. Aimed device is BME280. See BME280.fs

\ Usage:
\ Step 1: load spi1-hard.txt to invoke the SPI1 hardware module
\ Step 2: load this file to overwrite also spi-setup-routine
\ Step 3: laod noramlisation.fs to translate SPI1 name to SPI names
\ Step 4: load BME280.fs as testcase and example.


\ --------------------------------------------------------------------------
\ ---------------- code ----------------------------------------------------
\ --------------------------------------------------------------------------

\ Teh software CS uses GPIOB-P5
: cs-high ( -- ) 1 5 lshift GPIOB_BOP bis! ;
: cs-low  ( -- ) 1 5 lshift GPIOB_BC  bis! ;

\ set CS-hook

: spi1-setup ( -- )         \ overwrite 'old' setup          
  spi1-setup                \ call origin setup
  spi1-sw-nss spi1-config!  \ config software CS
  ['] cs-low  ['] cs-high   \ two cfas of software CS
  spi1-soft-CS-set          \ hook in sw routines
  $00F00000 GPIOB_CTL0 bic! \ setup GPIOB for pin B5
  $00700000 GPIOB_CTL0 bis! \ 7 = output 50 MHZ
  spi1-CS-software          \ set spi1 to software-CS
;
