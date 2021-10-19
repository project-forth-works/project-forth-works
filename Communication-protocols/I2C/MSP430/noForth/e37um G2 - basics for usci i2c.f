(* E37UM G2 - For noForth C&V 200202: USCI I2C on MSP430G2553 using pull-ups.
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

  User words: >DEV  {I2WRITE)  {I2WRITE  {I2READ)  {I2READ
              I2STOP}  I2IN  I2IN}  I2OUT  I2OUT}  I2C?
              SETUP-I2C  {I2ACK?}  {POLL}

  An example, first execute SETUP-I2C  After that the I2C is setup as a
  master. Sent byte 'b' to an I2C device with address 'a'.
    : >SLAVE    ( b a -- )  {i2write  i2out} ;
    : >PCF8574  ( b -- )    40 >slave ;

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

hex
code INT-OFF  C232 ,  4F00 ,  end-code

: SETUP-I2C ( -- )
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
    8 3 *bis ;   \ IFG2      Start with TX buffer empty

: I2C   ( fl -- )   ?abort ;        \ I2C error message

\ 04 = wait for data received to RX; 08 = wait for TX to be sent
\ : I2READY   ( bit -- )
\    80  begin
\        over 3 bit* if  2drop exit  then  
\    1- dup 0= until  true ?abort ;
code I2READY   ( bit -- )
    800 # day mov       \ 2048 to counter (day)
    begin,
        tos 3 & .b bit  cs? if,  sp )+ tos mov  next  then,
        #1 day sub
    0=? until,
chere >r  \ Reuse of code
    ip push
    ' i2c >body # ip mov
    next
end-code

\ 02 = wait for startcond. to finish; 04 = wait for stopcond. to finish
\ : I2DONE    ( bit -- )  \ wait until startcond. or stopcond. is done
\    200  begin
\        over 69 bit* 0= if  2drop exit  then  
\    1- dup 0= until  true ?abort ;
code I2DONE     ( bit -- )
    2000 # day mov      \ 8192 to counter (day)
    begin,
        tos 69 & .b bit  cc? if,  sp )+ tos mov  next  then,
        #1 day sub
    0=? until,
    r> jmp
end-code

: I2START   ( -- )      2 69 *bis ;         \ UCB0CTL1
: I2STOP    ( -- )      4 69 *bis ;         \ UCB0CTL1
: I2NACK    ( -- )      8 69 *bis ;         \ UCB0CTL1
: I2ACK?    ( -- fl )   8 6D bit* 0= ;      \ UCB0STAT
: I2OUT     ( b -- )    6F c!  8 i2ready ;  \ TX to shiftreg.
: I2IN      ( -- b )    4 i2ready  6E c@ ;  \ UCB0RXBUF Read databyte
: >DEV      ( a -- )    2/ 11A c! ;         \ UCB0I2CSA Set I2C device address
: I2STOP}   ( -- )      i2stop  4 i2done ;  \ Stop condition & check
: I2OUT}    ( b -- )    i2out  i2stop} ;    \ Write last I2C databyte!
: I2IN}     ( -- b )    i2stop  i2in  4 i2done ; \ Read last I2C databyte!
: {I2WRITE) ( -- )      12 69 *bis  8 i2ready ; \ UCB0CTL1  Send start condition

: {I2READ)  ( -- )          \ Send I2C device address for reading
    10 69 *bic  2 69 *bis   \ UCB0CTL1  Setup read & start
    8 i2ready  2 i2done ;   \ Wait for start condition & ack

: {I2WRITE  ( b a -- )      \ Send I2C device address for writing
    >dev  {i2write)  6F c!  \ Set dev. addr, send start condition & store 1st databyte
    2 i2done  8 i2ready ;   \ Wait for start cond. & send first data to TX

: {I2READ   ( a -- )        \ Set and send I2C device address for reading
    >dev   {i2read) ;       \ UCB0I2CSA Set slave address

: {I2ACK?}  ( -- fl )       \ Flag 'fl' is true when in ACK is received
    {i2write)  i2stop}  i2ack? ;

: {POLL}    ( -- )      begin  {i2ack?} until ; \ Wait until an ACK is received


\ Prints -1 if device with address 'a' is present on I2C-bus otherwise 0.
: I2C?      ( a -- )        \ Result is true when device 'a' is on I2C bus
    setup-i2c >dev {i2ack?} . ; \ Address device, present?

shield USCI-I2C\  freeze

\ End
