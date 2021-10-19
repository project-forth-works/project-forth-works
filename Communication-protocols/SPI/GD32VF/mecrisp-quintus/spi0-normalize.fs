\ Filename: spi0-normalization.txt
\ Date: June 2021
\ For Mecrisp-Quintus by Matthias Koch.
\ https://sourceforge.net/projects/mecrisp/
\ Chip: Gigadevices GD32VF103, Board: Longan-Nano
\ Pinout: 48
\ Purpose: normalize special spi0 names to spi names (without 1)
\ Usage: switch software-CS: see spi1-set-software-cs.fs
\        Remap SPI0:         use the right version of spi-setup 

\ --------------------------------------------------------------------------
\ ---------------- code ----------------------------------------------------
\ --------------------------------------------------------------------------

: {spi      ( -- )     {spi0 ;
: spi}      ( -- )     spi0} ; 
: spi-i/o   ( n -- n ) spi0-i/o ;
: spi-in    ( -- n )   spi0-in ;
: spi-out   ( n -- )   spi0-out ; 
\ : spi-setup ( -- )     spi0-setup unmap ; \ default version
: spi-setup ( -- ) spi0-setup spi0-remap ; \ remapped version 

