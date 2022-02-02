(* Advanced I2C 24C02 EEPROM demo

PB6 = SCL
PB7 = SDA
 
    Reading and writing to EEPROM type 24C02
    A0 = EEPROM I2C bus address
    Load 'GD32VF103 bb-I2C.f' before this file

*)

hex
i2c-on
: {EEADDR   ( ea +n -- )    \ Address EEPROM
    50 device!  {i2c-write  bus! ;                      \ 24C02 EE-addr.

\ Byte wide fetch and store in EEPROM
: NEC@      ( -- b )        1 {i2c-read  bus@ i2c} ;    \ EE Read next byte
: EC@       ( ea -- b )     1 {eeaddr i2c}  nec@ ;      \ EE Read byte from address
: EC!       ( b ea -- )     2 {eeaddr  bus! i2c} {poll} ; \ EE Store byte at address
: EC@+      ( ea -- ea+ x ) dup 1+  swap ec@ ;          \ EE version of COUNT

\ Cell wide read and store operators for 24Cxxx EEPROM
: E@        ( ea -- x )      ec@  nec@  b+b ;       \ EE Read word from address
: E@+       ( ea1 -- ea2 x ) dup 2 +  swap e@ ;     \ EE Read word with oute increase
: E!        ( x ea -- )      >r  b-b r@ 1+ ec!  r> ec! ; \ EE Store word at address
: E+!       ( n ea -- )      >r  r@ e@ +  r> e! ;   \ EE Increase contents of address with n

  FF constant EESIZE  \ 8 kByte   24CL64, etc.

\ First cell in EEPROM is used as EHERE, this way it is always up to date
\ We have to take care manually of the forget action on this address pointer
\ Note that EHERE is initialised at address 2 right behind itself!!
\ The out of EE-memory error message, shows an error in EALLOT !!
0 constant EDP  \ Define and initialise EHERE
: EHERE         ( -- ea )   edp e@ ;                \ EE dictionary pointer
: EMPTY         ( -- )      2 edp e! ;              \ EE (re) initialise
: EUNUSED       ( -- u )    eesize ehere - ;         \ EE unused space 
: .EFREE        ( -- )      eunused u. ;            \ EE show free memory space
: EALLOT        ( +n -- )   eunused  over u< ?abort  edp e+! ; \ EE reserve memory
: EC,           ( b -- )    ehere  1 eallot  ec! ;  \ EE compile byte
: E,            ( x -- )    ehere  2 eallot  e! ;   \ EE compile word
: EM,           ( a u -- )  for  count ec,  next drop ; \ EE compile the string a,n
: ECREATE       ( -- ea )   ehere  constant ;       \ EE named memory
: ETYPE         ( ea u -- ) bounds ?do  i ec@ emit  loop ; \ EE type string

inside
: EDUMP         ( ea u -- )                         \ EE dump u bytes
    i2c-on  base @ >r  hex      \ base is HEX
    bounds ?do
        cr i 4 u.r ." : "       \ print EE address
        i 10 bounds do          \ dump 10 EE bytes in HEX
            i ec@ 2 .r space
        loop
        space  i 10 bounds do   \ dump 10 bytes in ASCII
            i ec@ pchar emit
        loop
    10 +loop                    \ next 10 or ready
    r> base ! ;                 \ restore base
forth

empty \ Intialise EEPROM memory pointer


\ Small demo
ecreate STRING  ( -- ea )       \ Store named string in EEPROM

\ Show stored string from EEPROM
: SHOW      ( -- )
    i2c-on
    begin
        cr ." Project-"
        string ec@+ etype
        ." -Works"  100 ms
    key? until ;     

' show  to app  
shield I2C-DEMO\  freeze
    
s" Forth"  dup ec, em,

\ End ;;;
