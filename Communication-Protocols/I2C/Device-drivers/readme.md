# I2C device drivers

## The idea for I2C device drivers
There are lots of chips available using the I2C-protocol. These examples use the I2C implementation as [described here](../). All of them need a specific device driver. To name some: sensors, memory, clocks, I/O, etc. Here you can add any driver you like to share. Preferably written in **Generic Forth**. But as we embrace the differences, you may also add them in a new folder for your own dialect !

## I2C drivers

- [24C02](24C02.f), EEPROM memory, this driver works for EEPROM & FRAM chips from 1 kBit to 2 kBit [datasheet](http://ww1.microchip.com/downloads/en/devicedoc/Atmel-3350-SEEPROM-AT24C64B-Datasheet.pdf) & examples:
- [24CL64](24CL64.f), EEPROM memory, this driver works for EEPROM & FRAM chips from 32 kBit to 512 kBit [datasheet](https://4donline.ihs.com/images/VipMasterIC/IC/MCHP/MCHPS02656/MCHPS02656-1.pdf) & examples:
```
      EDMP ( ea -- )       - Dump EEPROM memory from address ea
      SHOW ( -- )          - Show string stored in EEPROM
```
- [APDS9300](APDS9300.f), Light sensor [datasheet](https://docs.broadcom.com/docs/AV02-1077EN) & examples:
```
      APDS ( -- )          - Show light and infrared light data 
```
- [PCA9632](PCA9632.f), 4-bit LED driver [datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9632.pdf) & examples:
```
      PCA-ON ( -- )        - Activate PCA9632 LED power switch 
      >ON    ( b -- )      - (De)activate LED power output modes
```
- [DS1307](DS1307.f), Low power Real-Time Clock [datasheet](https://datasheets.maximintegrated.com/en/ds/DS1307.pdf) & examples:
```
      ALARM  ( -- )        - Give every 10 seconds text string alarm signal
      TIMER  ( s m -- )    - Give every s seconds and m minutes a text string
      CLOCK  ( -- )        - Show an RTC each second on a new line, first set the RTC!
```
- [PCF8574](PCF8574.f), 8-bit I/O extender [datasheet](https://www.nxp.com/docs/en/data-sheet/PCF8574_PCF8574A.pdf) & examples:
```
      RUNNER1 ( -- )       - Running light on the output chip 
      RUNNER2 ( -- )       - Same running light with delay timing using the input chip
      SHOW    ( -- )       - Copy input chip data to output chip 
```
- [PCF8591](PCF8591.f), 8-bit ADC/DAC (four inputs, one output) [datasheet](https://www.nxp.com/docs/en/data-sheet/PCF8591.pdf) & examples:
```
      ANALOG  ( +n -- )    - Convert ADC input +n, output to a DAC and type on screen 
```

<p align="center">
<img src="https://home.hccnet.nl/willem.ouwerkerk/egel-for-msp430/p33%20-%20pcf8591%20adc%20&%20dac.jpg" width="320" height="240" />
      <b>8-Bit ADC/DAC</b>
</p>

- [TMP75](TMP75.f), Temperature sensor with 12-bit resolution and max. +-1 degree celcius accuracy [datasheet](https://datasheets.maximintegrated.com/en/ds/LM75.pdf) & examples:
```
      TMP75-DEMO ( -- )    - Read & show temperature continuously
```
- [More on OLEDs](OLED) ; OLED drivers, character sets, etc.
- [More on LCD's](LCD) ; LCD drivers, character sets, etc.
- [Scanner](I2C-scanner.f) ; Scan your I2C network for connected devices

## APDS9300 driver in pseudo code

Using the I2C driver as presented [here](../)

``` 
Function: {AP-ADDR  ( reg +n -- )
  29  perform device! perform {i2c-write  or reg with 80 bus!

Function: APDS@     ( reg -- byte )
  1  perform {ap-addr perform i2c}
  perform {i2c-read  perform bus@  perform i2c}

Function: APDS!     ( byte reg -- )
  2  perform {ap-addr  perform bus!  perform i2c}

Function: APDS-ON   ( -- )     3 0   perform apds!
Function: APDS-ON   ( -- )     3 0   perform apds!
Function: LIGHT     ( -- u )   0C  do apds@  100 times  0D  do apds@  or
Function: IR        ( -- u )   0E  do apds@  100 times  0F  do apds@  or
```
<p align="center">
<img src="https://project-forth-works.github.io/APDS9300.jpg" width="224" height="200" />
      <b>The tiny APDS9300</b>
</p>

## APDS9300 in Generic Forth
```forth
hex
: {AP-ADDR  ( reg +n -- )   29 device!  {i2c-write  80 or bus! ;
: APDS@     ( reg -- b )    1 {ap-addr i2c}  1 {i2c-read  bus@ i2c} ;
: APDS!     ( b reg -- )    2 {ap-addr  bus! i2c} ;
: APDS-ON   ( -- )          3 0 apds! ;
: APDS-OFF  ( -- )          0 0 apds! ;
: LIGHT     ( -- u )        0C apds@  0D apds@  b+b ;
: IR        ( -- u )        0E apds@  0F apds@  b+b ;
```

## Implementations
Have a look in this directory for Generic Forth implementations. Or in the sub directories for implementations for different systems.
