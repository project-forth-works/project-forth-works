\ I2C for the Broadcom BCM2835
\ https://www.nxp.com/docs/en/user-guide/UM10204.pdf
\
\ User words:  I2C-ON  {I2C-WRITE  {I2C-READ   I2C}
\              BUS@  BUS!  DEVICE!  {DEVICE-OK?}
\ Additional:  {I2C-OUT  {I2C-IN  {POLL}  BUS!}  BUS@}  BUS-MOVE
\
\ An example, first execute I2C-ON  After that the I2C is setup as
\ a master. Sent byte 'b' to an I2C device with address 'a'.
\   : >SLAVE    ( b a -- )  {i2c-write  bus!  i2c} ;
\   : >PCF8574  ( b -- )    40 >slave ;

hex
: B-B           ( x - lx hx )   >r r@ FF and  r> 8 rshift ; \ Split 16-bit into lx & hx
: B+B           ( lx hx -- x )  8 lshift or ; \ Build 16-bit from lx & hx

\ : **BIS     ( mask addr -- )    tuck @ or  swap ! ;          \ Set bits from mask at addr
\ : **BIC     ( mask addr -- )    >r  invert  r@ @ and  r> ! ; \ Clear bits from mask at addr
\ : BIT**     ( mask addr -- f )  @ and ;                      \ True if any bit from the mask at addr are high


\ low_out is active_low, high_out is only high impedance!!
\ wabiForth specifieke woorden: SETFUNCGPIO, SETPULLUD, WAITMCS, SETGPOUT, GETGPIN, [HEX], [DECIMAL]

: WAIT5US       5 waitmcs ; \ Delay of 5 usec - waitmcs waits 'at-least' in wabiForth


\ HARDWARE translation ******************

: SCL_P1OUT_*BIS        true 3 setgpout ;       \ clock hi
: SCL_P1OUT_*BIC        false 3 setgpout ;      \ clock lo
: SCL_P1DIR_*BIC        0 3 setfuncgpio ;       \ clock input to make high impedance for clock high
: SCL_P1DIR_*BIS        1 3 setfuncgpio ;       \ clock output to pull low

: SDA_P1OUT_*BIS        true 2 setgpout    ;    \ data hi
: SDA_P1OUT_*BIC        false 2 setgpout    ;   \ data lo
: SDA_P1DIR_*BIC        0 2 setfuncgpio ;       \ data input
: SDA_P1DIR_*BIS        1 2 setfuncgpio ;       \ data output

: SDA_P1IN_BIT*         2 getgpin     ;         \ get input from data-pin

: I2START       ( -- )
    scl_p1out_*bis  scl_p1dir_*bic  wait5us
    sda_p1dir_*bis  sda_p1out_*bic  wait5us ;

: I2ACK         ( -- )
    scl_p1out_*bic  scl_p1dir_*bis
    sda_p1out_*bic  sda_p1dir_*bis  wait5us
    scl_p1out_*bis  scl_p1dir_*bic  wait5us ;

: I2NACK        ( -- )
    scl_p1out_*bic  scl_p1dir_*bis
    sda_p1out_*bis  sda_p1dir_*bic  wait5us
    scl_p1out_*bis  scl_p1dir_*bic  wait5us ;

variable DEV  variable SUM  variable NACK?
: I2ACK@        ( -- )
    scl_p1out_*bic  scl_p1dir_*bis
    sda_p1out_*bis  sda_p1dir_*bic  wait5us
    scl_p1out_*bis  scl_p1dir_*bic  wait5us
    sda_p1in_bit* nack? ! ;

: BUS!          ( byte -- )
    8 0 do
        scl_p1out_*bic  scl_p1dir_*bis
        dup  80 and if
            sda_p1out_*bis  sda_p1dir_*bic
        else
            sda_p1out_*bic  sda_p1dir_*bis
        then
        wait5us  2*
        scl_p1out_*bis  scl_p1dir_*bic   wait5us
    loop drop  i2ack@ ;

: {I2C-ADDR     ( +n -- )          drop  i2start  dev @ bus! ; \ Start I2C write with device in DEV

\ Higher level I2C access, hides internal details!
: I2C-ON        ( -- )
    1 2 setfuncgpio     \ = data - 0=input, 1=output
    0 2 setpullud       \ -> NO pullup (1=pull-down, 2=pull-up)
    1 3 setfuncgpio     \ = clock - 0=input, 1=output
    0 3 setpullud ;     \ -> NO pullup (1=pull-down, 2=pull-up)

: BUS@          ( -- byte )
    0  8 0 do
        2*
        scl_p1out_*bic  scl_p1dir_*bis
        sda_p1out_*bis  sda_p1dir_*bic  wait5us
        sda_p1in_bit* 0<> 1 and or
        scl_p1out_*bis  scl_p1dir_*bic  wait5us
    loop  -1 sum +!
    sum @ if  I2ACK  else  I2NACK  then ;

: I2C}          ( -- )
    scl_p1out_*bic  scl_p1dir_*bis
    sda_p1out_*bic  sda_p1dir_*bis  wait5us
    scl_p1out_*bis  scl_p1dir_*bic  wait5us
    sda_p1out_*bis  sda_p1dir_*bic ;

: DEVICE!       ( a -- )    2*  FE and dev ! ;
: {DEVICE-OK?}  ( -- f )    0 {i2c-addr  i2c}  nack? @ 0= ; \ 'f' is true when an ACK was received
: {I2C-WRITE    ( +n -- )   {i2c-addr  nack? @ abort" Ack error" ; \ Start I2C write with device in DEV
  
: {I2C-READ     ( +n -- )     \ Start read to device in DEV
    sum !  i2start  dev @ 1+ bus!   \ Used for repeated start
    nack? @ abort" Ack error" ; 


\ Waiting for an EEPROM write to succeed is named acknowledge polling.
: {POLL}    ( -- )          begin  {device-ok?} until ; \ Wait until ACK received
: {I2C-OUT  ( dev +n -- )   swap  device!  {i2c-write ;
: {I2C-IN   ( dev +n -- )   swap  device!  {i2c-read ;
: BUS!}     ( b -- )        bus!  i2c} ;
: BUS@}     ( -- b )        bus@  i2c} ;
: BUS-MOVE  ( a u -- )      bounds ?do i c@ bus! loop ; \ Send string of bytes from 'a' with length 'u

\ : MS        ( u -- )        0 ?do  400 waitmcs  loop ;

\ End ;;;
