(* For noForth C&V 200202: I2C on MSP430xxxx
   I2C data memory with an 24C32 using external pull-ups

  Connect a 24C32 EEPROM and connect the power lines, 
  P1.7 to SDA and P1.6 to SCL and jumper P1.6 to the green led has to 
  be removed, that's it.

 Addresses, Lables and Bit patterns  
 0069    - UCB0CTL1     - 081
 0003    - IFG2         - 008 = TX ready, 004 = RX ready

This code implements data storage with an 24C32 EEPROM

*)

hex
\ Example with clock & 24C32 EEPROM

\ Address EE-device and sent 16-bit EE-address
: {EEADDR   ( eaddr +n -- )    50 device!  {i2c-write  b-b bus! bus! ;

\ Read next byte from 24C32 EEPROM like COUNT but without address
: NEC@      ( -- b )        1 {i2c-read  bus@  i2c} ;

\ Read data 'x' from EEPROM address 'addr'.
: EC@       ( eaddr -- b )  2 {eeaddr i2c}  nec@ ;

\ Write 'x' to EEPROM address addr
: EC!       ( b eaddr -- )  3 {eeaddr  bus! i2c}  {poll} ;

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

i2c-on  0       \ Save string at the beginning of the EEPROM
5       over ec!  1+  
ch F    over ec!  1+  
ch o    over ec!  1+  
ch r    over ec!  1+  
ch t    over ec!  1+  
ch h    over ec!  1+ 
drop 

shield 24C32\  freeze

\ End
