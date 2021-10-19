(* Barebone SPI Flash memory driver for MSP430FR5949

Primitive functions:

{FL       ( c -- )            = Open SPI to flash & send command c
{FREAD    ( da c -- b )       = Send read command c & address, read byte b from address
{FREAD+   ( da +n -- da+n b ) = Read +n bytes from address a and increase a with 
                                that amount leaving the first databyte b
READY?    ( -- f )            = Leave true when an erase or write action is ready
WRITE-ON  ( -- )              = Activate write access to the flash chip
BUSY      ( -- )              = Wait until an erase or write action is finished

Higher functions:

FC@       ( da -- b )         = Read byte b from flash address a
FC@+      ( da1 -- da2 b )    = Read byte b from flash address a1 & increase address leaving a2
F@        ( da -- x )         = Read word x from flash address a
F@+       ( da1 -- da2 x )    = Read word x from flash address a1 & increase address leaving a2
FTYPE     ( da u --  )        = Type u bytes from flash address a
CHIP-ERASE ( -- )             = Erase the whole flash chip
ID.       ( -- )              = Read & print manufacturer & device id
FDUMP     ( da u -- )         = Dump u bytes of flash memory beging at address a

*)

: {FL           ( c -- )        {spi ; \ Open SPI to flash & send command c

: {FREAD        ( da c -- b )
    {fl  swap spi-out   \ Send command, swap address & send high byte
    b-b  spi-out        \ Split lower address byte & send
    spi-out  spi-in ;   \ Send lowest address byte & read data byte

: {FREAD+     ( da +n -- da+n b ) >r 2dup r> m+  2swap 3 {fread ;
: READY?      ( -- f )         5 {fl spi-in spi} 1 and 0= ;
: WRITE-ON    ( -- )           6 {fl spi} ;
: BUSY        ( -- )           begin  ready? until ;

\ SPI Flash start here
\ Read bytes, words & strings from flash
: FC@         ( da -- b )      3 {fread  spi} ;
: FC@+        ( da1 -- da2 b ) 1 {fread+  spi} ;
: F@          ( da -- x )      3 {fread  spi-in  spi}  b+b ;
: F@+         ( da1 -- da2 x ) 2 {fread+  spi-in  spi}  b+b ;
v: inside
: FTYPE       ( da u --  )      for  fc@+ pchar emit  next  2drop ;

: CHIP-ERASE  ( -- )    ." Be patient! " write-on  60 {fl spi}  busy ;
: ID.           ( -- )          \ Read manufacturer & device id
    0  90 {fread spi-in  spi}  . . ;

: FDUMP         ( da u -- )
    4 SPI-setup  0 ?do
        cr  2dup d.str 5 rtype ." : "   \ Print address
         2dup  10 for                   \ Dump 16 bytes
            fc@+ 2 .r space             \ Print 16 bytes in hex.
        next
        ch | emit  2swap 10 ftype ." | " \ Print 16 bytes in visible ASCII
        stop? if leave then             \ Adjust address & test for key
    10 +loop  2drop ;


\ Read and write sectors from and to SPI-flash
100             constant #SECT  \ Sector size
800000 #sect /  constant #FLASH \ Flash end for 64 Mbit Flash in sectors, 8 MByte
create 'BUFFER  #sect allot     \ Reserve sector buffer in RAM

\ Read & write 256 byte sectors from and to flash & patch buffer
: ADDR-SECTOR   ( sa -- )
    #sect m*  swap spi-out  b-b spi-out spi-out ;

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


v: forth
\ Small SPI flash demonstration
: FILL1         ( -- )      #sect 0 do  i  'buffer i + c!  loop ;
: FILL2         ( -- )      0 #sect 1- do  i  'buffer i + c!  -1 +loop ;
: FILL3         ( c -- )    #sect 0 do  dup  'buffer i + c!  loop  drop ;

4 spi-setup
fill1       0 write-sector
fill2       1 write-sector
ch W fill3  2 write-sector

200. fc@  dup .  emit
0. 40 fdump
100. 40 fdump
200. 40 fdump
0 erase-sector

0. 40 fdump

shield FLASH\  freeze
