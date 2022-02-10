# The I2C protocol

## The Idea of I2C

|  |  |
 ------ | --------------------------------------------------------------- 
 ![i2c-logo](https://user-images.githubusercontent.com/11397265/120920357-a63c7d00-c6be-11eb-8f43-5287f7f82a9c.jpg) | [I2C](https://www.nxp.com/docs/en/user-guide/UM10204.pdf) is a synchronous serial protocol with two lines (SDA & SCL). It is used for clocks, memory, I/O-expanders, sensors, etc. An in-depth protocol description of the I2C signals can be found on the [I2C website](https://www.i2c-bus.org/) or [on wikipedia](https://en.wikipedia.org/wiki/I%C2%B2C).  
 SDA | Serial Data Line  
 SCL | Serial Clock Line  

**Note that the I2C-protocol uses 7-bits addresses and a read/write bit. 
In some cases an 8-bit address is mentioned, the original designer of the protocol, Philips, sometimes also falls into this trap.**  

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
Reserve RAM memory cells named: DEV  SUM  NACK?
Function: WAIT         ( -- )
  Delay for about 5 µsec.

Function: I2START      ( -- )
  Clock line high, wait, generate low flank on data line, wait

Function: I2ACK        ( -- )
  Clock line low, data line low, wait, 
  clock line high, wait

Function: I2NACK       ( -- )
  Clock line low, data line high, wait, 
  clock line high, wait

Function: I2ACK@       ( -- )
  Clock line low, data line high, wait, clock line high, wait
  Read status of data line, store true in NACK? if it is a nack, otherwise false

Function: BUS!         ( x -- )
  8 loop
    clock line low
    write bit-7 level of x to data line, wait
    clock line high, wait
    shift x left
  Discard byte, perform i2ack@

Function: {I2C-ADDR    ( +n -- )
    store +n + 1 in SUM,  perform i2start
    read dev, perform bus!


Higher level I2C access, hides internal details!

Function: I2C-ON       ( -- )
  Setup I/O-bits for two bidirectional 
  open collector lines with pull-up

Function: I2C}         ( -- )
  Clock line high, wait, generate high flank on data line, wait

Function: BUS@         ( -- y )
  Initialise y at zero
  8 loop
    shift y left
    Clock line low, data line high, wait, clock line high, wait
    read data line to bit-0 position of y
  Decrease SUM
  Sum not zero IF  perform i2ack  ELSE  perform i2nack  THEN

Function:  DEVICE!     ( dev -- )
  Multiply dev by 2,  AND result with 0xFE and store in DEV

Function: {I2C-WRITE   ( +n -- )
  Discard +n, perform i2start, read DEV, (bus!
  Read nack? issue error message when true

Function: {I2C-READ    ( +n -- )  
  Store +n in SUM, perform i2start, read DEV and set lowest bit, 
  Perform bus!, read nack? issue error message when true

Function: {DEVICE-OK?} ( -- fl ) \ Flag 'fl' is true when an ACK is received
  Perform {i2c-addr, perform i2c} 
  Read nack?, leave true when result is zero


\ Waiting for an EEPROM write to succeed is named acknowledge polling.
Function: {POLL}      ( -- )          Start loop {i2ack?} leave when ACK received
Function: {I2C-OUT    ( dev +n -- )   Store dev in DEV  perform {i2c-write
Function: {I2C-IN     ( dev +n -- )   Store dev in DEV  perform {i2c-read
Function: BUS!}       ( b -- )        Perform bus!, perform i2c}
Function: BUS@}       ( -- b )        Perform bus@, perform i2c}
Function: BUS-MOVE    ( a u -- )      Sent string of 'u' bytes from 'a' over the I2C-bus
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
Function: >PCF8574  ( byte dev-addr -- )
  perform device!  1  perform {i2c-write  perform bus!  perform i2c}

Function: PCF8574>  ( dev-addr -- byte )
  perform device!  1  perform {i2c-read  perform bus@  perform i2c}
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

: WAIT          ( -- )  \ Delay of 5 µsec. must be trimmed!
    ( true  drop ) ;

: I2START       ( -- )
  scl p1out *bis  scl p1dir *bic  wait
  sda p1dir *bis  sda p1out *bic  wait ;

: I2ACK         ( -- )
  scl p1out *bic  scl p1dir *bis
  sda p1out *bic  sda p1dir *bis  wait
  scl p1out *bis  scl p1dir *bic  wait ;

: I2NACK        ( -- )
  scl p1out *bic  scl p1dir *bis
  sda p1out *bis  sda p1dir *bic  wait
  scl p1out *bis  scl p1dir *bic  wait ;

: I2ACK@        ( -- flag )
  scl p1out *bic  scl p1dir *bis
  sda p1out *bis  sda p1dir *bic  wait
  scl p1out *bis  scl p1dir *bic  wait
  sda p1in bit* nack? ! ;

: BUS!          ( byte -- )
  8 0 do
    scl p1out *bic  scl p1dir *bis
    dup 80 and if
      sda p1out *bis  sda p1dir *bic
    else
      sda p1out *bic  sda p1dir *bis
    then
    wait  2*
    scl p1out *bis  scl p1dir *bic  wait
  loop  drop  i2ack@ ;

: {I2C-ADDR     ( +n -- )
  drop  i2start  dev @ bus! ; \ Start I2C write with address in DEV


\ Higher level I2C access, hides internal details!

\ Note that this setup is valid for an MSP430 with external pull-up resistors attached!
\ On hardware which is able to use an open collector (or open source) with pull-up
\ resistor, you should initialise this mode!
: I2C-ON        ( -- )
  io p1ren *bic         \ Deactivate pull-up/pull-down resistors
  io p1dir *bic         \ SDA & SCL are inputs
  io p1out *bis         \ Which start high
  io p1sel *bic         \ Guarantee normal i/o on MSP430
  io p1sel2 *bic ;

: BUS@          ( -- byte )
  0  8 0 do
    2*
    scl p1out *bic  scl p1dir *bis
    sda p1out *bis  sda p1dir *bic  wait
    sda p1in bit*  0= 0= 1 and  or
    scl p1out *bis  scl p1dir *bic  wait
  loop  -1 sum +!
  sum @ if  i2ack  else  i2nack  then ;

: I2C}          ( -- )
  scl p1out *bic  scl p1dir *bis
  sda p1out *bic  sda p1dir *bis  wait
  scl p1out *bis  scl p1dir *bic  wait
  sda p1out *bis  sda p1dir *bic ;

: DEVICE!       ( dev -- )  2* FE and dev ! ;
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
```

### I2C implementation examples

This example is for an 8-bit PCF8574 like I/O-expander:
```forth
: >PCF8574  ( byte dev-addr -- )
  device!  1 {i2c-write  bus!  i2c} ;

: PCF8574>  ( dev-addr -- byte )
  device!  1 {i2c-read  bus@  i2c} ;
```
More examples can be found in the file [i2c-examples.f](i2c-examples.f), for 
the EEPROM code you may adjust the address constant `#EEPROM`. Note that the
programming page size is different between EEPROM sizes. More info in the file.  
See the list of example words below.  

|  Word | Stack |  Description |
| ------ | ------------ | --------------------------------------------------------------- | 
| `I2C?` | ( dev -- ) | Show or device 'dev' is present on the bus | 
| `SCAN-I2C` | ( -- ) | Show a grid with all device addresses found on the bus |  
| `>PCF8574` | ( b dev -- ) | Write data to 8-bit I/O-extender with 'dev' address | 
| `PCF8574>` | ( dev -- b ) | Read data from 8-bit I/O-extender with 'dev' address | 
| `EC@` | ( addr -- b ) | Fetch byte from address in EEPROM | 
| `EC!` | ( b addr -- ) | Store byte to address in EEPROM | 
| `EDMP` | ( addr -- ) | Dump EEPROM memory from EEPROM 'addr' onward | 
| `WRITE-PAGE` | ( sa1 ta1 dev +n -- sa2 ta2 ) | Write '+n' bytes data from 'sa1' to 'ta1' in 'dev' etc. | 
| `WRITE-MEMORY` | ( sa ta u -- ) | Write 'u' bytes data from 'sa' to 'ta' |
| `EEFILL` | ( a u b -- ) | Fill 'u' EEPROM bytes from address 'a' with byte 'b' |

   ***

### Dedicated implementations

Have a look at the sub directories for implementations for different systems. 

- [MSP430](MSP430), bitbang & hardware specific I2C implementations for MSP430
- [GD32VF103](GD32VF), bitbang & hardware specific I2C implementations for the Risc-V
- [Raspberry3B+](Raspberry3B+), bitbang & hardware specific I2C implementation for BCM2835 
- [Generic device drivers](Device-drivers), EEPROM, OLED, LCD, Clocks, etc.


