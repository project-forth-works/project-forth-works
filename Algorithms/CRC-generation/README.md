## CRC generation

### The idea

CRC-codes are used to check whether a set of data, like a string, is unchanged and intact. It can, for instance, be used to see whether a send message has been received correctly.

An example explains the idea: a set of data is used to generate a number, the CRC-code. On the receiving end the same method is used to also generate a CRC-code on the received data. If the two CRC-codes match, there is a high likelyhood that the data was correctly received.

The same principle can be used in any situatin where a check on the integrity of data is needed.

It is good to realize that such a check is not fully waterproof. With a 16bit CRC-code, the change of accidentally having a correct code is 1:65536. But for most applications this is already enough.

It is also good to realize that there are many, many, many different CRC-standards. They all have the same principle but differ in details. This is all not that relevant when using it for yourself, but finding the correct version for existing protocol is not always easy. For an example see the CRC16 for NRF24.


### Pseudo code
```
CONSTANT CRC-POLYNOMIAL
   
Function: CRC16 ( oldCRC databyte -- newCRC )
	shift databyte left 8 bits
	XOR shifted_databyte with oldCRC
	8 0 DO
		check msb of result: IF 'true'
			multiply with 2
			XOR with CRC-POYNOMIAL
		ELSE
			multiply with 2
		THEN
	LOOP
  
```

### Implementations

The generic Forth version should run on all Forth implementations.

## Generic Forth

``` 
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
