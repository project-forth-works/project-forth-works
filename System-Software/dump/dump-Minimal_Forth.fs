\ Dump utility in Minimal Forth         uh 2021-08-11

\ This source code provides a simle hex dump utility.
\
\ It does not require number output conversion U. U.R . .R <# # #S #> SIGN or HOLD
\
\ Memory is accessed by C@ output is perfomed by EMIT.
\ So this dump utility can be used also on quite limited systems.
\
\ Usage:
\
\   <addr> <len> DUMP
\
\ or
\
\   <addr> <len> ADJUSTED DUMP   \ to start the dump at an even b/line boundary


\ definitions missing from Minimal Forth

: min ( n1 n2 -- n3 )  
   over over > IF swap THEN drop ;

32 Constant bl

: space ( -- )  
   bl emit ;

: spaces ( u -- ) 
   BEGIN dup WHILE space 1 - REPEAT drop ;

: /string ( c-addr1 u1 n -- c-addr2 u2 )
   swap over - >r + r> ;

: 2drop ( x1 x2 -- )
   drop drop ;

: 2dup ( x1 x2 -- x1 x2 x1 x2 )
   over over ;

46 Constant '.'
48 Constant '0'
58 Constant ':'
65 Constant 'A'

\ ---- Dump utility 

: .hexdigit ( x -- )
     15 and  dup 10 < IF '0' + ELSE  10 - 'A' + THEN emit ;  

: .hex ( x -- )
     dup  4 rshift .hexdigit  .hexdigit ; 

: .addr ( x -- )
     0 BEGIN ( x i ) over WHILE  over 8 rshift  swap 1 + REPEAT swap drop
       BEGIN ( x i )  dup WHILE  swap .hex 1 - REPEAT drop ;

16 Constant b/line ( -- x )

: .h ( addr len -- )
   b/line min dup >r
   BEGIN \ ( addr len )
     dup
   WHILE \ ( addr len )
     over c@ .hex space  
     1 /string
   REPEAT 2drop
   b/line r> - 3 * spaces ; 

: .a ( addr1 len1 -- )
   b/line min
   BEGIN \ ( addr len )
     dup
   WHILE 
     over c@ dup bl < IF drop '.' THEN emit
     1 /string
   REPEAT 2drop ;

: dump-line ( addr len1 -- addr len2 )
   over .addr ':' emit space   2dup .h space space  2dup .a 
   dup  b/line  min /string ;

: dump ( addr len -- )
   BEGIN
     dup
   WHILE \ ( addr len )
     cr dump-line 
   REPEAT 2drop ;

: adjusted ( addr1 u1 -- addr2 u2 ) \ adjust addr len as in "adjusted dump"
    swap     b/line /     b/line * 
    swap 1 - b/line / 1 + b/line * ; 

