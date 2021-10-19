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
    A0 {i2write {i2read) i2in} ; \ Address EE & rep. start & read data

\ Write 'x' to EEPROM address 'a'
: EC!       ( x ia -- )
    A0 {i2write  i2out} ;       \ Address EE & write data

\ Show stored string from EEPROM
: SHOW      ( -- )
    i2c-setup
    begin
        cr ." Embedding"
        0 ec@ 0 ?do
            i 1+ ec@ emit
        loop  100 ms
    key? until ;     

i2c-setup  0        \ Store string to start of EEPROM
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

