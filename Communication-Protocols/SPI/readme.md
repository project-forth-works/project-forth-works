# The SPI protocol

### The Idea of SPI

SPI is a synchronous serial protocol with three to four lines, it  
is used for (LCD) displays, (Flash) memory chips, SD-cards, etc.

```
1. MOSI     Master Out Slave In
2. MISO     Master In  Slave Out
3. CLK      Clock
4. CE       Chip Enable (also called SS)
```

This example has the clock signal low at rest, the data is transmitted at  
a low to high clock pulse. The data is 8-bits long, the highest bit (MSB) is sent first. Here we have shown one of four modes. They differ in the timings of raising or falling edges of the clock pulses.

![nrf24l01 read register 00](https://user-images.githubusercontent.com/11397265/119979076-bbc4ef00-bfba-11eb-8c2f-2d682f33ed0d.jpg "SPI logic analyzer tracks")

It is possible to configure in many variants but this version is common. (The clock rate is arbitrary. If you like you can send bytes just by tipping wires by hand. Ofcourse there is a maximum speed. It depends on the speed of the peripheral hardware (data sheet)) and/or the maximum speed your CPU can handle.  
More information about SPI [on this wikipedia page](https://en.wikipedia.org/wiki/Serial_Peripheral_Interface).
Bitbang and hardware specific SPI will both be among the specific implementation examples.
**Note that! All numbers are in hexadecimal**.

### Pseudo code for (bitbang) SPI input & output
```
Function: SPI-ON  ( -- )
  Initialise MOSI & SCK as output, MISO as input
```

Name | Function
 :--------: | ------------ 
`SPI-I/O `|Send 8-bit value x and receive 8-bit value y via SPI  
`SPI-OUT `|Send the 8-bit value byte via SPI  
`SPI-IN  `|Receive the 8-bit value byte via SPI  
`{SPI    `|Enable access to an SPI device  
`SPI}    `|Disable access to an SPI device  
```
Function: SPI-I/O ( x -- y )
8 loop
  write bit-7 level from x to I/O port
  shift x left
  rising clock pulse on I/O port
  read bit-6 level from I/O port
  Move bit-6 to bit-0 position
  Add bit-0 to y
  falling clock pulse on I/O port
Leave only low 8-bits

Function: SPI-OUT  ( byte -- )
    Send byte using SPI-I/O
    discard received byte

Function: SPI-IN   ( -- byte )
    Send dummy byte using SPI-I/O
    
Function: {SPI      ( -- ) 
  Clear chip enable bit on I/O port

Function: SPI}      ( -- )
  Set chip enable bit on I/O port
```

### Generic Forth bitbang example 
This example has the SPI interface pins connected like this.
```
MOSI (Data out)               = bit-7 
MISO (Data in)                = bit-6
SCK (Clock)                   = bit-5 
CE (Chip enable)              = bit-4
```

<!-- **Missing words**
 ```
*BIS ( bitmask addr -- )      Set the bits from bitmask at half cell address  
*BIC ( bitmask addr -- )      Clear the bits from bitmask at half cell address  
BIT* ( bitmask addr -- mask ) Test the bits from bitmask at half cell address
                              mask = bitmask when the bits were high otherwise zero
```
**In minimal Forth**
For a machine with byte wide I/O ports.
-->

**The used addresses are for port-1 of the MSP430G2553:**
```forth
\ Extra words: TUCK  

hex
\ Words with hardware dependencies:
: *BIS  ( mask addr -- )        tuck c@ or  swap c! ; 
: *BIC  ( mask addr -- )        >r  invert  r@ c@ and  r> c! ;
: BIT*  ( mask addr -- b )      c@ and ;

20 constant P1IN        \ Input register of port-1
21 constant P1OUT       \ Output register of port-1
22 constant P1DIR       \ Direction register of port-1

: SPI-ON       ( -- )
    B0 P1DIR c!         \ P1.4, P1.6 & P1.7 are outputs, P1.5 is input
    20 P1OUT *bic ;     \ Start with clock low

: CLOCK-HI     ( -- )       20 P1OUT *bis ; \ Generate rising clock pulse
: CLOCK-LOW    ( -- )       20 P1OUT *bic ;

: WRITE-BIT ( b -- )
    80 and if           \ Test if bit-7 high?
      80 P1OUT *bis     \ Yes, write a high bit
    else
      80 P1OUT *bic     \ No, write a low bit
    then ;

: READ-BIT  ( b1 -- b2 )
    40 P1IN bit* 0= 0=  \ Read & convert bit-6 to flag
    1 and  or ;         \ Convert flag to 1 or 0 & add to b1

: SPI-I/O   ( b1 -- b2 )
  8 0 do                \ Output 8-bits in a loop
    dup write-bit  2*   \ Send & shift byte left
    clock-hi  read-bit
    clock-low
  loop
  FF and ;              \ Leave only received byte

: SPI-OUT       ( b -- )    spi-i/o drop ;
: SPI-IN        ( -- b )    0 spi-i/o ;

: {SPI          ( -- )      10 P1OUT *bic ; \ Enable device
: SPI}          ( -- )      10 P1OUT *bis ; \ Disable device

```
### Implementations

Have a look at the sub directories for implementations for different systems.  

[MSP430](MSP430), SPI implementations for MSP430  
[GD32VF](GD32VF), SPI implementations for GD32VF103  

