\ Generic implementation of an I2C bus scanner, original J. J. Hoekstra

hex
: .BYTE         ( byte -- )         0 <# # # #> type space ;
: I2C-TARGET?   ( addr -- f )       2* >dev  {i2ack?} ;

: .I2C-HEADER   ( -- )
    cr  8 spaces  10 0 do  i ."  0x"  1 .r  loop ;

: .I2C-COLUMN   ( +n -- )
    cr  4 spaces  ." 0x"  1 .r  ." 0 " ;

: .I2C-TARGET   ( addr -- )
    dup i2c-target? if  ." x" .byte  else  drop ." --- "  then ;

: FIRST-LINE    ( -- )
    0 .i2c-column ." gcl stb cbs res res hsm "
    10 6 do  i .i2c-target  loop ;

: LAST-LINE     ( -- )
    7 .i2c-column  8 0 do  i .i2c-target  loop
    ." sgn sgn sgn sgn 0/1 fut fut fut" ;

: I2C-SCAN      ( -- )      \ Scan all valid I2C bus addresses
    i2c-setup  base @ >r  hex
    .i2c-header  first-line
    7 1 do
        i .i2c-column
        i  10 0 do
            dup 10 * i + .i2c-target
        loop  drop
    loop
    last-line  r> base !  cr ;

\ Willems I2C address map
\
\ I2C-SCAN
\         0x0 0x1 0x2 0x3 0x4 0x5 0x6 0x7 0x8 0x9 0xA 0xB 0xC 0xD 0xE 0xF
\    0x00 gcl stb cbs res res hsm --- --- --- --- --- --- --- --- --- ---
\    0x10 --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
\    0x20 x20 x21 --- --- --- --- --- --- --- --- --- --- --- --- --- ---
\    0x30 --- --- --- --- --- --- --- --- --- --- --- --- x3C --- --- ---
\    0x40 --- --- --- --- --- --- --- --- --- --- x4A --- x4C --- --- ---
\    0x50 --- x51 x52 --- --- --- --- x57 --- --- --- --- --- --- --- ---
\    0x60 --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
\    0x70 --- --- --- --- --- --- --- --- sgn sgn sgn sgn 0/1 fut fut fut

\ End ;;;
