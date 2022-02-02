\ I2C for the Broadcom BCM2835
\ https://www.nxp.com/docs/en/user-guide/UM10204.pdf
\
\ User words:  I2C-ON  {I2C-WRITE  {I2C-READ   I2C}
\              BUS@  BUS!  DEVICE!  {DEVICE-OK?}
\ Additional:  {I2C-OUT  {I2C-IN  {POLL}  BUS!}  BUS@}  BUS-MOVE
\
\ An example, first execute I2C-ON  After that the I2C is setup as
\ a master. Sent byte 'b' to an I2C device with address 'a'.
\   : >SLAVE    ( b a -- )  device !  1 {i2c-write  bus!  i2c} ;
\   : >PCF8574  ( b -- )    20 >slave ;

hex
: B-B       ( x - lx hx )       >r r@ FF and  r> 8 rshift ; \ Split 16-bit into lx & hx
: B+B       ( lx hx -- x )      8 lshift or ; \ Build 16-bit from lx & hx

: **BIS     ( mask addr -- )    tuck @ or  swap ! ;          \ Set bits from mask at addr
: **BIC     ( mask addr -- )    >r  invert  r@ @ and  r> ! ; \ Clear bits from mask at addr
: BIT**     ( mask addr -- f )  @ and ;                      \ True if any bit from the mask at addr are high

3F804000 constant BSC1-C                \ Control register BCM serial controller 1
3F804004 constant BSC1-S                \ Status register
3F804008 constant BSC1-DLEN             \ Data length register
3F80400C constant BSC1-A                \ Slave address register
3F804010 constant BSC1-FIFO             \ Fifo (16 byte deep) read and write data per byte from this address
3F804014 constant BSC1-DIV              \ Divider: 4000 voor 100kHz with a core freq of 400Mhz
3F804018 constant BSC1-DEL              \ Data delay register
3F80401C constant BSC1-CLKT             \ Clock stretch timeout - 0 disables timeout -> hang when no ACK!

: I2C-CLEAR     ( -- )
    20 bsc1-c !                         \ Clear fifo
    302 bsc1-s ! ;                      \ Clear Clock stretch, No-Ack & Transfer done bits

decimal
: I2C-ON     ( -- )
    4 2 setfuncgpio                     \ Set I2C function of which GPIO=pin
    4 3 setfuncgpio                     \ ditto
    i2c-clear
    2000 bsc1-div ! ;                   \ 200kHz = Core clock / cdiv (2000)
                                        \ So Core clock = 400 MHz!

hex
\ : I2C-OFF     ( -- )      8000 bsc1-c **bic ;         \ Disable I2C
\ : I2C-STATUS  ( -- stat ) 3FF bsc1-s bit** ;          \ Leave content of status reg
\ : I2C-START   ( -- )      80 bsc1-c **bis ;           \ Start I2C transfer
\ : I2C-BUSY?   ( -- f )    1 bsc1-s bit** ;            \ Flag is true when I2C bus is occupied
\ : I2C-@DATA   ( -- +n )   bsc1-dlen @ ;               \ Number of bytes left to ...

: I2C-BYTE!     ( byte -- ) FF and  bsc1-fifo ! ;       \ Store data byte
: I2C-BYTE@     ( -- byte ) bsc1-fifo @ ;               \ Read data byte
: >I2C-DATA     ( +n -- )   FFFF and  bsc1-dlen ! ;     \ Number of bytes to transmit or receive
: I2C-WRITE?    ( -- f )    010 bsc1-s bit** ;          \ Flag = true when there is space in the fifo
: I2C-READ?     ( -- f )    020 bsc1-s bit** ;          \ Flag = true when there is data in the fifo
: I2C-ADDR?     ( -- f )    100 bsc1-s bit** 0= ;       \ Flag is true when I2C addr. is valid
: I2C-DONE?     ( -- f )    002 bsc1-s bit** ;          \ Flag is true if done
: I2C-OPEN      ( 0|1 -- )  1 and  8080 or  bsc1-c ! ;  \ 0 = Write, 1 = Read. Open I2C-bus for read or write
: I2C-INIT      ( +n -- )   i2c-clear  >i2c-data ;


\ Generic I2C interface
: DEVICE!       ( adr -- )          7F and  bsc1-a ! ;  \ Set 7-bits slave address
: {I2C-WRITE    ( +n -- )           i2c-init  0 i2c-open ;
: {I2C-READ     ( +n -- )           i2c-init  1 i2c-open ;
: I2C}          ( -- )              begin  i2c-done? until  2 bsc1-s ! ; \ Without time out & reset done bit
: BUS!          ( b -- )            begin  i2c-write? until  i2c-byte! ;
: BUS@          ( -- b )            begin  i2c-read? until  i2c-byte@ ;
: {DEVICE-OK?}  ( -- f )            0 {i2c-write  i2c}  i2c-addr? ;


\ These words are just optimized alternatives for two or more words
: {I2C-OUT      ( addr +n -- )      swap device!  {i2c-write ;
: {I2C-IN       ( addr +n -- )      swap device!  {i2c-read ;
: BUS!}         ( b -- )            bus!  i2c} ;
: BUS@}         ( -- b )            bus@  i2c} ;
: {POLL}        ( -- )              begin  {device-ok?} until ;
: BUS-MOVE      ( a u -- )          bounds ?do i c@ bus! loop ; \ Send from addr. 'a' with length 'u'

\ : MS            ( u -- )            s0 ?do  400 waitmcs  loop ;

\ End ;;;
