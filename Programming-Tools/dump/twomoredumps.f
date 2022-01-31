\ Two more DUMPs for a forth that has no .R and U.R
\ an 20oct2021

\ - 1 -

hex : DUMP ( a n -- )
    0 max 1000 min           \ safety for n
    over + >r                                               \ limit
    begin dup r@ u<
    while cr dup u. ." : "                                  \ .addr
        dup 8 0 do count dup 10 < if space then . loop drop \ .bytes
        ." |"
        8 0 do count dup 7F < and bl max emit loop          \ .chars
        ." |"
    repeat r> 2drop cr ;

\ The forth system must be in hex.
\ --- Option:
\ For longer lines replace  8 0 do  with  10 0 do ( in .bytes & .chars )


\ - 2 -

hex : .DIGITS ( u n -- )    \ output last n hex digits of u
    1 max 10 min            \ safety for n
    dup >r
       0 do dup 4 rshift loop drop
    r> 0 do 0F and 9 over < 7 and + 30 + emit loop ;

: DUMP ( a n -- )
    0 max 1000 min          \ safety for n
    over + >r               \ limit
    begin dup r@ u<
    while cr dup 8 .digits ." : "                   \ .addr
        dup 10 0 do count 2 .digits space loop drop \ .bytes
        ." ["
        10 0 do count dup 7F < and bl max emit loop \ .chars
        ." ]"
    repeat r> 2drop cr ;

\ This DUMP does not depend on BASE
\ --- Options
\ For 16bit addresses: 4 .digits  ( in .addr }
\ For shorter lines:   8 0 do     ( in .bytes & .chars )
\ <><>
