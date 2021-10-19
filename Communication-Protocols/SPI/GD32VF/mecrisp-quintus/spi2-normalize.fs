\ Filename: spi2-normalization.txt
\ Date: June 2021
\ For Mecrisp-Quintus by Matthias Koch.
\ https://sourceforge.net/projects/mecrisp/
\ Chip: Gigadevices GD32VF103, Board: Longan-Nano
\ Pinout: 48
\ Purpose: normalize special spi2 names to spi names (without 1)
\ Usage: see spi2-set-software-cs.fs

\ --------------------------------------------------------------------------
\ ---------------- code ----------------------------------------------------
\ --------------------------------------------------------------------------

: {spi      ( -- )     {spi2 ;
: spi}      ( -- )     spi2} ; 
: spi-i/o   ( n -- n ) spi2-i/o ;
: spi-in    ( -- n )   spi2-in ;
: spi-out   ( n -- )   spi2-out ; 
: spi-setup ( -- )     spi2-setup ;