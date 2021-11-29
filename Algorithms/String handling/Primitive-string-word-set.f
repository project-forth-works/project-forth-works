\  A minimal string package, original Albert van der Horst, this version W.O. 2021
\  
\ The idea of strings is that a character string (s)
\ is in fact a counted string (c) that has been stored.
\ s (c-addr) is the string, c (c-addr u) is constant string
\ Note: This code assumes that a character is byte wide!

: $BUFFER       \ Reserve space for a string buffer
    here  over 1+ allot     \ Reserve RAM buffer
    create  ( here) ,       ( +n "name" -- )
    does>  @ ;              ( -- s )

: C+!       ( n a -- )      >r  r@ c@ +  r> c! ;    \ Incr. byte with n at a
: $@        ( s -- c )      count ;                 \ Fetch string 'c' from 's'  
: $+!       ( c s -- )      >r  tuck  r@ $@ +  swap cmove  r> c+! ; \ Extend string 's' with 'c'
: $!        ( c s -- )      0 over c!  $+! ;        \ Store 'c' string into 's'
: $.        ( c -- )        type ;                  \ Print string 'c'
: $C+!      ( char s -- )   dup >r  $@ + c!  1 r> c+! ;             \ Add char to string 's'

\ End ;;;
