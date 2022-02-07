\ Rolling dice on an OLED screen
\ Uses the graphic character set and a random number generator
\ From well known words: UMIN MS

decimal     \ Add Brodies pseudo random number generator
0 value RND
: RANDOM        ( -- ud )    rnd 31421 *  6927 +  dup to rnd ;
: CHOOSE        ( u1 -- u2 ) random  um* nip ;
: SETUP-RANDOM  ( -- )       31414 to rnd ;

hex
: DOT       ( y x -- )      \ Eight character dot
    6 umin >r  70 umin
        dup  r@    xy" Q11P"
             r> 1+ xy" O11N" ;

: ONE           ( -- )       3C 3 dot ;      \ The six sides of a dice
: TWO           ( -- )       24 6 dot  54 0 dot ;
: THREE         ( -- )       one  two ;
: FOUR          ( -- )       two  24 0 dot  54 6 dot ;
: FIVE          ( -- )       one  four ;
: SIX           ( -- )       four 24 3 dot  54 3 dot ;

create 'DICE    ( -- addr )
    ' one , ' two , ' three , ' four , ' five , ' six , 

: ROLL          ( -- )       6 choose ;    \ Roll dice once
: .DICE         ( -- )       &page  roll cells 'dice +  @ execute ; \ Randomly print the dice value
: ROLL-DICE     ( -- )       7 0 do  i 1+ 20 * ms  .dice  loop ; \ Let the die roll out

: DICE          ( -- )          \ Roll dice, stop when a key is pressed
    &page  graphic  20 >bright
    begin  
        7 0 do  roll drop  loop  .dice  
    key? until  key drop
    roll-dice  C0 >bright ;

\ End ;;;
