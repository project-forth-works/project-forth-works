\ APDS9300 light sensor. I2C bus address = 52

hex
: B-B       ( x - lx hx )       >r  r@ FF and  r> 8 rshift ;
: B+B       ( lx hx -- x )      8 lshift or ;

\ Address APDS9300 device, sent 8-bit command code with register-address 'r'
: {AP-ADDR  ( reg +n -- )   29 device!  {i2c-write  80 or bus! ;
: APDS@     ( reg -- b )    1 {ap-addr i2c}  1 {i2c-read  bus@ i2c} ;
: APDS!     ( b reg -- )    2 {ap-addr  bus! i2c} ;
: APDS-ON   ( -- )          3 0 apds! ;
: APDS-OFF  ( -- )          0 0 apds! ;
: LIGHT     ( -- u )        0C apds@  0D apds@  b+b ;
: IR        ( -- u )        0E apds@  0F apds@  b+b ;

: APDS      ( -- )
    i2c-on  apds-on  200 ms
    begin
        cr light u.  ir u.
    key? until  apds-off ;

\ End ;;;
