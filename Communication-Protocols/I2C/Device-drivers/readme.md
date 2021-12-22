# I2C device drivers

## The idea for I2C device drivers
There are lots of chips available using the I2C-protocol. These examples use the I2C implementation as [described here](../). All of them need a specific device driver. To name some: sensors, memory, clocks, I/O, etc. Here you can add any driver you like to share. Preferably written in **Generic Forth**. But as we embrace the differences, you may also add them in a new folder for your own dialect !

## I2C drivers

- [24CL64](24CL64.f), EEPROM memory, this driver works for EEPROM & FRAM chips from 32 kBit to 512 kBit [datasheet](http://ww1.microchip.com/downloads/en/devicedoc/Atmel-3350-SEEPROM-AT24C64B-Datasheet.pdf) & examples:
```
      EDMP ( ea -- )       - Dump EEPROM memory from address ea
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
      ANALOG  ( +n -- )    - Convert ADC input +n, output ta DAC and type on screen 
```
- [TMP75](TMP75.f), Temperature sensor with 12-bit resolution and max. 1% accuracy [datasheet](https://www.ti.com/lit/gpn/tmp75) & examples:
```
      TMP75-DEMO ( -- )    - Read & show temperature continuously
```
- [OLED](ssd1306-setup-(128x64)-a.f ), 128x64 I2C OLED driver & controller [datasheet](http://www.adafruit.com/datasheets/SSD1306.pdf)
- [Character set](ssd1306-thin-chars.f), 7x16 bits thin characterset & [more on OLEDs](https://home.hccnet.nl/willem.ouwerkerk/egel-for-msp430/egel%20for%20launchpad.html#e060), examples:
```
      SETUP-DISPLAY ( -- ) - Initialise OLED display
      THINDEMO      ( -- ) - Show some text and a part of the character set
```
<p align="center">
<img src="https://home.hccnet.nl/willem.ouwerkerk/egel-for-msp430/p60%20-%20thin%207x16%20characters.jpg" width="300" height="300" />
      <b>7x16 character set</b>
</p>

## APDS9300 driver in pseudo code

Using the I2C driver as presented [here](../)

``` 
Function: {AP-ADDR  ( reg -- )
  or reg with 80  52 {i2write

Function: APDS@     ( reg -- byte )
  {ap-addr  {i2read)  i2in}

Function: APDS!     ( byte reg -- )
  {ap-addr  i2out}

Function: APDS-ON   ( -- )     3 0 apds!
Function: APDS-ON   ( -- )     3 0 apds!
Function: LIGHT     ( -- u )   0C apds@  or 100 times 0D apds@
Function: IR        ( -- u )   0E apds@  or 100 times 0F apds@
```

## APDS9300 in Generic Forth
```
hex
: {AP-ADDR  ( r -- )        80 or  52 {i2write ;
: APDS@     ( r -- b )      {ap-addr  {i2read)  i2in} ; \ Read register 'r' leaving 'b'
: APDS!     ( b r -- )      {ap-addr  i2out} ; \ Write 'b' to register 'r'
: APDS-ON   ( -- )          3 0 apds! ; \ Sensor on
: APDS-OFF  ( -- )          0 0 apds! ; \ Sensor off
: LIGHT     ( -- u )        0C apds@  0D apds@  8 lshift or ; \ Visual light
: IR        ( -- u )        0E apds@  0F apds@  8 lshift or ; \ Visual & infrared light
```

## Implementations
Have a look in this directory for Generic Forth implementations. Or in the sub directories for implementations for different systems.
