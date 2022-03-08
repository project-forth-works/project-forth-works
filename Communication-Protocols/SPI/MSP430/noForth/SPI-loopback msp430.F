(* SPI loopback test 

For: MSP430G2553
Connect P1.6 (MISO) and P1.7 (MOSI) on any MSP430G2553 board
The output is printed and increased by one until a key is pressed

For: MSP430FR59x9
Connect P2.6 (MISO) and P2.5 (MOSI) on any MSP430FR59x9 board
The output is printed and increased by one until a key is pressed

For: MSP430F149
Connect P5.2 (MISO) and P5.1 (MOSI) on any MSP430F14x board
The output is printed and increased by one until a key is pressed

*)

: COUNTER       ( -- )
    spi-on  0
    begin
        spi-i/o  dup .  1+  80 ms
    key? until  drop ;

\ End ;;;
