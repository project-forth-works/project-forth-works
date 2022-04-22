\ CRC16 for XMODEM

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

: tst1
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

decimal
: tst2
	0000									\ start-value=CRC-16/XMODEM
	49 crc16
	50 crc16
	51 crc16
	52 crc16
	53 crc16
	54 crc16
	55 crc16
	56 crc16
	57 crc16
	.hex ;
