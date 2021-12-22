\ Reading the TMP75 temperature sensor
\ Original: Frans van der Markt  (3-1-2019)
\ Rewritten for PFW: Willem Ouwerkerk  (19-12-2021)
\
\ The device I2C-address for the TMP75: 0x90
\
\ Note that in the selected 12-bits mode a conversion takes
\ typical 220 ms and maximal 300 ms! When a low current is
\ important, the OS (one shot) mode should be selected. The
\ conversion time needs to be taken into account when this
\ OS mode is selected!
\
\ TMP75 resolution is .0625 degrees Celcius for each bit!
\ Precision plus & min 1 degrees typical & 2 degrees maximal.
\
\ -25 C = -400
\   0 C =  000
\  25 C =  400
\  50 C =  800
\ 100 C = 1600

hex
: TEMPERATURE)  ( -- raw-temperature )
    0  90 {i2write          \ Address TMP75 for writing, select temp. register
    {i2read)                \ Start reading the 16-bit temperature register
    i2in 8 lshift  i2in} or \ Hi-byte and low-byte, merge them too
    2/ 2/ 2/ 2/ ;           \ Remove unused lower four bits, keep sign!


\ Example, read temperature with a resolution 0.1 degree
decimal
: CELCIUS       ( -- celcius )  temperature)  625 1000 */ ;
: FAHRENHEIT    ( -- fahren. )  celcius  9 5 */  320 + ;
hex

: CONFIGURE     ( b -- )        1 90 {i2write  i2out} ;

: .TEMP         ( temp -- )
    s>d dup >r  dabs            \ Save sign
    <#  #  ch . hold  #s  r> sign #> type space ;

\ Read temperature continuously, stop with ESC or hold with SPACE
: TMP75-DEMO
  i2c-setup  60 configure   \ Make R0&R1 high, this sets 12-bit resolution
  begin
     125 ms                 \ Conversion time
     cr  celcius .temp      \ Use celcius scale
\    cr  fahrenheit .temp   \ Use fahrenheit scale
  key? until ;

\ End ;;;
