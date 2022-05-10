### CRC-32 KOOPMAN

Since CRC's are used to detect errors, developers have been searching for the optimal polynomial. More specifically: which polynomial detects most bit-errors.
The discussion on the optimal polynomial was definitely answered by Koopman in 2002. He tested ALL 32-bit polynomials for their bit-error-detecting capabilities for datastrings of 12112 bits (the size of an Ethernet MTU message). The tests where run using optimised software specifically written for the tests, and ran for 3 months on 50 DEC AlphaStations. He presented his paper at 'The International Conference on Dependable Systems and Networks (DSN) 2002)'.
It is in interesting paper to read, but prepare yourself for an extensive treatise on message lengths and hamming-distances.
His search found 4 polynomials with optimal proporties in different situations. Here we use 0x741B8CD7, reversed for programming-convenience to 0xEB31D82E.
It is interesting to note that for Ethernet frame lengths this polynomial is optimal, but for longer lengths it apparently is not.

[Here a link to the CRC-page of Philip Koopman at Carnegie Mellon University] (https://users.ece.cmu.edu/~koopman/crc/)

[and the link to the paper mentioned above]
(https://users.ece.cmu.edu/~koopman/networks/dsn02/dsn02_koopman.pdf)



#### Generic Forth example:

CRC32_KOOP takes a start address and length of a byte-array as input
and produces the 32bit CRC according to KOOPMAN.
This algorithm is exactly the same as the CRC32-IEEE version, with the exception of the polynomial. So again the values are shifted to the right and the polynomial is reversed to avoid having to reverse every received byte, and the output is inverted to create the final output.

```
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
 decimal
 ```
 
 
 
