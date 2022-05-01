\ crc32b-IEEE - this implementation (C) 2022 - J.J. HOEKSTRA

hex
EDB88320 constant crc-polynomial ( reversed IEEE )

: compl8b ( ch -- ^ch ) FF xor ;

: correctcrc ( crc count -- cor_crc )
\ needed for strings of 1, 2 and 3 chars - I do not know why!!!
	dup 3 > if drop           exit then
	dup 3 = if drop    FF xor exit then
	    2 = if       FFFF xor exit then
		           FFFFFF xor ;

0 value counter

: CRC32_IEEE ( addr len -- crc )
	0 to counter
	0 -rot									\ 0 = inverted start number...
	bounds do
		i  c@
		counter 4 < if compl8b then			\ invert first 4 chars
		xor
		8 0 do
			DUP 1 AND IF 					\ lsb = '1'?
				1 rshift
				crc-polynomial XOR
      		ELSE
				1 rshift
       		THEN
        loop
    	1 +to counter
    loop
	-1 xor									\ invert output
	counter correctcrc
;
decimal

\ ********  TEST  ***********

cr
s" 123456789" crc32_ieee .hex ( CBF43926 )
s" 1"         crc32_ieee .hex ( 83DCEFB7 )
s" 12"        crc32_ieee .hex ( 4F5344CD )
s" 123"       crc32_ieee .hex ( 884863D2 )
s" 1234"      crc32_ieee .hex ( 9BE3E0A3 )

decimal

