\ Filename: spi1-normalization.txt
\ Date: June 2021
\ For Mecrisp-Quintus by Matthias Koch.
\ https://sourceforge.net/projects/mecrisp/
\ Chip: Gigadevices GD32VF103, Board: Longan-Nano
\ Pinout: 48
\ Purpose: normalize special spi1 names to spi names (without 1)
\ Usage: see spi1-set-software-cs.fs

\ --------------------------------------------------------------------------
\ ---------------- code ----------------------------------------------------
\ --------------------------------------------------------------------------

: {spi      ( -- )     {spi1 ;
: spi}      ( -- )     spi1} ; 
: spi-i/o   ( n -- n ) spi1-i/o ;
: spi-in    ( -- n )   spi1-in ;
: spi-out   ( n -- )   spi1-out ; 
: spi-setup ( -- )     spi1-setup ;