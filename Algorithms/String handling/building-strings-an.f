( using string variables with Procrustean overflow protection )
\ [an dec2021]
\
\ A string variable is a buffer that has a name and its own fixed length.
\
\ With the commands SET$, ADD$ and INC$ you store characters in a string variable.
\ GET$ puts the address and length of the stored string on stack.
\ Use these commands after the name of a string variable.
\
\ A string that doesn't fit in the buffer undergoes the Procrustus therapy.
\ This means that the characters that cause the buffer overflow are simply
\ discarded without any warning.
\
\ $VARIABLE ( maxlen 'name' -- ) \ define an uninitialized stringbuffer
\
\ SET$ ( a n $var -- )    \ store string a,n in $var
\ ADD$ ( a n $var -- )    \ add string a,n to the string in $var
\ INC$ ( char $var -- )   \ add char to the string in $var
\ GET$ ( $var -- a n )    \ get adr,len of the string in $var
\
\ Important:
\ A $variable must be initialized with SET$ before you use
\ ADD$ INC$ or GET$ on it because the count-byte of an uninitialized
\ string variable may contain any number.
\
\ ----- What's in a $variable ? -----
\ The buffer contains a count-byte plus space for 'maxlen' characters.
\ The count-byte contains the length of the actual string in the string
\ variable.
\ Execution of a string variable puts an address on the stack. At that
\ address you find a double cell: the first one contains the address of
\ the buffer, the second one contains 'maxlen'.
\ Example:
\     20 $variable JOHN   \ space for 20 characters, not initialized
\     JOHN         -> body address of JOHN
\     JOHN @       -> buffer-address (location of the count-byte)
\     JOHN cell+ @ -> maxlen
\ After
\     ( adr len ) JOHN SET$
\ 'len' will be in count-byte followed by the string.
\     JOHN @ count    -> adr,len of the string
\
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
