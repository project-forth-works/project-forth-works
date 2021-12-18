\ I2C analog input & output using a PCF8591
\
\ Note that; 090 = PCF8591 I2C-bus identification address 0
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
    3 and                   \ Select 1 of four inputs  
    dac? 40 and  or         \ (De)activate DAC & add input
    90 {i2write             \ Send address & control byte
    {i2read)  i2in drop  i2in} ; \ Repeated start, get fresh ADC reading 

\ Set DAC-output the a value that matches 'u'.
: DAC       ( u -- )
    true to dac?            \ DAC active
    40 90 {i2write i2out} ; \ Send address & control byte


\ Example program
: ANALOG    ( +n -- )       \ Show the use off ADC/DAC
    setup-i2c  >r           \ Initialise I2C
    true to dac?            \ DAC is used
    begin
        r@ adc  dup .       \ Read ADC input +n, show result
        invert dac          \ Store inverted to DAC
    key? until  r> drop ;

\ End ;;;
