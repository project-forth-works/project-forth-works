(* E37 FR5 - For noForth C&V Bit-bang I2C routines for MSP430FR5xxx code variant
   This implementation is without clockbit stretching!!! Basic building blocks

  Connect the I2C-print from the Forth users group or any other module
  with I2C compatible chip{s} and connect the power lines. P1.6 to SDA and
  P1.7 to SCL, note that two 10k pullup resistors has te be mounted, that's it.
  User words:  >DEV  {I2WRITE)  {I2WRITE  {I2READ)  {I2READ
               I2STOP}  I2IN  I2IN}  I2OUT  I2OUT}  I2C?
               SETUP-I2C  {I2ACK?}  {POLL}

  10 200 - P1IN   Input bits
  10 202 - P1OUT  Output bits
  10 204 - P1DIR  Direction bits
  10 206 - P1REN  Resistor enable bits
  10 20A - P1SEL0 Function select-0 bits
  10 20C - P1SEL1 Function select-1 bits
  ...
  10 218 - P1IES  Interrupt edge select bits
  10 21A - P1IE   Interrupt enable bits
  10 21C - P1IFG  Interrupt flag bits
 *)

hex  v: inside also definitions
value DEV
: SETUP-I2C     ( -- )
    C0 206 *bic  C0 204 *bis  C0 202 *bis  C0 20C *bic ; \ P1REN, P1DIR, P1OUT, P1SEL1

\ Minimal period is 5 us, is about 100 kHz clock
routine WAIT     ( -- adr )
    12 # moon mov   \ 12 is about 5 us at 16 MHz
\   9 # moon mov    \ 9 is about 2.5 us at 16 MHz
    begin, #1 moon sub =? until,
    rp )+ pc mov              ( ret )
end-code

\ Give I2C start condition
code I2START    ( -- )
    80 # 202 & .b bis  80 # 204 & .b bic  \ P1OUT, P1DIR  set-scl
    wait # call
    40 # 204 & .b bis  40 # 202 & .b bic  \ P1DIR, P1OUT  clr-sda
    wait # call
    next
end-code

\ Give I2C stop condition
code I2STOP     ( -- )
    80 # 202 & .b bic  80 # 204 & .b bis  \ P1OUT, P1DIR  clr-scl
    40 # 202 & .b bic  40 # 204 & .b bis  \ P1DIR, P1OUT  clr-sda
    wait # call
    80 # 202 & .b bis  80 # 204 & .b bic  \ P1OUT, P1DIR  set-scl
    wait # call
    40 # 202 & .b bis  40 # 204 & .b bic  \ P1OUT, P1DIR  set-sda
    next
end-code

\ Generate I2C ACK
code I2ACK      ( -- )
    80 # 202 & .b bic  80 # 204 & .b bis  \ P1OUT, P1DIR  clr-scl
    40 # 202 & .b bic  40 # 204 & .b bis  \ P1DIR, P1OUT  clr-sda
    wait # call
    80 # 202 & .b bis  80 # 204 & .b bic  \ P1OUT, P1DIR  set-scl
    wait # call
    next
end-code

\ Generate I2C noACK
code I2NACK     ( -- )
    80 # 202 & .b bic  80 # 204 & .b bis  \ P1OUT, P1DIR  clr-scl
    40 # 202 & .b bis  40 # 204 & .b bic  \ P1OUT, P1DIR  set-sda
    wait # call
    80 # 202 & .b bis  80 # 204 & .b bic  \ P1OUT, P1DIR  set-scl
    wait # call
    next
end-code

\ Flag 'f' is true if an I2C ACK is received otherwise false
code I2ACK?     ( -- f )
    80 # 202 & .b bic  80 # 204 & .b bis  \ P1OUT, P1DIR  clr-scl
    40 # 202 & .b bis  40 # 204 & .b bic  \ P1OUT, P1DIR  set-sda
    wait # call
    80 # 202 & .b bis  80 # 204 & .b bic  \ P1OUT, P1DIR  set-scl
    wait # call
    tos sp -) mov
    40 # 200 & .b bit                     \ P1IN  test ack
    tos tos subc                          \ Make flag
    next
end-code

\ Send the byte b out on the I2C bus
code (I2OUT     ( b -- )
    tos w mov
    sp )+ tos mov
    #8 day mov
    begin,
        80 # 202 & .b bic  80 # 204 & .b bis  \ P1OUT, P1DIR  clr-scl
        w w .b add  cs? if,
          40 # 202 & .b bis  40 # 204 & .b bic \ P1OUT, P1DIR  set-sda
        else,
          40 # 202 & .b bic  40 # 204 & .b bis \ P1DIR, P1OUT  clr-sda
        then,
        wait # call
        80 # 202 & .b bis  80 # 204 & .b bic  \ P1OUT, P1DIR  set-scl
        wait # call
        #1 day sub
    =? until,       \ ready?
    next
end-code

\ Receive the byte b from the I2C bus
code (I2IN      ( -- b )
    tos sp -) mov
    #0 tos mov
    #8 day mov
    begin,
        80 # 202 & .b bic  80 # 204 & .b bis  \ P1OUT, P1DIR  clr-scl
        40 # 202 & .b bis  40 # 204 & .b bic  \ P1OUT, P1DIR  set-sda)
        wait # call
        80 # 202 & .b bis  80 # 204 & .b bic  \ P1OUT, P1DIR  set-scl
        wait # call
        40 # 200 & .b bit                     \ P1IN  sda-in
        tos tos addc                          \ Add bit to 'b'
        #1 day sub
    =? until,       \ ready?
    next
end-code

v: extra definitions
: I2OUT     ( b -- )    (i2out  i2ack? drop ; \ Write byte & drop Ack
: I2IN      ( -- b )    (i2in  i2ack ;        \ Read byte & give Ack


\ : >DEV      ( a -- )    FE and  to dev ;      \ Set device address
code >DEV   ( a -- )
    FE # tos bia  tos adr dev & mov  sp )+ tos mov  next
end-code

: I2STOP}   ( -- )      i2nack  i2stop ;
: I2OUT}    ( b -- )    i2out  i2stop ;
: I2IN}     ( -- b )    (i2in  i2stop} ;
: {I2WRITE) ( -- )      i2start  dev (i2out ;   \ Start I2C write
: {I2READ)  ( -- )      i2start  dev 1+ i2out ; \ Start read to device

: {I2WRITE     ( b a -- )
    >dev  {i2write)  i2ack? 0= ?abort  i2out ;  \ Start write to dev 'a'

: {I2READ      ( a -- )    >dev  {i2read) ;     \ Start read to dev. 'a'

: {I2ACK?}  ( -- fl )           \ Flag 'fl' is true when an ACK is received
    {i2write)  i2ack?  i2stop ;

\ This routine may be used when writing to EEPROM memory devices.
\ The waiting for the write to succeed is named acknowledge polling.
: {POLL}        ( -- )      begin  {i2ack?} until ; \ Wait until ACK received

\ Prints -1 if device with address 'a' is present on I2C-bus otherwise 0.
: I2C?          ( a -- )
    setup-i2c >dev {i2ack?} . ;

v: fresh definitions
shield BB-I2C\  freeze

\ End ;;;
