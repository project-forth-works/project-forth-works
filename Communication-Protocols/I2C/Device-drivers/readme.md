# I2C device drivers

## The idea for I2C device drivers
There are lots of chips available using the I2C-protocol. All of them need a specific device driver. To name some: sensors, memory, clocks, I/O, etc. Here you can add any driver you like to share preferably written in **Generic Forth**. But as we embrace the differences, you may also ass then in a new folder for your own dialect !

## I2C drivers

- 24CL64, EEPROM memory, this driver works for EEPROM & FRAM chips from 32 kBit to 512 kBit
- APDS9300, Light sensor
- PCA9632, 4-bit LED driver
- DS1307, Low power Real-Time Clock
- PCF8574, 8-bit I/O extender
- PCF8591, 8-bit ADC/DAC (four inputs, one output) 

## APDS9300 driver in pseudo code

Using the I2C driver as presented here.

``` 
Function: {AP-ADDR  ( reg -- )
  or reg with 80  52 {i2write

Function: APDS@     ( reg -- byte )
  {ap-addr  {i2read)  i2in}

Function: APDS!     ( byte reg -- )
  {ap-addr  i2out}

Function: APDS-ON   ( -- )     3 0 apds!
Function: APDS-ON   ( -- )     3 0 apds!
Function: LIGHT     ( -- u )   0C apds@  0D apds@  100 *  or
Function: IR        ( -- u )   0E apds@  0F apds@  100 *  or
```

## APDS9300 in Generic Forth
```
: {AP-ADDR  ( r -- )        80 or  52 {i2write ;
: APDS@     ( r -- b )      {ap-addr  {i2read)  i2in} ;
: APDS!     ( b r -- )      {ap-addr  i2out} ;
: APDS-ON   ( -- )          3 0 apds! ;
: APDS-OFF  ( -- )          0 0 apds! ;
: LIGHT     ( -- u )        0C apds@  0D apds@  b+b ;
: IR        ( -- u )        0E apds@  0F apds@  b+b ;
```

## Implementations
Have a look in this directory for Generic Forth implementations. Or in the sub directories for implementations for different systems.
