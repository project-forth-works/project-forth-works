\ I2C temperature measuring temperature with LM75CIM
\ AUTHOR      : Willem Ouwerkerk, November 25, 1999
\ LAST CHANGE : Willem Ouwerkerk, Februari 1, 2022
\ Added compensation value for the LM75 named #COMP

hex
dm -50 constant #COMP            \ Correction value in half degrees please adjust!
: {REGISTER     ( reg +n -- )   {i2c-write  bus! ;   \ Select any LM75 register
: TEMP-REGISTER ( -- )          0 1 {register i2c} ; \ Select temp. register

: @REG8         ( reg -- b )    \ Read 8-bit register
    1 {register i2c}  1 {i2c-read  bus@ i2c} ;

: @REG16        ( reg -- x )    \ Read 16-bit register
    1 {register i2c}  2 {i2c-read  bus@ bus@ i2c} swap b+b ;

\ Temperature is given in half degrees for each bit, where zero
\ is 0 degrees celcius, the range goes from -55 tot 125 degrees.
: TEMPERATURE)   ( -- tr )          \ Read raw temperature
    2 {i2c-read  bus@ bus@ i2c} swap b+b ;

: TEMPERATURE   ( -- n )            \ Read corrected temperature
    temperature)  dup 0F rshift     \ Shift 15 bits to right
    if  -1  FFFF xor  or  then      \ Convert sign to systems word width
    7 for  2/  next  #comp + ;      \ Divide by 128, keep sign & compensation value

: CONFIGURATION ( b  -- )           \ Set LM75 configuration
    1 1 {register  i2c}             \ Select config. reg.
    temp-register ;                 \ Select temp. reg. again

\ The temperatute T needs to be given in whole degrees here
: >TEMPERATURE  ( t -- tl th )      \ Convert temp. to two bytes
    0  swap FF and ;                \ for LM75 thermostatic function

: LOW-LIMIT     ( t -- )
    >temperature  2 3 {register     \ Select THYST reg.
    bus! bus! i2c}  temp-register ; \ Set thermostat lower boundary

: HIGH-LIMIT    ( t -- )
    >temperature  3 3 {register     \ Select TOS reg. (over temperature)
    bus! bus! bus! i2c}  temp-register ; \ Set thermostat higher boundary

i2c-on  4C device!  \ Set LM75 device address


\ Example programs

\ Show temperature in whole degrees celcius
: .CELCIUS1         ( n -- )        2/ 3 .r  BA emit ." C " ;

: TEMPERATURE1      ( -- )
    i2c-on  4C device!
    base @ >r decimal
    begin
        temperature .celcius1  100 ms
    key? until  r> base ! ;

\ Show temperature in half degrees celsius
\ temperature dm 10 dm 2 */ dm .
: .CELCIUS2         ( n -- )
    0A * 2 / s>d <# # ch . hold #s #> type  BA emit ." C " ;

: TEMPERATURE2      ( -- )
    i2c-on  4C device!
    base @ >r  decimal
    begin
        temperature .celcius2  100 ms
    key? until  r> base ! ;

\ End ;;;
