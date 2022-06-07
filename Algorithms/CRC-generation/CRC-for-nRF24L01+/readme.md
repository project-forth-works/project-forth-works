# CRC generation for the nRF24L01+

## Idea

To build a data logger for the nRF24L01+ we need to check the incoming data records manually.
This code example runs on noForth R for the RISC-V micro processor. It uses a trick to
pick up all network data. It does so by checking only the first three of the five address bytes.
When the received records do not overflow the 32 bytes data buffer we can inspect all the
received data! Note: The third received byte contains a field with the received record length!

![afbeelding](https://user-images.githubusercontent.com/11397265/172347230-b23f0068-8415-48a7-991b-ecdfb5e9244d.png)
  **The record format as used by the nRF24L01+**  

### Pseudo code

```
Function: CRC  ( x1 -- x2 )
  Check if bit 15 of x1 is high, if it is high
  move x1 1 position to the left & AND with FFFF
  Then XOR the result with the CCITT polynomial (0x1021)
  If bit 15 is low, X1 will only be shifted 1 bit to the left

Function: CRC16  ( x1 b -- x2 )
  Shift byte 'b' 8 bits to the left, XOR it with x1
  then call CRC 8 times, one time for each bit in the byte

Function: CRCBIT  ( x1 b x2 )
  AND the byte 'b' with 80 leaving the highest bit of the byte
  Shift the result 8 bits to the left and XOR with x1
  after that call CRC one time

Function: LASTBIT  ( a x1 #pay -- a x2 )
  Add 3 to #pay, then add addres 'a' to it
  read the byte stored on that address
  finally call the crcbit

Function: CRC?  ( a #pay -- a f )
  Save #pay, start with CRC code D310
  Add 3 (two address bytes & PCF) to the record length #pay
  of the record pointed to by 'a'
  Read #pay+3 bytes stored at 'a' and call CRC16 for each of them
  finally call LASTBIT for the add the final bit
  Then calculate the address of the first CRC code in the buffer
  now read & correct the CRC code, compare it to the calculated CRC
  The flag 'f' is true when both CRC's are correct.
```

## Generic Forth example
```forth
\ Check received nRF24L01+ message on correct CRC,
\ Note: This version starts with a prepared polynomal
\ This: D310  which is: -1 F0 CRC16  F0 CRC16  F0 CRC16
\
\ Extra words: H@ ( a -- x )  \ Fetch a 16-bit word

hex
create BUFFER  20 allot     \ Saved payload package
: CRC       ( x1 -- x2 )    \ Bitwise CRC check
    dup 8000 and if
        2* FFFF and  1021  xor  ( CRC-POLYNOMIAL CCITT )
    else
        2*
    then ;

\ Extend CRC x1 with the CRC of the byte 'b' leaving a new CRC x2
: CRC16    ( x1 b -- x2 )    8 lshift xor  crc crc crc crc crc crc crc crc ;

\ Extend the CRC x1 with the highest bit of the byte 'b'
: CRCBIT   ( x1 b -- x2 )    80 and  8 lshift xor  crc ;

\ Add bit-7 of the last byte to x1 finishing the CRC code x2.
: LASTBIT  ( a x1 #pay -- a x2 )  3 +  2 pick + c@ crcbit ;


\ 'a'  = The address where the payload is stored
\ #pay = The length of the payload to check
\ f    = True when the CRC over a variable length payload is correct
: CRC?      ( a #pay -- a f )   \ Generate & check CRC code
    >r  D310                                \ CRC of three base address bytes
    over r@ 3 + bounds do  i c@ crc16  loop \ Other address bytes & payload
    r@ lastbit
    buffer r> 3 + + h@ ><  = ;              \ CRC correct?
```

More info later on with the nRF24L01+ data logger (sniffer) implementation.  
