(* SPI loopback test

Connect PA6 (MISO) and PA7 (MOSI) on the GD32VF103 board
The output is printed and increased by one until a key is pressed

*)

: COUNTER       ( -- )
    4 spi-setup  0
    begin
        spi-i/o  dup .  1+  80 ms
    key? until  drop ;

\ End ;;;
