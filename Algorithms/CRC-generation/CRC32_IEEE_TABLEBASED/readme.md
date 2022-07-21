### fast 32bit IEEE CRC generation using a table

Generating a CRC is a pretty slow process. One way of speeding up this process is by using a table. This table contains pre-calculated values of the 8 shifts and XOR steps done for each byte added to a CRC.
This saves time, as a major part of the work is be done only once, during initialisation.

The code is split up in two sections: an initialisation part to create a table with values and a CRC-creation part which uses the table to quickly generate a CRC.

If you look at the code you will see that the part which generates/fills the table looks very much the same as the code we used for the generation of a CRC in the other examples. Which is in fact logical!

If you look at the part of the code which updates the CRC for a next byte (below) you will see that instead of 8 loops, the CRC is now be updated in 1 go. Hence the speed-up of this algorithm compared to the simple implementations.
The essential trick for the routine is that the byte used as input is first XOR'd with the previous CRC and only then is used as index into the table.

```
hex
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
```
