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

