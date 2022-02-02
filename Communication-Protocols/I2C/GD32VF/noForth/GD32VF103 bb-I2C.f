(* GD32VF103 bitbang I2C driver

Values for CRL/CRH-Registers:
 0:  Analog Input
 1:  Output Push/Pull, 10 MHz
 2:  Output Push/Pull,  2 MHz
 3:  Output Push/Pull, 50 MHz
 4:  Floating Input (Reset state)
 5:  Open-Drain Output, 10 MHz
 6:  Open-Drain Output,  2 MHz
 7:  Open-Drain Output, 50 MHz
 8:  Input with pull-up / pull-down
 9:  Alternate Function, Push/Pull, 10 MHz
 A:  Alternate Function, Push/Pull,  2 MHz
 B:  Alternate Function, Push/Pull, 50 MHz
 C:  Reserved
 D:  Alternate Function, Open-Drain, 10 MHz
 E:  Alternate Function, Open-Drain,  2 MHz
 F:  Alternate Function, Open-Drain, 50 MHz

PB6 = SCL
PB7 = SDA

  User words:  I2C-ON  {I2C-WRITE  {I2C-READ   I2C}
               BUS@  BUS!  DEVICE!  {DEVICE-OK?}
  Additional:  {I2C-OUT  {I2C-IN  {POLL}  BUS!}  BUS@}  BUS-MOVE
 
  An example, first execute I2C-ON  After that the I2C is setup as
  a master. Sent byte 'b' to an I2C device with address 'a'.
    : >SLAVE    ( b a -- )  {i2c-write  bus!  i2c} ;
    : >PCF8574  ( b -- )    40 >slave ;

*)

hex  
v: inside also definitions
40010C00 constant PB-CRL    \ Port-B control Register for pins 0 to 7
40010C08 constant PB-IDR    \ Port-B Input Data Register
40010C0C constant PB-ODR    \ Port-B Output Data Register

40 constant SCL             \ I2C clock line 
80 constant SDA             \ I2C data line
SCL SDA or constant BUS     \ I2C bus lines

value DEV  value SUM  value NACK?
\ : WAIT          ( -- )      10 for next ;         \ About 100 KHz with 104 MHz clock
  : WAIT          ( -- )      02 for next ;         \ About 200 KHz with 104 MHz clock
\ : WAIT          ( -- )      ;                     \ About 300 KHz with 104 MHz clock
\ : WAIT          ( -- )      ; immediate           \ About 380 KHz with 104 MHz clock

: I2START       ( -- )
    scl pb-odr *bis  wait
    sda pb-odr *bic  wait ;
 
: I2ACK         ( -- )
    scl pb-odr *bic  sda pb-odr *bic  wait
    scl pb-odr *bis  wait ;

: I2NACK        ( -- )
    scl pb-odr *bic  sda pb-odr *bis  wait
    scl pb-odr *bis  wait ;

: I2ACK@        ( -- )
    scl pb-odr *bic  sda pb-odr *bis  wait
    scl pb-odr *bis  wait
    sda pb-idr bit* to nack? ;

v: extra definitions
: BUS!          ( b -- )
    8 for
        scl pb-odr *bic 
        dup 80 and if   sda pb-odr *bis
        else            sda pb-odr *bic
        then            wait  2*
        scl pb-odr *bis  wait
    next  drop  i2ack@ ;

v: inside definitions
: {I2C-ADDR     ( +n -- )       drop  i2start  dev bus! ; \ Start I2C write with address from DEV


\ Higher level I2C access, hides internal details!
v: extra definitions
: I2C-ON        ( -- )
    6644,4444 pb-crl !  \ Set PB5 & PB6 as I2C output (Reset $44444444)
    bus pb-odr *bis ;   \ I2C floating at startup

: BUS@          ( -- b )
    0  8 for
        2*  scl pb-odr *bic  sda pb-odr *bis  wait
        sda pb-idr bit*  0<> 1 and  or
        scl pb-odr *bis wait
    next 
    -1 +to sum
    sum if  i2ack  else  i2nack  then ;

: I2C}          ( -- )
    scl pb-odr *bic  sda pb-odr *bic  wait
    scl pb-odr *bis  wait
    sda pb-odr *bis ;

: DEVICE!       ( ia -- )   2* FE and  to dev ;
: {DEVICE-OK?}  ( -- f )    0 {i2c-addr  i2c}  nack? 0= ; \ 'f' is true when an ACK was received 
: {I2C-WRITE    ( +n -- )   {i2c-addr  nack? ?abort ; \ Start I2C write to device in DEV

: {I2C-READ     ( +n -- )     \ Start read from device in DEV
    to sum  i2start  dev 1+ bus!  nack? ?abort ; 


\ Waiting for an EEPROM write to succeed is named acknowledge polling.
: {POLL}    ( -- )          begin  {device-ok?} until ; \ Wait until ACK received
: {I2C-OUT  ( dev +n -- )   swap  device!  {i2c-write ;
: {I2C-IN   ( dev +n -- )   swap  device!  {i2c-read ;
: BUS!}     ( b -- )        bus!  i2c} ;
: BUS@}     ( -- b )        bus@  i2c} ;
: BUS-MOVE  ( a u -- )      bounds ?do i c@ bus! loop ; \ Send string of bytes from 'a' with length 'u

v: fresh
shield BB-I2C\  freeze

\ End ;;;
