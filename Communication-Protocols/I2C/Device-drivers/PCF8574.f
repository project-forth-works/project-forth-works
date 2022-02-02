\ I2C input & output with a PCF8574 using external pull-ups
\
\ Connect a PCF8574 and 8 leds and connect the power lines
\ The leds & switches are connected with inverted logic (a zero sets them on)
\ For RUNNER2 and SHOW we need a second PCF8574 with eight switches. 
\ Words from the well-known-words list: MS

hex
\ Output routine for PCF8574(a) chips
\ 21 Is address 1 of the output chip, 20 is address 0 of the input chip
\ When using the PCF8574A these addresses are, output: 39 and input: 38
: OUTPUT    ( b -- )    21 device!  1 {i2c-write  bus! i2c} ;
: INPUT     ( -- b )    20 device!  1 {i2c-read   bus@ i2c} ;


\ Examples
: BLINK     ( -- )      0 output 100 ms  -1 output 100 ms ;

: RUNNER1   ( -- )              \ Show a running light on the leds
    i2c-on  blink
    begin
        8 0 do  1 i lshift invert output  50 ms  loop  
    key? until 
    -1 output ;

: RUNNER2   ( -- )              \ Show a running light on leds
    i2c-on  blink
    begin
        8 0 do
            1 i lshift invert output  input FF xor 0A * ms
        loop  
    key? until  -1 output ;

: SHOW      ( -- )              \ Show keypresses on leds
    i2c-on  blink  begin  input output  key? until  -1 output ;

\ End ;;;
