(* Barebone SPI Flash memory driver for GD32VF103

Primitive functions:

{FL       ( c -- )          = Open SPI to flash & send command c
{FREAD    ( a c -- b )      = Send read command c & address, read byte b from address
{FREAD+   ( a +n -- a+n b ) = Read +n bytes from address a and increase a with that 
                              amount leaving the first databyte b
READY?    ( -- f )          = Leave true when an erase or write action is ready
WRITE-ON  ( -- )            = Activate write access to the flash chip
BUSY      ( -- )            = Wait until an erase or write action is finished

Higher functions:

FC@       ( a -- b )        = Read byte b from flash address a
FC@+      ( a1 -- a2 b )    = Read byte b from flash address a1 & increase address leaving a2
F@        ( a -- x )        = Read word x from flash address a
F@+       ( a1 -- a2 x )    = Read word x from flash address a1 & increase address leaving a2
FTYPE     ( a u --  )       = Type u bytes from flash address a
CHIP-ERASE ( -- )           = Erase the whole flash chip
ID.       ( -- )            = Read & print manufacturer & device id
FDUMP     (a u -- )         = Dump u bytes of flash memory beging at address a

*)

: {FL         ( c -- )          {spi ; \ Open SPI to flash & send command c

: {FREAD      ( a c -- b )
    {fl  h-h spi-out    \ Send command, split address & send high byte
    b-b  spi-out        \ Split lower address byte & send
    spi-out  spi-in ;   \ Send lowest address byte & read data byte

: {FREAD+     ( a +n -- a+n b ) over + swap 3 {fread ;
: READY?      ( -- f )         5 {fl spi-in spi} 1 and 0= ;
: WRITE-ON    ( -- )           6 {fl spi} ;
: BUSY        ( -- )           begin  ready? until ;

\ SPI Flash start here
\ Read bytes, words & strings from flash
: FC@         ( a -- b )       3 {fread  spi} ;
: FC@+        ( a1 -- a2 b )   1 {fread+  spi} ;
: F@          ( a -- x )       3 {fread  spi-in  spi}  b+b ;
: F@+         ( a0 -- a1 x )   2 {fread+  spi-in  spi}  b+b ;
inside
: FTYPE       ( a u --  )      for  fc@+ pchar emit  next  drop ;

: CHIP-ERASE  ( -- )    ." Be patient! " write-on  60 {fl spi}  busy ;
: ID.         ( -- )    \ Read manufacturer & device id
    0  90 {fread spi-in  spi}  . . ;

: FDUMP       ( a u -- )
    4 SPI-setup  0 ?do
        cr  dup 0 d.str 5 rtype ." : "  \ Print address
         dup  10 for                    \ Dump 16 bytes
            fc@+ 2 .r space             \ Print 16 bytes in hex.
        next
        ch | emit  swap 10 ftype ." | " \ Print 16 bytes in visible ASCII
        stop? if leave then             \ Adjust address & test for key
    10 +loop  drop ;


\ Read and write sectors from and to SPI-flash
100             constant #SECT  \ Sector size
800000 #sect /  constant #FLASH \ Flash end for 64 Mbit Flash in sectors, (8 MByte/#sect)
create 'BUFFER  #sect allot     \ Reserve sector buffer in RAM

\ Read & write 256 byte sectors from and to flash & patch buffer
: ADDR-SECTOR   ( sa -- )
    #sect *  h-h spi-out  b-b spi-out spi-out ;

: READ-SECTOR   ( sa -- )       \ Fill buffer from 'sa', the address of a 256 byte sector
    3 {fl  addr-sector  'buffer
    #sect for  spi-in  over c!  1+  next  spi}  drop ;

: WRITE-SECTOR  ( sa -- )       \ Write buffer to 'sa' address of a 256 byte sector
    dup #flash u< 0= if  drop exit  then \ Prevent invalid write
    write-on  2 {fl  addr-sector  'buffer
    #sect for  count spi-out  next  drop  spi}  busy ;

\ Erase goes in 4 kByte sectors
: ERASE-SECTOR  ( sa -- )       \ 'sa' is a 256 byte sector address in a 4 kByte sector!
    write-on  20 {fl addr-sector spi}  busy ;

forth
\ Small SPI flash demonstration
: FILL1         ( -- )      #sect 0 do  i  'buffer i + c!  loop ;
: FILL2         ( -- )      0 #sect 1- do  i  'buffer i + c!  -1 +loop ;
: FILL3         ( c -- )    #sect 0 do  dup  'buffer i + c!  loop  drop ;

4 spi-setup
fill1       0 write-sector
fill2       1 write-sector
ch W fill3  2 write-sector

200 fc@  dup .  emit
0 40 fdump
100 40 fdump
200 40 fdump

0 erase-sector

0 40 fdump

shield FLASH\  freeze
