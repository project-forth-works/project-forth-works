(* Short I2C 24C02 EEPROM demo

PB6 = SCL
PB7 = SDA
 
    Reading and writing to EEPROM type 24C02
    A0 = EEPROM I2C bus address
    Load 'GD32VF103 bb-I2C.f' before this file

*)

hex
\ Read data 'x' from EEPROM address 'a'.
: EC@       ( ia -- x )
    50 device!  1 {i2c-write  bus! i2c} 
    1 {i2c-read  bus@ i2c} ;

\ Write 'x' to EEPROM address 'a'
: EC!       ( x ia -- )
    50 device!  2 {i2c-write  bus! bus! i2c} ;

\ Show stored string from EEPROM
: SHOW      ( -- )
    i2c-on
    begin
        cr ." Project-"
        0 ec@ 0 ?do
            i 1+ ec@ emit
        loop
        ." -Works"  100 ms
    key? until ;     

i2c-on  0        \ Store string to start of EEPROM
5       over ec!  1+  
ch F    over ec!  1+  
ch o    over ec!  1+  
ch r    over ec!  1+  
ch t    over ec!  1+  
ch h    over ec!  1+ 
drop 

' show  to app  
shield I2C-DEMO\  freeze

\ End ;;;

