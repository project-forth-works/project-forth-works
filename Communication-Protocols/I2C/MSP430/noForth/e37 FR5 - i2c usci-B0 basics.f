(* FR5xxx, eUSCI I2C on MSP430FR5xxx using external pull-ups.
   The bitrate values are for a 16 MHz DCO, for 8 MHz they must be halved.
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
  2500 Hz, that is a bitrate divisor of 6400!!!

  User words:  I2C-ON  {I2C-WRITE  {I2C-READ   I2C}
               BUS@  BUS!  DEVICE!  {DEVICE-OK?}
  Additional:  {I2C-OUT  {I2C-IN  {POLL}  BUS!}  BUS@}  BUS-MOVE

  An example, first execute I2C-ON  After that the I2C is setup as a
  master. Sent byte 'b' to an I2C device with address 'a'.
    : >SLAVE    ( b a -- )  1 {i2c-write  bus!  i2c} ;
    : >PCF8574  ( b -- )    20 >slave ;

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
code INT-OFF    ( -- )      C232 ,  4F00 ,  end-code
: I2C-CLEAR     ( -- )      2 66C ! ;   \ UCB0IFG  reset USCI
: ?I2C          ( fl -- )   ?abort ;    \ I2C error message

\ 01 = wait for data received to RX; 02 = wait for TX to be sent
\ : I2C-WAIT       ( bit -- )
\     80  begin
\      over 66C bit* if  2drop exit  then \ UCB0IFG
\  1- dup 0= until  true ?abort ;
code I2C-WAIT   ( bit -- )
    200 # day mov       \ Timeout
    begin,
        tos 66C & .b bit  cs? if,  sp )+ tos mov  next  then, \ UCB0IFG
        #1 day sub
    0=? until,
chere >r  \ Reuse error message
    ip push
    ' ?I2C >body # ip mov
    next
end-code

\ 02 = wait for startcond. to finish; 04 = wait for stopcond. to finish
\ : I2C-DONE      ( bit -- )  \ Wait until startcond. or stopcond. is done
\    80  begin
\        over 640 bit* 0= if  2drop exit  then \ UCB0CTLW0
\    1- dup 0= until  true ?abort ;
code I2C-DONE     ( bit -- )
    200 # day mov       \ Timeout!
    begin,
        tos 640 & .b bit  cc? if,  sp )+ tos mov  next  then, \ UCB0CTLW0
        #1 day sub
    0=? until,
    r> jmp
end-code

value SUM  value 1ST?   \ Hold number of bytes to send & flag first data byte
v: extra definitions \ Basic I2C bus primitives
: I2C-ON    ( -- )
    int-off
    1 640 **bis     \ UCB0CTLW0  USCI in reset state
    C0 20A *bic     \ P1SEL0     I2C to pins
    C0 20C *bis     \ P1SEL1
    FD1 640 !       \ UCB0CTLW0  I2C master transmitter using SMCLK
\   dm 16 646 !     \ UCB0BRW    Bitrate 1 MHz with 16 MHz DCO
\   dm 20 646 !     \ UCB0BRW    Bitrate 800 KHz with 16 MHz DCO
\    dm 40 646 !     \ UCB0BRW    Bitrate 400 KHz with 16 MHz DCO
    dm 80 646 !     \ UCB0BRW    Bitrate 200 KHz with 16 MHz DCO
\   dm 160 646 !    \ UCB0BRW    Bitrate 100 KHz with 16 MHz DCO
    1 640 **bic     \ UCB0CTLW0  Resume eUSCI
    i2c-clear ;     \            Start with TX buffer empty

: DEVICE!       ( dev -- )      7F and  660 c! ; \ UCB0I2CSA  Set I2C device (or target) address

: BUS@          ( -- b )            \ Read databyte 'b' from I2C-bus
    -1 +to sum  sum 0= if  4 640 **bis  then
    1 i2c-wait  64C c@ ;            \ UCB0RXBUF 

: BUS!          ( b -- )            \ Output 'b' on I2C-bus
    64E c!  1st? if  0 to 1st?  2 i2c-done  then \ UCB0TXBUF
    -1 +to sum  2 i2c-wait  sum 0= if  4 640 **bis  then ; \ UCB0CTLW0 

: {I2C-WRITE    ( +n -- )           \ (Repeated)start for I2C write, keep record length
    to sum  -1 to 1st?  12 640 **bis \ UCB0CTLW0  
    2 i2c-wait  noop noop ;         \ eUSCI needs a short delay here!

: {I2C-READ     ( +n -- )           \ (Repeated)start for I2C read, keep record length
    to sum  10 640 **bic            \ UCB0CTLW0
    2 640 **bis  2 i2c-done ;       \ UCB0CTLW0
    
: I2C}          ( -- )              \ End I2C bus transfer
     4 640 **bis  4 i2c-done  0 to 1st? ; \ UCB0CTLW0

: {DEVICE-OK?}  ( -- fl )           \ Flag 'fl' is true when an ACK is received
    i2c-clear  0 {i2c-write  i2c}  20 66C bit** 0= ; \ UCB0IFG


\ Possible extensions:
\ This routine may be used when writing to EEPROM or alike memory devices.
\ The waiting for the write to succeed is named acknowledge polling.
: {POLL}        ( -- )          begin  {device-ok?} until ; \ Wait until addressed device is ready
: {I2C-OUT      ( dev +n -- )   swap device!  {i2c-write ;  \ Open I2C device for writing
: {I2C-IN       ( dev +n -- )   swap device!  {i2c-read ;   \ Open I2C device for reading
: BUS@}         ( -- b )        bus@  i2c} ;                \ Read last I2C databyte!
: BUS!}         ( b -- )        bus!  i2c} ;                \ Write last I2C data byte
: BUS-MOVE      ( a u -- )      bounds ?do i c@ bus! loop ; \ Send string of bytes from 'a' with length 'u

v: fresh
shield USCI-I2C\  freeze

\ End ;;;
