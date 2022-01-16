# The I2C protocol

## The Idea of I2C

|  |  |
 ------ | --------------------------------------------------------------- 
 ![i2c-logo](https://user-images.githubusercontent.com/11397265/120920357-a63c7d00-c6be-11eb-8f43-5287f7f82a9c.jpg) | [I2C](https://www.nxp.com/docs/en/user-guide/UM10204.pdf) is a synchronous serial protocol with two lines (SDA & SCL). It is used for clocks, memory, I/O-expanders, sensors, etc. A in depth protocol description of the I2C signals can be found on the [I2C website](https://www.i2c-bus.org/) or [on wikipedia](https://en.wikipedia.org/wiki/I%C2%B2C).  
 SDA | Serial Data Line  
 SCL | Serial Clock Line  

**Note that the I2C-protocol uses 7-bits addresses and a read/write bit. 
In some cases an 8-bit address is mentioned, the original designer of the protocol Phillips sometimes also falls into this trap.**  

  ***

### The low level I2C states for a single master are in short:

- Start condition
- Address a device (for read or write)
    A device may stretch the clock cycle to allow for a slow response  
    When a device exists and is ready, it responds with an ACK
- Read or write one or more data bytes
    After each byte an ACK is received, a NAK is received when it is the last byte
- Stop condition

![t30i - i2c read and write with pcf8574](https://user-images.githubusercontent.com/11397265/120920036-121de600-c6bd-11eb-9e0c-0ab8664f9c47.jpg "I2C logic analyzer tracks")
**A read and a write to a PCF8574**

  ***
### Pseudo code for low level bitbang I2C ###

This pseudo code is without the use of clock streching. This is only necessary when you use a multi master system or I2C slaves implemented on slow microcontrollers.
Note that the used example works on on a chip with a push/pull output ports

```
Function: I2C-SETUP  ( -- )
  Setup I/O-bits for two bidirectional 
  open collector lines with pull-up

Function: WAIT ( -- )
  Delay for about 5 µsec.

Function: I2START ( -- )
  Clock line high, wait, data line low flank, wait

Function: I2STOP} ( -- )
  Clock line high, wait, data line high flank, wait

Function: I2ACK  ( -- )
  Clock line low, data line low, wait, 
  clock line high, wait, clock line low

Function: I2NACK ( -- )
  Clock line low, data line high, wait, 
  clock line high, wait, clock line low

Function: I2ACK? ( -- flag )
  Clock line low, data line high, wait, clock line high, wait
  Read status of data line, leave true if it is an ack,
  otherwise false, wait, clock line low

Function: (I2OUT ( x -- )
  8 loop
    clock line low
    write bit-7 level of x to data line, wait
    clock line high, wait
    shift x left
  Discard byte

Function: (I2IN ( -- y )
  8 loop
    shift y left
    Clock line low, data line high, wait, clock line high, wait
    read data line to bit-0 position of x
    
Function: I2OUT     ( b -- )    (i2out, i2ack?, discard flag
Function: I2IN      ( -- b )    (i2in, i2ack
Function: I2OUT}    ( b -- )    i2out, i2stop}
Function: I2IN}     ( -- b )    (i2in, i2nack, i2stop}

Higher level I2C access, hides internal details!
RAM memory cell named: DEV

Function: >DEV      ( a -- )
  AND device-addres with 0xFE and store in DEV

Function: {I2WRITE) ( -- )
  i2start, read DEV, (i2out

Function: {I2READ) ( -- )  
  i2start, read DEV and set lowest bit, 
  (i2out, i2ack? issue error message when false

Function: {I2WRITE ( byte device-address -- )
  >dev, {i2write), i2ack? issue error message when false
  (i2out, i2ack? issue error message when false

Function: {I2READ ( device-address -- )
  >dev, {i2cread)

Function: {I2ACK?}  ( -- fl )           \ Flag 'fl' is true when an ACK is received
  {i2write), i2ack?, i2stop}

( This routine may be used when writing to EEPROM memory devices )
(The waiting for the write to succeed is named acknowledge polling )
Function: {POLL}    ( -- )
  Start loop {i2ack?} leave when ACK received
    
( Prints -1 if device with address 'a' is present on I2C-bus otherwise 0 )
Function: I2C?          ( a -- )
  i2c-setup, >dev, {i2ack?} print presence flag

```
  ***
### When looked to I2C from a higher level it's access is:

1) Simple write action
    - Open I2C-bus for write access to bus-address and output one byte to I2C-bus
    - Close I2C-bus access

2) Multiple write action to a devices register or address:
    - Open I2C-bus for write access to bus-address and output one byte to I2C-bus
    - Output one ore more byte(s) to I2C-bus (with auto increment)
    - Close I2C-bus access

3) A read action from a devices register or address:
    - Open I2C-bus for write access to bus-address and output the address byte to I2C-bus
    - Open I2C-bus for reading (Repeated start)
    - Read one byte from I2C-bus
    - Close I2C-bus access

4) Multiple read action from a devices register or address:
    - Open I2C-bus for write access to bus-address and output the address byte to I2C-bus
    - Open I2C-bus for reading (Repeated start)
    - Read one or more byte(s) from I2C-bus (with auto increment)
    - Close I2C-bus access

### I2C pseudo code with high level factorisation

```
Function: PCF8574-WRITE ( byte dev-addr -- )
  {i2c-write  i2c-stop}

Function: PCF8574-READ  ( dev-addr -- byte )
  {i2c-read  i2c-in}
```
  ***
### Generic Forth low level part of bitbang example

This example has the I2C interface pins connected like this.
```
SDA (Serial DAta line)          = bit-7
SCL (Serial CLock line)         = bit-6
```

**The used addresses are for port-1 of the MSP430G2553:**

Note that the MSP430 controller series does not have the easiest I/O structure to implement a bitbang version of I2C! 
This is because it only has push/pull outputs and I2C needs an open collector (or open drain) output. So this example
code mimics open collector ports.

![Minimal forth example reading EEPROM](https://user-images.githubusercontent.com/11397265/123260134-83e79380-d4f5-11eb-86e8-8f3c6d46b4ba.jpg)  
**Read byte from I2C EEPROM**
  ***
  
## Generic Forth example

```forth
Extra words: ABORT"  TUCK  

Words with hardware dependencies:
: *BIS  ( mask addr -- )        tuck c@ or  swap c! ; 
: *BIC  ( mask addr -- )        >r  invert  r@ c@ and  r> c! ;
: BIT*  ( mask addr -- b )      c@ and ;

20 constant P1IN        \ Port-1 input register
21 constant P1OUT       \ Port-1 output register
22 constant P1DIR       \ Port-1 direction register
26 constant P1SEL       \ Port-1 function select
27 constant P1REN       \ Port-1 resistor enable (pullup/pulldown)
42 constant P1SEL2      \ Port-1 function select-2

40 constant SCL         \ I2C clock line 
80 constant SDA         \ I2C data line
SCL SDA or constant IO  \ I2C bus lines

: I2C-SETUP ( -- )
  io p1ren *bic         \ Activate resistors
  io p1dir *bis         \ SDA & ACL are inputs
  io p1out *bis         \ With pullup
  io p1sel *bic         \ Guarantee normal i/o
  io p1sel2 *bic ;

: WAIT      ( -- )      \ Delay of 5 µsec. must be trimmed!
    ( true  drop ) ;

: I2START ( -- )
  scl p1out *bis  scl p1dir *bic  wait
  sda p1dir *bis  sda p1out *bic  wait ;

: I2STOP} ( -- )
  scl p1out *bic  scl p1dir *bis
  sda p1out *bic  sda p1dir *bis  wait
  scl p1out *bis  scl p1dir *bic  wait
  sda p1out *bis  sda p1dir *bic ;

: I2ACK   ( -- )
  scl p1out *bic  scl p1dir *bis
  sda p1out *bic  sda p1dir *bis  wait
  scl p1out *bis  scl p1dir *bic  wait
  scl p1out *bic  scl p1dir *bis ;

: I2NACK  ( -- )
  scl p1out *bic  scl p1dir *bis
  sda p1out *bis  sda p1dir *bic  wait
  scl p1out *bis  scl p1dir *bic  wait
  scl p1out *bic  scl p1dir *bis ;

: I2ACK?  ( -- flag )
  scl p1out *bic  scl p1dir *bis
  sda p1out *bis  sda p1dir *bic  wait
  scl p1out *bis  scl p1dir *bic  wait
  sda p1in bit* 0=
  scl p1out *bic  scl p1dir *bis ;

: (I2OUT  ( byte -- )
  8 0 do
    scl p1out *bic  scl p1dir *bis
    dup 80 and if
      sda p1out *bis  sda p1dir *bic
    else
      sda p1out *bic  sda p1dir *bis
    then
    wait  2*
    scl p1out *bis  scl p1dir *bic  wait
  loop  drop ;

: (I2IN   ( -- byte )
  0  8 0 do
    2*
    scl p1out *bic  scl p1dir *bis
    sda p1out *bis  sda p1dir *bic  wait
    sda p1in bit*  0= 0= 1 and  or
    scl p1out *bis  scl p1dir *bic  wait
  loop ;

: I2OUT     ( b -- )    (i2out i2ack? drop ;
: I2IN      ( -- b )    (i2in  i2ack ;
: I2OUT}    ( b -- )    i2out  i2stop} ;
: I2IN}     ( -- b )    (i2in  i2nack  i2stop} ;

\ Higher level I2C access, hides internal details!
variable DEV
: >DEV      ( a -- )    FE and dev ! ;

: {I2WRITE)     ( -- )      \ Start I2C write with device in DEV
  i2start  dev @ (i2out ;   \ Used for repeated start
  
: {I2READ)      ( -- )      \ Start read to device in DEV
  i2start  dev @ 1+ (i2out  \ Used for repeated start
  i2ack? 0= abort" Ack error " ; 

: {I2WRITE  ( byte dev-addr -- )
  >dev  {i2write)  i2ack? 0= abort" Ack error "
  (i2out i2ack? 0= abort" Ack error " ;

: {I2READ   ( dev-addr -- )
  >dev  {i2read) ;

: {I2ACK?}  ( -- fl )           \ Flag 'fl' is true when an ACK is received
    {i2write)  i2ack?  i2stop} ;

\ This routine may be used when writing to EEPROM memory devices.
\ The waiting for the write to succeed is named acknowledge polling.
: {POLL}    ( -- )      begin  {i2ack?} until ; \ Wait until ACK received

\ Prints -1 if device with address 'a' is present on I2C-bus otherwise 0.
: I2C?          ( a -- )
    i2c-setup  >dev  {i2ack?} . ;
```

### I2C Generic Forth with high level factorisation

This example is for an 8-bit PCF8574 like I/O-expander:
```forth
: PCF8574-WRITE ( byte dev-addr -- )
  {i2write  i2stop} ;

: PCF8574-READ  ( dev-addr -- byte )
  {i2read  i2in} ;
```

### Implementations

Have a look at the sub directories for implementations for different systems. 

- [MSP430](MSP430), bitbang & hardware specific I2C implementations
- [GD32VF103](GD32VF), bitbang I2C implementations for the Risc-V
- [Raspberry3B+](Raspberry3B+), harware specific I2C implementation for broadcom 
- [Generic device drivers](Device-drivers), EEPROM, OLED, LCD, Clocks, etc.


