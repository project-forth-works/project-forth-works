(* Circular buffers v 0.01

This buffer can be used in case of unstable data readings.
It could be the input for an average or median routine or so.

1) This type of buffer needs to be filled fully
   before at can be used, otherwise garbage is returned.
2) The buffer meeds te be filled regularly and overwrites
   the oldest values continuously..
3) This implementation uses buffers with a length
   that is a power of two. For fast wrapping around!
4) This is just a sample implementation, please adjust
   it to suit the needs of your application.


1) Bytes wide storage
2) Character wide storage
3) Cell wide storage

*)

hex     \ 1) Byte wide storage
08 constant #SIZE       \ Note, must be a power of 2
value PTR               \ Data pointer
create BUFFER   #size allot  align

: INIT      ( -- )          0 to ptr ;
: WRAP      ( n1 -- n2 )    [ #size 1- ] literal and ;
: 'BUFFER   ( +n -- a )     buffer + ;
: !BYTE     ( b -- )        ptr 'buffer c!  ptr 1+  wrap to ptr ;
: @BYTE     ( -- b )        ptr 'buffer c@ ;
: @BYTE-N   ( +n -- )       ptr + wrap  'buffer c@ ;


init
: B1    #size 1+ 0 ?do  i !byte  loop ;  \ Test overflow
: B2    #size 0 ?do  i @byte-n .  loop ; \ Dump whole buffer
: B3    #size 0 ?do  i !byte  loop ;     \ Test whole buffer fill



hex     \ 2) Char wide storage
08 constant #SIZE       \ Note, must be a power of 2
value PTR               \ Data pointer
create BUFFER   #size chars allot  align

: INIT      ( -- )          0 to ptr ;
: WRAP      ( n1 -- n2 )    [ #size 1- ] literal and ;
: 'BUFFER   ( +n -- a )     chars buffer + ;
: !CHAR     ( b -- )        ptr 'buffer c!   ptr 1+  wrap to ptr ;
: @CHAR     ( -- b )        ptr 'buffer c@ ;
: @CHAR-N   ( +n -- )       ptr + wrap  'buffer c@ ;

init
: C1    #size 1+ 0 ?do  i !char  loop ;  \ Test overflow
: C2    #size 0 ?do  i @char-n .  loop ; \ Dump whole buffer
: C3    #size 0 ?do  i !char  loop ;     \ Test whole buffer fill



hex     \ 3) Cell wide storage
08 constant #SIZE       \ Note, must be a power of 2
value PTR               \ Data pointer
create BUFFER   #size cells allot  align

: INIT      ( -- )          0 to ptr ;
: WRAP      ( n1 -- n2 )    [ #size 1- ] literal and ;
: 'BUFFER   ( +n -- a )     cells buffer + ;
: !CELL     ( b -- )        ptr 'buffer !   ptr 1+  wrap to ptr ;
: @CELL     ( -- b )        ptr 'buffer @ ;
: @CELL-N   ( +n -- )       ptr + wrap  'buffer @ ;

init
: W1    #size 1+ 0 ?do  i !cell  loop ;  \ Test overflow
: W2    #size 0 ?do  i @cell-n .  loop ; \ Dump whole buffer
: W3    #size 0 ?do  i !cell  loop ;     \ Test whole buffer fill


