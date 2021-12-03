\  A safe minimal string package, original Albert van der Horst, this version W.O. 2021
\
\ Note that to keep security working, use the string buffer and operations together!
\ This code also has a depency, it uses S" interactivly!
\
\ The idea of strings is that a character string (s)
\ is in fact a counted string (c) that has been stored.
\ s (c-addr) is the string, c (c-addr u) is constant string

variable LIM
: $BUFFER       \ Reserve space for a protected string buffer
    here  over 1+ allot                 \ Reserve RAM buffer
    create  ( length) swap , ( here) ,  ( +n "name" -- )
    does>  @+ lim !  @ ;                ( -- s )

: $OVERFLOW ( +n1 +n2 -- )      <  throw ;                          \ Abort when string overflows
: C+!       ( n a -- )          >r  r@ c@ +  r> c! ;                \ Incr. byte with n at a

: $@        ( s -- c )          count ;                             \ Fetch string 'c' from 's'
: $+!       ( c s -- )          lim @  over c@ 3 pick + $overflow  >r \ Check for string overflow!
                                tuck  r@ count +  swap cmove  r> c+! ; \ Extend string 's' with 'c'
: $!        ( c s -- )          0 over c!  $+! ;                    \ Store 'c' string into 's'
: $.        ( c -- )            type ;                              \ Print string 'c'
: $C+!      ( char s -- )       lim @  over c@ 1+ $overflow         \ Check string overflow!
                                dup >r count + c!  1 r> c+! ;       \ Add char to string 's'

\ Check safe string word set

10 $buffer DEMO$

s" One" demo$ $!
demo$ $@ .s $.

bl demo$ $c+!
demo$ $@ .s $.

s" two " demo$ $+!
demo$ $@ .s $.

s" three " demo$ $+!
demo$ $@ .s $.

char & demo$ $c+!
demo$ $@ .s $.

bl demo$ $c+!
demo$ $@ .s $.

s" Go" demo$ $+!
demo$ $@ .s $.

\ End ;;;
