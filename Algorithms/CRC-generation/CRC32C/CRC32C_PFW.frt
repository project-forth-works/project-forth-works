\ CRC32b-Castagnoli - this implementation (C) 2022 - J.J. HOEKSTRA
\ CRC32_CAST takes a start address and length of a byte-array as input
\ and produces the 32bit CRC according to Castagnoli

hex
82F63B78 constant crc-polynomial        \ reversed Castagnoli polynomial

: CRC32_CAST ( addr len -- crc )
    FFFFFFFF -rot                       \ FFFFFFFF = start-value CRC
    bounds do
        i  c@ xor
        8 0 do
            dup 1 and if                \ lsb = '1'?
                1 rshift
                crc-polynomial xor
            else
                1 rshift
            then
        loop
    loop
    -1 xor ;                            \ invert output

\ ********  TEST  ***********

cr
s" 123456789" crc32_cast u. ( E3069283 )
s" 1"         crc32_cast u. ( 90F599E3 )
s" 12"        crc32_cast u. ( 7355C460 )
s" 123"       crc32_cast u. ( 107B2FB2 )
s" 1234"      crc32_cast u. ( F63AF4EE )
decimal

