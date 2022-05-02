### 32bit IEEE CRC

The IEEE 32bit CRC standard was introduced for the ethernet protocol. The essential difference with previous CRC-implementations was that the start-number is 0xFFFFFFFF instead of 0x0. The reason is that a network can easily start with a couple of spurious 0x0's. A CRC with a 0x0 as start-number cannot detect such a network-specific error. By having 0xFFFFFFFF as start number, the first 4 characters received are effectively inverted. And that enables the detection of spurious zero's at the start of a transmission.

If you look at the implementation that you will see that the CRC is shifted to right and that the polynomial of the CRC-IEEE has been reversed. This avoids having to bit-reverse every received byte, another IEEE speciality.


```
EDB88320 constant crc-polynomial ( reversed IEEE )

hex
: CRC32_IEEE ( addr len -- crc )            \ input is address and length
    FFFFFFFF -rot                           \ FFFFFFFF = start-value CRC
    bounds do
        i  c@ xor
        8 0 do
            dup 1 and if                    \ if lsb = '1' do rshift and xor
                1 rshift
                crc-polynomial xor
            else                            \ otherwise only a rshift
                1 rshift
            then
        loop
    loop
    -1 xor                                  \ invert output
;
```
