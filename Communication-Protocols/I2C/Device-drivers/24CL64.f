\ Driver for large I2C EEPROM's and FRAM chips, the device address is set to AE
\ The device may be addressed from A0, A2 to AE in steps of 2
\
\ Prints -1 if device with address 'a' is present on I2C-bus otherwise 0.
\ : I2C?          ( a -- )    setup-i2c  >dev {i2ack?} . ;
\
\ Words from the well-known-words list: <>  1+  BOUNDS  MS

hex
: B-B       ( x - lx hx )       >r r@ FF and  r> 8 rshift ;
: B+B       ( lx hx -- x )      8 lshift or ;
: PCHAR     ( ch1 -- ch2 )      dup 7F < and  bl max ;

\ Reading and writing to EEPROM type 24CL64 with acknowledge polling
\ AE = EEPROM I2C bus address
\ Address EE-device and sent 16-bit EE-address
: {EEADDR   ( eaddr +n -- )    57 device!  {i2c-write  b-b bus! bus! ;

\ Read next byte from 24C512 EEPROM like COUNT but without address
: NEC@      ( -- b )        1 {i2c-read  bus@  i2c} ;

\ Read data 'x' from EEPROM address 'addr'.
: EC@       ( eaddr -- b )  2 {eeaddr i2c}  nec@ ;

\ Write 'x' to EEPROM address addr
: EC!       ( b eaddr -- )  3 {eeaddr  bus! i2c}  {poll} ;


\ Cell wide read and store operators for EEPROM
: EC@+      ( ea1 -- ea2 b )    dup 1+  swap ec@ ;
: E@        ( eaddr -- x )      ec@  nec@ b+b ;
: E!        ( x eaddr -- )      >r  b-b r@ 1+ ec!  r> ec! ;
: E+!       ( n eaddr -- )      >r  r@ e@ +  r> e! ;


\ Example: A forth style memory interface with tools
i2c-on

  1FFF constant EESIZE  \ 8 kByte   24CL64, etc.
\ 7FFF constant EESIZE  \ 32 kByte  24CL256, etc.

\ First cell in EEPROM is used as EHERE, this way it is always up to date
\ We have to take care manually of the forget action on this address pointer
\ Note that EHERE is initialised at address 2 right behind itself!!
\ The error message shows an error in EALLOT !!
0 constant EDP   2 edp e!  ( Init. EHERE )
: EHERE         ( -- ea )       edp e@ ;
: EALLOT        ( +n -- )       eesize over ehere + u< throw  edp e+! ;
: EC,           ( b -- )        ehere  1 eallot  ec! ;
: E,            ( x -- )        ehere  2 eallot  e! ;
: ECREATE       ( -- ea )       ehere constant ;
: EVARIABLE     ( -- ea )       ecreate  2 eallot ;
: EFILL         ( ea u b -- )   rot rot  bounds do  dup i ec!  loop drop ;

: EDMP      ( ea -- )
    hex  i2c-on  begin
        cr  dup 4 u.r ." : "
        10 0 do  dup i + ec@ 2 .r space  loop  ch | emit \ Show hex
        10 0 do  dup i + ec@ pchar emit  loop  10 +      \ Show Ascii
    key bl <> until  drop ;



\ An example

: EM,           ( a u -- )  0 ?do  count ec,  loop  drop ; \ EE compile the string a,n
: ETYPE         ( ea u -- ) bounds ?do  i ec@ emit  loop ; \ EE type string

ecreate STRING  ( -- ea )       \ Store named string in EEPROM
s" Forth"  dup ec, em,


\ Show stored string from EEPROM
: SHOW      ( -- )
    i2c-on
    begin
        cr ." Project "
        string ec@+ etype
        ."  Works"  100 ms
    key? until ;     

\ End ;;;
