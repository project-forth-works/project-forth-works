## CRC generation - 16bit

Here some examples of 16 bit CRC-code generators.

The start-value is important: start with 0xFFFF and you have the CCITT version of CRC-16, start with 0x0000 and you have the CRC-16 as used in the XMODEM data-transfer protocol. 

There are a lot of different CRC-standards. They all have the same principle but differ in details. This is not relevant when using it for yourself, but finding the correct version for existing protocol is not always easy.

For an example of a very specific way of using a CRC-code, see the CRC16 for NRF24.



### Implementations

The generic Forth version should run on all Forth implementations.

## Generic Forth

```forth
hex
1021 CONSTANT crc-polynomial ( CCITT )

: crc16 ( n ch--n)
	8 lshift XOR
	8 0 DO
		DUP 8000 AND IF 					\ msb = '1'?
			2*
			FFFF AND						\ needed for systems with > 16 bits
			crc-polynomial XOR
        ELSE
			2*
        THEN
    LOOP ;

: tst
	ffff									\ start-value
	f0 crc16
	f0 crc16
	f0 crc16
	f0 crc16
	05 crc16
	0d crc16
	15 crc16
	02 crc16
	84 crc16
	. ;

```

