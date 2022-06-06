## CRC generation

### The idea

CRC-codes are used to check whether a set of data, like a string, is unchanged and intact. It can, for instance, be used to see whether a send message has been received correctly.

An example explains the idea: a set of data is used to generate a number, the CRC-code. On the receiving end the same method is used to also generate a CRC-code on the received data. If the two CRC-codes match, there is a high likelihood that the data was correctly received.

The same principle can be used in any situation where a check on the integrity of data is needed.

A CRC-check is not fully waterproof. With a 16bit CRC-code, the change of accidentally not finding an error is 1:65536. But for most applications this is good enough. And if you need better protection, use a 32bit CRC or combine 2 or more 16bit CRC-checks.

It is also good to realise that there are a lot of different CRC-standards. They all have the same principle but differ in details. This is not that relevant when using it for yourself, but finding the correct version for existing protocol is not always easy. For an example see the CRC16 for NRF24.

The start-value is critical: start with 0xFFFF and you have the CCITT version of CRC-16, start with 0x0000 and you have the CRC-16 as used in the XMODEM data-transfer protocol.  

- [CRC mathematical background](crc-math.md): If you are interested, have a look at a background discussion
 ***
- [CRC16](CRC16): CRC-16 sample implementation  
- [CRC32-IEEE](CRC32_IEEE): IEEE 32bit CRC standard protocol  
- [CRC32-Castagnoli](CRC32C): 32bit CRC according to Castagnoli  
- [CRC32-Koopman](CRC32_KOOP): 32bit CRC according to Philip Koopman 


### Pseudo code
```
CONSTANT CRC-POLYNOMIAL
   
Function: CRC16 ( oldCRC databyte -- newCRC )
	shift databyte left 8 bits
	XOR shifted_databyte with oldCRC
	8 0 DO
		check msb of result: IF 'true'
			multiply with 2
			XOR with CRC-POLYNOMIAL
		ELSE
			multiply with 2
		THEN
	LOOP
  
```

### Implementations

The generic 16 bit Forth version should run on all Forth implementations.

## Generic Forth

```forth 
hex
1021 CONSTANT crc-polynomial ( CCITT )

: CRC16 ( n ch--n)
	8 lshift XOR
	8 0 DO
		DUP 8000 AND IF 					\ msb = '1'?
			2*
			FFFF AND					\ needed for systems with > 16 bits
			crc-polynomial XOR
        ELSE
			2*
        THEN
    LOOP ;

: TST
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

<!-- If you are interested, have a look at [a discussion of the mathematical background](crc-math.md). -->

