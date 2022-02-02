# I2C for noForth on the MSP430 
![p30(u) - i2c bitbang usci input and output to pcf8574](https://user-images.githubusercontent.com/11397265/122937875-9ab1ad00-d372-11eb-9eab-5bcbd29c8512.jpg)  
**I2C on the MSP430G2553**

All driver files are from the [Egel Project, from chapter 30ff](https://home.hccnet.nl/willem.ouwerkerk/egel-for-msp430/egel%20for%20launchpad.html#e03x).
This code example works with all added driver versions of the noForth I2C implementation:
```
\ Example with clock & 24C32 EEPROM
: {EEADDR   ( a +n -- )                     \ Address EEprom
    50 device!  {i2c-write  b-b bus! bus! ;

\ Read data b from 24C32 EEPROM byte-address addr. 
: EC@       ( addr -- b )
    2 {eeaddr i2c}  1 {i2c-read bus@ i2c} ;

\ Write data b to 24C32 EEPROM byte-address addr.
: EC!       ( b addr -- )
    3 {eeaddr  bus! i2c}  {poll} ;
```
