\ this code code based on work by Howerd Oakford, who based his code on work by Petrus Prawirodidjojo and Wil Baden
\ this verion (c) Jeroen Hoekstra 2022
\ open-sourced according to default "Project Forth Works" licensing (ie MIT)

\ this code implements the 32bit IEEE CRC ( ie with 04C11DB7 as polynomial )
\ only uses core ANI forth definitions

\ The shortest run-time for the standard crc test is 415 cycles on a Raspberry 3b+
\ the default routine takes 1238 cycles -> the table-based routine is around 3* faster
\ at the cost of 1024 bytes for the table

hex

EDB88320 constant CRCpolynomial \ =bit-reversed 04C11DB7

\ construct the table - 256 4-byte entries  *********************
: (CRC32TBL)   ( c - u)         \ for a given byte-value c create a corresponding table-value
   8 0 do
      dup 1 and if
         1 rshift
         CRCpolynomial xor
      else
         1 rshift
      then
   loop
;
: FILLCRCTABLE
    100 0 do i (crc32tbl) , loop
;

create CRCTABLE fillcrctable    \ this creates and fills the actual table


\ create a 32bit CRC for a byte-array  **************************
\ Add byte c to previous CRC
: (CRC32)                       \ ( crc c - crc_new )
    over                        \ crc c crc
    xor                         \ crc cou
    FF and                      \ crc cou_8b
    cells                       \ crc cou_8b*4=>index
    CRCtable +  @               \ crc value
    swap                        \ value crc
    8 rshift                    \ value crc>>8
    xor                         \ crc_new
;
\ calculate the CRC32 crc for n bytes at addr
: CRC32_IEEE  ( addr n - crc )
   -1 -rot                      \ IEEE CRC uses -1 as start-value
   over + swap do
      i c@ (CRC32)
   loop
   invert                       \ IEEE inverts the final calculated crc
;

\ standard crc test and output of table  ************************

s" 123456789" crc32_ieee .hex ( output should be: CBF43926 )

: SHOWCRCTABLE                  \ show table for inspection
    cr
    100 0 do
        i cells crctable + @    \ get value from table
        0 <# # # # # # # # # bl hold #> type
        i 7 and 7 = if cr then  \ cr after each 8 values
    loop
;
