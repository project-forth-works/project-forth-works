# OLED display drivers 

## Idea for OLED drivers
There are lots of small OLED displays available, most use the SSD1306 display driver, some the SH1106 driver. 
There are slight differences between these driver chips. Here are some implementation examples.

## Direct drive an OLED
Barebone driver that uses almost no RAM, that means no screen buffer is used! More files can be found on the Egel project pages.

- [OLED, 128x32](ssd1306-setup-(128x32)-a.f ) I2C OLED driver & controller [datasheet](http://www.adafruit.com/datasheets/SSD1306.pdf)
- [OLED, 128x64](ssd1306-setup-(128x64)-a.f ) I2C OLED driver & controller [datasheet](http://www.adafruit.com/datasheets/SSD1306.pdf)
- [Character set 5x8 bits](ssd1306-small-chars.f), small characterset & [more on OLEDs](https://home.hccnet.nl/willem.ouwerkerk/egel-for-msp430/egel%20for%20launchpad.html#e060), examples:
- [Character set 7x16 bits](ssd1306-thin-chars.f), thin characterset & [more on OLEDs](https://home.hccnet.nl/willem.ouwerkerk/egel-for-msp430/egel%20for%20launchpad.html#e060), examples:
```
      SETUP-DISPLAY ( -- ) - Initialise OLED display
      SMALLDEMO     ( -- ) - Demonstrate the 5x8 character set
      THINDEMO      ( -- ) - Demonstrate the 7x16 character set
```
<p align="center">
<img src="https://home.hccnet.nl/willem.ouwerkerk/egel-for-msp430/p60%20-%20thin%207x16%20characters.jpg" width="300" height="300" />
      <b>7x16 character set</b>
</p>