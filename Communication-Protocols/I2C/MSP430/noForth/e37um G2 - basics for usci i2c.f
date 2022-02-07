(* USCI I2C on MSP430G2553 using pull-ups.
   The bitrate values are for an 8 MHz DCO, for 16 MHz they should be doubled.
   This is a better version, the routines work more solid. Code Vsn 1.02

  The most hard to find data are those for the selection registers.
  To find the data for the selection register of Port-1 here 026 and
  041 you have to go to the "Port Schematics". For P1.6 and P1.7 these
  are page 48 and 49 of SLAS735J.PDF These tables say which function 
  will be on each I/O-bit at a specific setting of the registers.

  Address 026 - P1SEL, port-1 selection register
  Address 041 - P1SEL2, port-1 selection register 2

  A description of USCI as I2C can be found in SLAU144J.PDF from page
  449 to page 473, the register description starts at page 468. The
  UCB0CTL0 register selects the SPI- or I2C-mode we are in.

  Connect the I2C-print from the Forth users group or any other module
  with I2C chips. Connect the power lines, P1.7 to SDA and P1.6 to SCL,
  note that two 10k pullup resistors has te be mounted and jumper P1.6 to
  the green led has to be removed, that's it. The minimum I2C clock for
  this code is 2500 Hz, that is a bitrate divisor of 6400.

  User words:  I2C-ON  {I2C-WRITE  {I2C-READ   I2C}
               BUS@  BUS!  DEVICE!  {DEVICE-OK?}
  Additional:  {I2C-OUT  {I2C-IN  {POLL}  BUS!}  BUS@}  BUS-MOVE

  An example, first execute I2C-ON  After that the I2C is setup as a
  master. Sent byte 'b' to an I2C device with address 'a'.
    : >SLAVE    ( b a -- )  1 {i2c-write  bus!  i2c} ;
    : >PCF8574  ( b -- )    20 >slave ;

 Addresses, Lables and Bit patterns  
 0120    - WDTCL        - Off already
 0026    - P1SEL        - 0C0
 0041    - P1SEL2       - 0C0
 0068    - UCB0CTL0     - 00F
 0069    - UCB0CTL1     - 081
 006A    - UCB0BR0      - 0A0
 006B    - UCB0BR1      - 000
 006C    - UCB0CIE      - USCI interrupt enable
 006D    - UCB0STAT     - USCI status
 006E    - UCB0RXBUF    - RX Data
 006F    - UCB0TXBUF    - TX Data
 0118    - UCB0I2C0A    - NC
 011A    - UCB0I2CSA    - 042
 0001    - IE2          - 000
 0003    - IFG2         - 008 = TX ready, 004 = RX ready
 *)

hex  v: inside also  definitions
code INT-OFF    ( -- )      C232 ,  4F00 ,  end-code
: I2C-CLEAR     ( -- )      8 3 *bis ;  \ IFG2      TX buffer empty
: ?I2C          ( fl -- )   ?abort ;    \ I2C error message

\ 04 = wait for data received to RX; 08 = wait for TX to be sent
\ : I2C-WAIT    ( bit -- )
\    80  begin
\        over 3 bit* if  2drop exit  then  
\    1- dup 0= until  true ?abort ;
code I2C-WAIT   ( bit -- )
    200 # day mov       \ 512 to counter (day)
    begin,
        tos 3 & .b bit  cs? if,  sp )+ tos mov  next  then,
        #1 day sub
    0=? until,
chere >r  \ Reuse of code
    ip push
    ' ?i2c >body # ip mov
    next
end-code

\ 02 = wait for startcond. to finish; 04 = wait for stopcond. to finish
\ : I2C-DONE    ( bit -- )  \ wait until startcond. or stopcond. is done
\    200  begin
\        over 69 bit* 0= if  2drop exit  then  
\    1- dup 0= until  true ?abort ;
code I2C-DONE     ( bit -- )
    200 # day mov      \ 512 to counter (day)
    begin,
        tos 69 & .b bit  cc? if,  sp )+ tos mov  next  then,
        #1 day sub
    0=? until,
    r> jmp
end-code

value SUM  value 1ST?   \ Hold number of bytes to send & flag first data byte
v: extra definitions \ Basic I2C bus primitives
: I2C-ON    ( -- )
    int-off
    C0 26 *bis   \ P1SEL     I2C to pins
    C0 41 *bis   \ P1SEL2
    1 69 *bis    \ UCB0CTL1  reset USCI
    F 68 c!      \ UCB0CTL0  I2C master
    81 69 c!     \ UCB0CTL1  Use SMclk
\   dm 20 6A c!  \ UCB0BR0   Bitrate 400 KHz with 8 MHz DCO for OLED
    dm 80 6A c!  \ UCB0BR0   Bitrate 100 KHz with 8 MHz DCO
\   dm 160 6A c! \ UCB0BR0   Bitrate 100 KHz with 16 MHz DCO
    0 6B c!      \ UCB0BR1
    1 69 *bic    \ UCB0CTL1  Resume USCI
    i2c-clear ;

v: inside definitions
: I2C-START     ( -- )      2 69 *bis ;           \ UCB0CTL1
: I2C-STOP      ( -- )      4 69 *bis ;           \ UCB0CTL1
: I2C-NACK      ( -- )      8 69 *bis ;           \ UCB0CTL1
: DEVICE-OK?    ( -- fl )   8 6D bit* 0= ;        \ UCB0STAT

v: extra definitions
: BUS@          ( -- b )    \ Read databyte 'b' from I2C-bus
    -1 +to sum  sum 0= if  i2c-stop  then  4 i2c-wait  6E c@ ; \ UCB0RXBUF

: BUS!          ( b -- )    \ Output 'b' on I2C-bus
    6F c!  1st? if  0 to 1st?  2 i2c-done  then  8 i2c-wait ;

: {I2C-WRITE    ( -- +n )
    to sum  -1 to 1st?  12 69 *bis  8 i2c-wait ;    \ UCB0CTL1  Send start condition

: {I2C-READ     ( +n -- )       \ Send I2C device address for reading
    to sum  10 69 *bic  2 69 *bis \ UCB0CTL1  Setup read & start
    8 i2c-wait  2 i2c-done ;   \ Wait for start condition & ack

: DEVICE!       ( dev -- )  7F and  11A c! ;        \ UCB0I2CSA Set I2C device address
: I2C}          ( -- )      I2C-stop  4 I2C-done  0 to 1st? ; \ Stop condition & check
: {DEVICE-OK?}  ( -- fl )   0 {i2c-write  i2c}  device-ok? ; \ Flag 'fl' is true when in ACK is received


\ Possible extensions:
: {POLL}        ( -- )          begin  {device-ok?} until ; \ Wait until an ACK is received
: {I2C-OUT      ( dev +n -- )   swap device!  {i2c-write ;  \ Open I2C device for writing
: {I2C-IN       ( dev +n -- )   swap device!  {i2c-read ;   \ Open I2C device for reading
: BUS!}         ( b -- )        bus!  i2c} ;                \ Write last I2C databyte!
: BUS@}         ( -- b )        i2c-stop  bus@  4 i2c-done ; \ Read last I2C databyte!
: BUS-MOVE      ( a u -- )      bounds ?do i c@ bus! loop ; \ Send string of bytes from 'a' with length 'u

v: fresh
shield USCI-I2C\  freeze

\ End
