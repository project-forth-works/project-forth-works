### CRC-32C

Since the first implementation of a CRC to detect errors it has been discussed which polynomial has the highest chance of detecting multi-bit errors. Every polynomial can detect a 1 bit error. But the ability of detecting errors in more than 1 bit depends strongly on the polynomial. Castagnoli proposed an alternative polynomial ( 0x1EDC6F41 ) which has a better capability than the IEEE polynomial to detect multi-bit errors.
The discussion on which polynomial is the best was only answered by Koopman in 2002 by testing ALL 32b polynomials against bit-detecting criteria.


#### Generic Forth example:

CRC32_CAST takes a start address and length of a byte-array as input
and produces the 32bit CRC according to Castagnoli
This algorithm is exactly the same as the CRC32-IEEE version, with the exception of the polynomial. So again the values are shifted to the right and the polynomial is reversed to  avoid having to reverse every received byte, and the output is inverted to create the final output.

```
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
 decimal
 ```
