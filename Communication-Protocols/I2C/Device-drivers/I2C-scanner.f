\ Generic implementation of an I2C bus scanner, original J. J. Hoekstra

hex
\ Show if a device with address 'dev' is present on the I2C-bus
: I2C?          ( dev -- )
    i2c-on  device!  {device-ok?}
    0= if  ." Not "  then  ." Present " ;


\ Generic implementation of an I2C bus scanner, original J. J. Hoekstra
: .BYTE         ( byte -- )         0 <# # # #> type space ;
: I2C-TARGET?   ( dev -- f )        device!  {device-ok?} ;

: .I2C-HEADER   ( -- )
    cr  8 spaces  10 0 do  i 2 .r space  loop ;

: .I2C-COLUMN   ( +n -- )
    cr  4 spaces  10 * .byte  8 emit  ." : " ;

: .I2C-TARGET   ( addr -- )
    dup i2c-target? if  .byte  else  drop  ." -- "  then ;

: FIRST-LINE    ( -- )
    0 .i2c-column ." gc cb db fp hs hs hs hs "
    10 8 do  i .i2c-target  loop ;

: LAST-LINE     ( -- )
    7 .i2c-column  8 0 do  i .i2c-target  loop
    ." sw sw sw sw ?? ?? ?? ??" ;

: SCAN-I2C      ( -- )      \ Scan for all valid I2C bus addresses
    i2c-on  base @ >r  hex
    .i2c-header  first-line
    7 1 do
        i .i2c-column
        i  10 0 do
            dup 10 * i + .i2c-target
        loop  drop
    loop
    last-line  r> base ! cr ;


\ Willems I2C address map
\
\ scan-i2c
\         0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
\    00: gc cb db fp hs hs hs hs -- -- -- -- -- -- -- --
\    10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
\    20: 20 21 -- -- -- -- -- -- -- -- -- -- -- -- -- --
\    30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
\    40: -- -- -- -- -- -- -- -- -- -- 4A -- 4C -- -- --
\    50: 50 51 52 -- -- -- -- 57 -- -- -- -- -- -- -- --
\    60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
\    70: -- -- -- -- -- -- -- -- sw sw sw sw ?? ?? ?? ??

\ End ;;;
