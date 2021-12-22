(* PCA9632 I2C (LED) power switch

This chip allows switching of outputs, dimmimg of outputs and blinking of outputs!

00 Mode register 1              01 Mode register 2
02 Brightness control led 0     03 Brightness control led 1
04 Brightness control led 2     05 Brightness control led 3
06 Group duty cycle control     07 Group frequency
08 Led output state             09 I2C bus subaddress 1
0A I2C bus subaddress 2         0B I2C bus subaddress 3
0C LED all call I2C-bus address

4 1 >pca    Activate Push-Pull output
0 1 >pca    Open drain output

About >ON  each output is contolled by two bits:
00 = All outputs off
01 = Output 0 on
04 = Output 1 on
02 = Output 0 PWM controlled, etc.
55 = All outputs on
AA = All outputs PWM controlled

*)

hex
: {PCADDR   ( r -- )    C4 {i2write ;
: >PCA      ( b r -- )  {pcaddr  i2out  i2stop} ;
: PCA>      ( r -- b )  {pcaddr  {i2read)  i2in} ;
: RST       ( -- )      A5 6 {i2write  5A i2out  i2stop} ;
: >ON       ( b -- )    8 >pca ;    \ b = 1, 4, 10 or 40
: PCA-ON    ( -- )      01 0 >pca ;
: PCA-OFF   ( -- )      11 0 >pca ;


\ Examples
  i2c-setup     \ Initalise I2C interface
  pca-on        \ Allow changing of outputs
  1 >on         \ Activate output 0
  0 >on         \ Deactivate all outputs
  4 >on         \ Activate output 1
  44 >on        \ Activate output 1 & 3
  pca-off       \ Disable changing of outputs

\ End ;;;
