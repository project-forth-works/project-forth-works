\ I2C analog input & output using a PCF8591
\
\ Note that: 48 = PCF8591 I2C-bus device address 0
\
\ Connections on module YL-40 e.g. at AliExpress:
\  0 ADC - AIN0 = LDR
\  1 ADC - AIN1 = Thermistor
\  2 ADC - AIN2 = Free
\  3 ADC - AIN3 = Potmeter
\  DAC is connected to an output and a green led

hex
\ This flag is set when DAC was used. Set to zero 
\ when DAC has to be off during ADC conversions!
0 value DAC?  ( -- vlag )   \ Keep DAC active if true

\ Read ADC input '+n', 'u' is the result of the conversion.
: ADC       ( +n -- u )
    4A device!              \ Select ADC
    3 and                   \ Select 1 of four inputs  
    dac? 40 and  or         \ (De)activate DAC & add input
    1 {i2c-write  bus! i2c} \ Send address & control byte
    2 {i2c-read  bus@ drop  bus@ i2c} ; \ Get fresh ADC reading 

\ Set DAC-output the a value that matches 'u'.
: DAC       ( u -- )
    4A device!              \ Select ADC
    true to dac?            \ DAC active
    1 {i2c-write  bus! i2c} ; \ Send address & control byte


\ Example program
: ANALOG    ( +n -- )       \ Show the use off ADC/DAC
    i2c-on  >r              \ Initialise I2C
    true to dac?            \ DAC is used
    begin
        r@ adc  dup .       \ Read ADC input +n, show result
        invert dac          \ Store inverted to DAC
    key? until  r> drop ;

\ End ;;;
