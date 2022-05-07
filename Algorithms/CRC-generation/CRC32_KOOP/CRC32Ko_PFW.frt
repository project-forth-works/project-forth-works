\ CRC32b-Koopamn - this implementation (C) 2022 - J.J. HOEKSTRA
\ CRC32_KOOP takes a start address and length of a byte-array as input
\ and produces the 32bit CRC according to Koopman

hex
EB31D82E constant crc-polynomial        \ reversed Koopman polynomial

: CRC32_KOOP ( addr len -- crc )
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
s" 123456789" crc32_koop u. ( 2D3DD0AE )
s" 1"         crc32_koop u. ( FBF549A1 )
s" 12"        crc32_koop u. ( 3A8AF32A )
s" 123"       crc32_koop u. ( 6BD5EAE9 )
s" 1234"      crc32_koop u. ( D5DE4206 )
decimal












