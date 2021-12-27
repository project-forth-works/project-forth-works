\ A character is supposed to be 1 byte.
\ MOVE is supposed to accept byte addresses.

\ : @+ dup cell+ swap @ ;     \ cell version of COUNT or C@+
: C+! ( ch adr -- ) >r r@ c@ + r> c! ;

: $VARIABLE ( maxlen "name" -- )
    here                    \ buffer-address
    over 1+ aligned allot   \ reserve space for count-byte & string
    create , , ;            \ buffer-address & maxlen

: SET$ ( a n $var -- )
    @+ >r           \ r: buffer-address
    @ min           \ overflow protection
    r@ c!           \ count
    r> count move ;
: ADD$ ( a n $var -- )
    @+ >r               \ r: buffer-address
    @ r@ c@ -           \ free space
    min 0 max           \ overflow protection
    r@ count +          \ a n endadr
    over r> c+!         \ update count
    swap move ;
: INC$ ( char $var -- )
    @+ >r                   \ r: buffer-address
    r@ c@ swap @ <          \ buffer not full?
    if  r@ count + c!       \ store char
        1 r> c+!            \ update count
    else r> 2drop
    then ;
: GET$ ( $var -- adr len )   @ count ;

: -TAIL ( adr len i -- adr len' )   0 max over min - ;
: -HEAD ( adr len i -- adr' len' )
    0 max over min tuck - >r + r> ;
\ ----- end of code -----


\ ----- Test -----
decimal
 12 $variable TXT     \ not initialized
: .TXT txt get$ type ;

s" Hallo" txt set$
txt @ .    ( buffer-address )
txt cell+ @ .      ( maxlen )
txt @ count .s ( string in txt )
type        ( string in txt )

s" mad"   txt set$  .txt
s" rid"   txt add$  .txt
s" sugar" txt set$  .txt
char -    txt inc$  .txt
s" free"  txt add$  .txt
s" made in Spain"
          txt set$  .txt
char n    txt inc$  .txt
txt get$
5 -head   txt set$  .txt
char n    txt inc$  .txt



----- Test results in noForth msp430 -----
s" Hallo" txt set$
txt @ .    ( buffer-address ) 8272
txt cell+ @ .      ( maxlen ) 12
txt @ @+ .s ( string in txt ) ( 8274 5 )
type        ( string in txt ) Hallo

s" mad"   txt set$  .txt mad
s" rid"   txt add$  .txt madrid
s" sugar" txt set$  .txt sugar
char -    txt inc$  .txt sugar-
s" free"  txt add$  .txt sugar-free
s" made in Spain"
          txt set$  .txt made in Spai
char n    txt inc$  .txt made in Spai
txt get$
5 -head   txt set$  .txt in Spai
char n    txt inc$  .txt in Spain


----- Test results in noForth RISC-V -----
s" Hallo" txt set$
txt @ .    ( buffer-address ) 536874308
txt cell+ @ .      ( maxlen ) 12
txt @ @+ .s ( string in txt ) ( 536874312 5 )
type        ( string in txt ) Hallo

s" mad"   txt set$  .txt mad
s" rid"   txt add$  .txt madrid
s" sugar" txt set$  .txt sugar
char -    txt inc$  .txt sugar-
s" free"  txt add$  .txt sugar-free
s" made in Spain"
          txt set$  .txt made in Spai
char n    txt inc$  .txt made in Spai
txt get$
5 -head   txt set$  .txt in Spai
char n    txt inc$  .txt in Spain

\ <><>
