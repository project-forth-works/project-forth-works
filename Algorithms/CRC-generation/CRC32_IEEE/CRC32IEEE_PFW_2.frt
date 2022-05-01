\ crc32b-IEEE - this implementation (C) 2022 - J.J. HOEKSTRA
forget crc32ieee : CRC32IEEE ;

hex
EDB88320 constant crc-polynomial ( reversed IEEE )

: compl8b ( ch -- ^ch )
	FF xor ;

: correctcrc ( crc count -- cor_crc )
	dup 3 > if drop           exit then
	dup 3 = if drop    FF xor exit then
	    2 = if       FFFF xor exit then
		           FFFFFF xor ;

0 value counter

: CRCS ( addr len -- crc )
	0 to counter
	0 -rot
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


s" 123456789" 	sliteral ts9 ( CBF43926 )
s" 1" 			sliteral ts1 (  )
s" 12" 			sliteral ts2 (  )
s" 123" 		sliteral ts3 (  )
s" 1234" 		sliteral ts4 (  )


: tst
	ts1 crcs cr .hex
	ts2 crcs cr .hex
	ts3 crcs cr .hex
	ts4 crcs cr .hex
	ts9 crcs cr .hex
;
decimal

