(* E37F5UM - For noForth C&V FR5xxx, eUSCI I2C on MSP430FR5xxx using pull-ups.
   The bitrate values are for an 8 MHz DCO, for 16 MHz they should be doubled.
   This is a ported version, for the FRAM MSP devices, code Vsn 1.10

  The most hard to find data are those for the selection registers.
  To find the data for the selection register of Port-1 here 20A and
  20C you have to go to the "Port Schematics". For P1.6 and P1.7 these
  are page 88 and 89 of SLASEC4B.PDF These tables say which function
  will be on each I/O-bit at a specific setting of the registers.

  Address 20A - P1SEL0, port-1 selection register 0
  Address 20C - P1SEL1, port-1 selection register 1

  A description of eUSCI as I2C can be found in SLAU445H.PDF from page
  626 to page 664, the register description starts at page 648. The
  UCB0CTLW0 register selects the SPI- or I2C-mode we are in.

  Connect the I2C-print from the Forth users group or any other module
  with I2C chips. Connect the power lines, P1.6 to SDA and P1.7 to SCL,
  note that two 10k pullup resistors has te be mounted and that's it.
  For RUNNER2 and SHOW we need a second PCF8574 with eight switches
  and a different I2C-address. The minimum I2C clock for this code is
  2500 Hz, that is a bitrate divisor of 6400.

  User words: >DEV  {I2WRITE)  {I2WRITE  {I2READ)  {I2READ
              I2STOP}  I2IN  I2IN}  I2OUT  I2OUT}  I2C?
              I2C-SETUP  {I2ACK?}  {POLL}

  An example, first execute I2C-SETUP  After that the I2C is setup as a
  master. Sent byte 'b' to an I2C device with address 'a'.
    : >SLAVE    ( b a -- )  {i2write  i2out} ;
    : >PCF8574  ( b -- )    40 >slave ;

 Addresses  - Labels       - Bit patterns
 1CC   15C  - WDTCL        - Off already
 20A   20A  - P1SEL        - 00C
 20C   20C  - P1SEL2       - 00C
 540   640  - UCB0CTLW0    - FF1
 542   642  - UCB0CTLW1    - 000
 546   646  - UCB0BRW      - 050
 548   648  - UCB0STATW    - sss eUSCI status
 54C   64C  - UCB0RXBUF    - rrr RX Data
 54E   64E  - UCB0TXBUF    - ttt TX Data
 554   654  - UCB0I2C0A    - ooo NC
 560   660  - UCB0I2CSA    - 042 /2
 56A   66A  - UCB0CIE      - 000 eUSCI interrupt enable
 56C   66C  - UCBOIFG      - 002 = TX ready, 001 = RX ready

Label    P1  P2  P3  Function
------------------------------------------------
PxIN     200 201 220 Input
PxOUT    202 203 222 Output
PxDIR    204 205 224 Direction
PxREN    206 207 226 Resistor enable
PxSEL0   20A 20B 22A Select 0
PxSEL1   20C 20D 22C Select 1
P1IV     20E 21E 22E Interrupt vector word
P1SELC   210 211 230 Complement selection
PxIES    218 219 238 Interrupt edge select
PxIE     21A 21B 23A Interrupt on
PxIFG    21C 21D 23C Interrupt flag

FR2433  - UCB0 P1.2 = SDA, P1.3 = SCL
FR2355  - UCB0 P1.2 = SDA, P1.3 = SCL, UCB1 P4.6 = SDA, P4.7 = SCL
FR5949  - UCB0 P1.6 = SDA, P1.7 = SCL
FR5969  - UCB0 P1.6 = SDA, P1.7 = SCL
FR5994  - UCB0 P1.6 = SDA, P1.7 = SCL, UCB1 P5.0 = SDA, P5.1 = SCL
        - UCB2 P7.0 = SDA, P7.1 = SCL, UCB3 P6.4 = SDA, P6.5 = SCL

*)

hex  v: inside also  definitions
code INT-OFF  C232 ,  4F00 ,  end-code

: I2C-SETUP ( -- )
    int-off
    C0 20A *bic     \ P1SEL0     I2C to pins
    C0 20C *bis     \ P1SEL1
    01 640 **bis    \ UCB0CTLW0  reset eUSCI
    FF1 640 !       \ UCB0CTLW0  I2C master using SMCLK
\   dm 40 646 !     \ UCB0BRW    Bitrate 400 KHz with 16 MHz DCO
\   dm 80 646 !     \ UCB0BRW    Bitrate 200 KHz with 16 MHz DCO
    dm 160 646 !    \ UCB0BRW    Bitrate 100 KHz with 16 MHz DCO
    01 640 **bic    \ UCB0CTLW0  Resume eUSCI
    02 66C **bis ;  \ UCB0IFG    Start with TX buffer empty

: I2CA  ( fl -- )   ?abort ;        \ I2C error message

\ 01 = wait for data received to RX; 02 = wait for TX to be sent
\ : I2READY   ( bit -- )
\     80  begin
\      over 66C bit* if  2drop exit  then  ( UCB0IFG )
\  1- dup 0= until  true ?abort ;
code I2READY   ( bit -- )
    400 # day mov       \ 1024 to counter (day)
    begin,
        tos 66C & .b bit  cs? if,  sp )+ tos mov  next  then,
        #1 day sub
    0=? until,
chere >r  \ Reuse of code
    ip push
    ' i2ca >body # ip mov
    next
end-code

\ 02 = wait for startcond. to finish; 04 = wait for stopcond. to finish
\ : I2DONE    ( bit -- )  \ wait until startcond. or stopcond. is done
\    200  begin
\        over 640 bit* 0= if  2drop exit  then  ( UCB0CTLW0 )
\    1- dup 0= until  true ?abort ;
code I2DONE     ( bit -- )
    2000 # day mov      \ 8192 to counter (day)
    begin,
        tos 640 & .b bit  cc? if,  sp )+ tos mov  next  then,
        #1 day sub
    0=? until,
    r> jmp
end-code

v: extra definitions
: I2START   ( -- )      2 640 **bis ;       \ UCB0CTLW0
: I2STOP    ( -- )      4 640 **bis ;       \ UCB0CTLW0
: I2NACK    ( -- )      8 640 **bis ;       \ UCB0CTLW0
: I2ACK?    ( -- fl )   20 66C bit* 0= ;    \ UCB0IFG
: I2OUT     ( b -- )    64E c!  2 i2ready ; \ UCB0TXBUF TX to shiftreg.
: I2IN      ( -- b )    1 i2ready  64C c@ ; \ UCB0RXBUF Read databyte
: >DEV      ( a -- )    2/ 660 c! ;         \ UCB0I2CSA Set I2C device address
: I2STOP}   ( -- )      i2stop  4 i2done ;  \ Stop condition & check
: I2OUT}    ( b -- )    i2out  i2stop} ;    \ Write last I2C databyte!
: I2IN}     ( -- b )    i2stop i2in 4 i2done ; \ Read last I2C databyte!
: {I2WRITE) ( -- )      12 640 **bis 2 i2ready ; \ UCB0CTLW0  Start I2C write

: {I2READ)  ( -- )              \ Send I2C device address for reading
    10 640 **bic  2 640 **bis   \ UCB0CTLW0  Setup read & start
    2 i2ready  2 i2done ;       \ Wait for start condition & ack

: {I2WRITE  ( b a -- )          \ Send I2C device address for writing
    >dev  {i2write)  64E c!     \ Set dev. addr, send start condition & store 1st databyte
    2 i2done  2 i2ready ;       \ UCB0TXBUF Send first data to TX

: {I2READ   ( a -- )            \ Set and send I2C device address for reading
    >dev   {i2read) ;           \ UCB0I2CSA Set slave address

: {I2ACK?}  ( -- fl )           \ Flag 'fl' is true when in ACK is received
    {i2write)  i2stop}  i2ack? ;

\ This routine may be used when writing to EEPROM memory devices.
\ The waiting for the write to succeed is named acknowledge polling.
: {POLL}    ( -- )      begin  {i2ack?} until ; \ Wait until an ACK is received


\ Prints -1 if device with address 'a' is present on I2C-bus otherwise 0.
: I2C?      ( a -- )            \ Result is true when device 'a' is on I2C bus
    i2c-setup >dev {i2ack?} . ; \ Address device, present?

v: fresh definitions
shield USCI-I2C\  freeze

\ End ;;;
