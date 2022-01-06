\ Animated hedgehog logo on OLED screen, ~430 Bytes
\ From well known words: MS

: EGEL      ( y x -- )          \ Print hedgehog at pos y x
    empty                       \ Erase custom characters
    dm 59 0 >cc  dm 52 0 >cc    \ Build four custom characters: p
    dm 58 1 >cc  dm 51 1 >cc    \ q
    dm 53 2 >cc  dm 56 2 >cc  9 2 >cc  \ r
    dm 45 3 >cc  dm 11 3 >cc    \ s
    >r  dup r@ xy" 0000000000W:`8c58050"
    dup r@ 1+  xy" 5700000000o8^^n]WjnXgV0"
    dup r@ 2 + xy" kpigbhhhge;q]^27o6n4[ii0"
    dup r@ 3 + xy" 0036grd700c0ef6hk07335of0"
    dup r@ 4 + xy" 0000000366kbkVk00b3f`46s0"
        r> 5 + xy" 00000000000000000003bf0" ;

: SHOW      ( -- )
    display-setup  graphic  &page   \ Init. and show Hedgehog
    38 00 do  80 i 2* - 1 egel  10 ms loop \ Move hedgehog to center screen
    80 ms  thin  4 6 xy" Graphic chars"
    A00 ms  &page                   \ Wait then show message
     4 0 xy" Project Forth"         \ Startup message
    28 2 xy" Works"                 \ To line 2
    1A 4 xy" Graphics"              \ To line 4
    20 6 xy" by W.O." ;             \ To line 6

\ End ;;;
