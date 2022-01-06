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
: {EEADDR   ( a -- )            \ Address EEprom
    b-b  A0 {i2write i2out ;    \ High EE-addr. & low EE-addr.

\ Read data b from 24C32 EEPROM byte-address addr. 
: EC@       ( addr -- b )
    {eeaddr  {i2read)  i2in} ;  \ Address EE & rep. start & read data

\ Write data b to 24C32 EEPROM byte-address addr.
: EC!       ( b addr -- )
    {eeaddr  i2out}  {poll} ;   \ Address EE & write data

\ Show stored string from EEPROM
: SHOW      ( -- )
    i2c-setup
    begin
        cr ." Embedding"
        0 ec@ 0 ?do
            i 1+ ec@ emit
        loop  100 ms
    key? until ;     

setup-i2c  0        \ Save string at the beginning of the EEPROM
5       over ec!  1+  
ch F    over ec!  1+  
ch o    over ec!  1+  
ch r    over ec!  1+  
ch t    over ec!  1+  
ch h    over ec!  1+ 
drop 

shield 24C32\  freeze

\ End
