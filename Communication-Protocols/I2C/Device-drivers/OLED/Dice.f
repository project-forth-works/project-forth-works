\ Rolling dice on an OLED screen
\ Uses the graphic character set and a random generator
\ From well known words: UMIN MS

decimal     \ Add Brodies pseudo random number generator
0 value RND
: RANDOM        ( -- ud )       rnd 31421 *  6927 +  dup to rnd ;
: CHOOSE        ( u1 -- u2 )    random  um* nip ;
: SETUP-RANDOM  ( -- )          31414 to rnd ;

hex
: DOT       ( y x -- )      \ Eight character dot
    6 umin >r  70 umin
        dup  r@    xy" Q11P"
             r> 1+ xy" O11N" ;

: ONE       3C 3 dot ;      \ The six sides of a dice
: TWO       24 6 dot  54 0 dot ;
: THREE     one  two ;
: FOUR      two  24 0 dot  54 6 dot ;
: FIVE      one  four ;
: SIX       four 24 3 dot  54 3 dot ;

: .DICE     ( +n -- )       \ Print dice
    &page
    dup 1 = if  one     then
    dup 2 = if  two     then
    dup 3 = if  three   then
    dup 4 = if  four    then
    dup 5 = if  five    then
        6 = if  six     then ;

: ROLL          6 choose 1+ ;    \ Roll dice once
: DO-DICE       roll .dice ;     \ Randomly print the dice
: ROLL-DICE     7 0 do  i 1+ 20 * ms  do-dice  loop ; \ Let the die roll out

: DICE      ( -- )          \ Roll dice once stop when akey was pressed
    &page  graphic  20 >bright
    begin  
        7 0 do  roll drop  loop  do-dice  
    key? until  key drop
    roll-dice  C0 >bright ; \ Roll out & show result

\ End ;;;
