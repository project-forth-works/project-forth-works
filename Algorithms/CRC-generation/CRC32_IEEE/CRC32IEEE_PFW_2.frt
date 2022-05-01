\ crc32b-IEEE - this implementation (C) 2022 - J.J. HOEKSTRA

hex
EDB88320 constant crc-polynomial ( reversed IEEE )

hex
: CRC32_IEEE ( addr len -- crc )
	FFFFFFFF -rot							\ FFFFFFFF = start-value CRC
	bounds do
		i  c@ xor
		8 0 do
			dup 1 and if 					\ lsb = '1'?
				1 rshift
				crc-polynomial xor
      		else
				1 rshift
       		then
        loop
    loop
	-1 xor									\ invert output
;


\ ********  TEST  ***********

hex cr
s" 123456789" crc32_ieee . ( CBF43926 )
s" 1"         crc32_ieee . ( 83DCEFB7 )
s" 12"        crc32_ieee . ( 4F5344CD )
s" 123"       crc32_ieee . ( 884863D2 )
s" 1234"      crc32_ieee . ( 9BE3E0A3 )
decimal

