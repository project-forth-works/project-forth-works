\ Reading and writing to EEPROM type 24C02, the device address is set to A4
\ The device may be addressed from A0, A2 to AE in steps of 2
\
\ Prints -1 if device with address 'a' is present on I2C-bus otherwise 0.
\ : I2C?          ( a -- )    i2c-setup  >dev {i2ack?} . ;
\
\ Words from the well-known-words list: <>  1+  BOUNDS  MS

hex
: B-B       ( x - lx hx )       >r r@ FF and  r> 8 rshift ;
: B+B       ( lx hx -- x )      8 lshift or ;
: PCHAR     ( ch1 -- ch2 )      dup 7F < and  bl max ;

: {EEADDR   ( ea -- )           \ Address EEprom
    A4 {i2write ;               \ 24C02 EE-addr.

\ Byte wide fetch and store in EEPROM
: NEC@      ( -- b )        {i2read) i2in} ;        \ EE Read next byte
: EC@       ( ea -- b )     {eeaddr  nec@ ;         \ EE Read byte from address
: EC!       ( b ea -- )     {eeaddr  i2out}  {poll} ; \ EE Store byte at address
: EC@+      ( ea -- ea+ x ) dup 1+  swap ec@ ;      \ EE version of COUNT

\ Cell wide read and store operators for 24Cxxx EEPROM
: E@        ( ea -- x )      ec@  nec@  b+b ;       \ EE Read word from address
: E@+       ( ea1 -- ea2 x ) dup 2 +  swap e@ ;     \ EE Read word with oute increase
: E!        ( x ea -- )      >r  b-b r@ 1+ ec!  r> ec! ; \ EE Store word at address
: E+!       ( n ea -- )      >r  r@ e@ +  r> e! ;   \ EE Increase contents of address with n


\ Example: A forth style memory interface with tools
i2c-setup
   0100 constant EESIZE         \ 24C02

\ First cell in EEPROM is used as EHERE, this way it is always up to date
\ We have to take care manually of the forget action on this address pointer
\ Note that EHERE is initialised at address 2 right behind itself!!
0 constant EDP  2 edp e!    \ Define and initialise EHERE
: EHERE         ( -- ea )   edp e@ ;                \ EE dictionary pointer
: EALLOT        ( +n -- )   eesize over ehere + u< throw  edp e+! ; \ EE reserve memory
: EC,           ( b -- )    ehere  1 eallot  ec! ;  \ EE compile byte
: E,            ( x -- )    ehere  2 eallot  e! ;   \ EE compile word
: ECREATE       ( -- ea )   ehere  constant ;       \ EE named memory
: EVARIABLE     ( -- ea )       ecreate  2 eallot ;
: EFILL         ( ea u b -- )   rot rot  bounds do  dup i ec!  loop drop ;

: EDMP      ( ea -- )
    hex  i2c-setup  begin
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
    i2c-setup
    begin
        cr ." Project "
        string ec@+ etype
        ."  Works"  100 ms
    key? until ;     

\ End ;;;
