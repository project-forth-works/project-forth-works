\  A safe minimal string package, original Albert van der Horst, this version W.O. 2021
\
\ Note that to keep security working, use the string buffer and operations together!
\ This code also has a depency it uses S" interactivly! this version cuts
\ the string when the added string does not fit anymore.
\
\ The idea of strings is that a character string (s)
\ is in fact a counted string (c) that has been stored.
\ s (c-addr) is the string, c (c-addr u) is constant string

variable LIM
: $VARIABLE     \ Reserve space for a protected string variable
    here  over 1+ allot                 \ Reserve RAM buffer
    create  ( length) swap , ( here) ,  ( +n "name" -- )
    does>  @+ lim !  @ ;                ( -- s )

: C+!       ( n a -- )          >r  r@ c@ +  r> c! ;                \ Incr. byte with n at a

: $@        ( s -- c )          count ;                             \ Fetch string 'c' from 's'
: $+!       ( c s -- )          >r  lim @  r@ c@ -  umin            \ Limit string to max. length!
                                tuck  r@ count +  swap move  r> c+! ; \ Extend string 's' with 'c'
: $!        ( c s -- )          0 over c!  $+! ;                    \ Store 'c' string into 's'
: $.        ( c -- )            type ;                              \ Print string 'c'
: $C+!      ( char s -- )       >r  lim @  r@ c@ -  1 umin if       \ Space for character?
                                    r@ count + c!  1 r> c+!  exit   \ Add char to string 's'
                                then  r> 2drop ;

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

s" God" demo$ $+!
demo$ $@ .s $.

bl demo$ $c+!
demo$ $@ .s $.

ch & demo$ $c+!
demo$ $@ .s $.

\ End ;;;
