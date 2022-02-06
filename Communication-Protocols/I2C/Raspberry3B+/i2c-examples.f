\ Example-0  shows if a device with address 'dev' is present on the I2C-bus
: I2C?          ( dev -- )
    i2c-on  device!  {device-ok?}
    0= if  ." Not "  then  ." Present " ;


hex
\ Example-1  Generic implementation of an I2C bus scanner, original J. J. Hoekstra
: .BYTE         ( byte -- )         0 <# # # #> type space ;
: I2C-TARGET?   ( dev -- f )        device!  {device-ok?} ;

: .I2C-HEADER   ( -- )
    cr  8 spaces  10 0 do  i 2 .r space  loop ;

: .I2C-COLUMN   ( +n -- )
    cr  4 spaces  10 * .byte  8 emit  ." : " ;

: .I2C-TARGET   ( addr -- )
    dup i2c-target? if  .byte  else  drop  ." -- "  then ;

: FIRST-LINE    ( -- )
    0 .i2c-column ." gc cb db fp hs hs hs hs "
    10 8 do  i .i2c-target  loop ;

: LAST-LINE     ( -- )
    7 .i2c-column  8 0 do  i .i2c-target  loop
    ." sw sw sw sw ?? ?? ?? ??" ;

: SCAN-I2C      ( -- )      \ Scan for all valid I2C bus addresses
    i2c-on  base @ >r  hex
    .i2c-header  first-line
    7 1 do
        i .i2c-column
        i  10 0 do
            dup 10 * i + .i2c-target
        loop  drop
    loop
    last-line  r> base ! cr ;


\ Example-2  A driver for the PCF8574 I/O-extender
: >PCF8574      ( b dev -- )    device!  1 {i2c-write  bus!  i2c} ;
: PCF8574>      ( dev -- b )    device!  1 {i2c-read   bus@  i2c} ;


\ Example-3  A basic 24C32 to 24C512 EEPROM driver
: NEC@          ( -- b )        1 {i2c-read  bus@  i2c} ;

: EC@           ( addr -- b )   
    50 device!  2 {i2c-write  b-b bus!  bus!  i2c}  nec@ ;

: EC!           ( b addr -- )
    50 device!  3 {i2c-write  b-b bus! bus!  bus!  i2c} 
    begin  {device-ok?} until ;

: PEMIT     ( ch1 -- )      dup 7F < and  bl max  emit ;

: EDMP      ( ea -- )
    hex  i2c-on
    begin
        cr  dup 4 u.r ." : "
        10 0 do  dup i + ec@ 2 .r space  loop  [char] | emit  \ Show hex
        10 0 do  dup i + ec@ pemit  loop  [char] | emit  10 + \ Show Ascii
    key bl <> until  drop ;


\ Example-4  Write data to EEPROM
\ Note that: a target address starts on page boundaries!!!!

\ 24C64   page write: The 32K/64K EEPROM is capable of 32-BYTE page writes.
\ 24C256  page write: The 128K/256K EEPROM is capable of 64-BYTE page writes.
\ 24C512  page write: The 512K/1024K EEPROM is capable of 128-BYTE page writes.
\ 24C2048 page write: Is capable of 256-BYTE page writes.
\ The 24C1024 & 24C2048 require a different scheme because some
\ of the address bits are part of the device address!

\ sa1 = address to copy from, ta1 = address where the EE-page starts, sa2 = Start of the next page to copy
\ ta2 = address of the next EE-page, dev = Device address of EEPROM. +n = Page size of that EEPROM 
: WRITE-PAGE    ( sa1 ta1 dev +n -- sa2 ta2 )   \ Universal EEPROM page write
    >r  device!                                 \ Save data stream length & target addr.\ sa1 ta1
    r@ 2 + {i2c-write  tuck b-b  bus! bus!      \ Correct block length, sent EE addr.   \ ta1 sa1
    r@ bounds do  i c@ bus!  loop  i2c}         \ Write EEPROM page                     \ ta1 sa2
    begin  {device-ok?} until  swap r> + ;      \ Leave source addr. & corrected targ. address

\ Example for a very large memory block write for testing
\ This version uses the page size for a 24C64!!!
20 constant #PAGE               \ Adjust #PAGE size to EEPROM type
: WRITE-MEMORY  ( sa ta u -- )  \ Write a memory block of 'a' with length 'u' with fixed page size
    begin
    ?dup while                  \ Bytes left to write?              \ sa ta u
        >r r@ #page umin        \ Determine #PAGE or less bytes     \ sa ta #p    u
        50 swap write-page      \ Write #PAGE or less bytes         \ sa ta       u
        r> #page -  0 max       \ Correct length minimum is zero!   \ sa ta u
    repeat  2drop ;             \ Remove address, write is ready?   \ -                      


: EEFILL        ( a u ch -- )   \ Fill 'u' bytes of EEPROM device 'dev' with 'ch' from addr 'a'
    rot rot  bounds do  dup i ec!  loop  drop ;

\ End ;;;
