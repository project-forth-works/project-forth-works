\ I2C input & output with a PCF8574 using external pull-ups
\
\ Connect a PCF8574 and 8 leds and connect the power lines
\ For RUNNER2 and SHOW we need a second PCF8574 with eight switches. 
\ Words from the well-known-words list: MS

hex
\ Output routine for PCF8574(a) chips
\ 42 Is address 1 of the output chip, 40 is address 0 of the input chip
\ When using the PCF8574A these are, output: 072 and input: 070
: OUTPUT    ( b -- )    42 {i2write  i2stop} ;
: INPUT     ( -- +n )   40 {i2read i2in} ;


\ Examples
: BLINK     ( -- )      0 output 100 ms  -1 output 100 ms ;

: RUNNER1   ( -- )              \ Show a running light on the leds
    i2c-setup  blink
    begin
        8 0 do  1 i lshift output  50 ms  loop  
    key? until 
    0 output ;

: RUNNER2   ( -- )              \ Show a running light on leds
    i2c-setup  blink
    begin
        8 0 do
            1 i lshift output  input 0A * ms
        loop  
    key? until  0 output ;

: SHOW      ( -- )              \ Show keypresses on leds
    i2c-setup  blink  begin  input output  key? until  0 output ;

\ End ;;;
