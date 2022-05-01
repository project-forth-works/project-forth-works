\ 2LOG with even less frills
\ Albert Nijhof 28apr2022
\ Unsigned argument as input
\ Please Note: For u=0 --> y=0

: B+B ( byte1 byte2 -- x ) 8 lshift or ; 	\ ( 12 34 --> 3412 )

: 2LOG ( u -- y )
    [ 8 cells ] literal     \ #bits/cell
    0 do  s>d
        if  2*
            [ 8 cells 8 - ] literal rshift  \ lineaire interpolatie
            [ 8 cells 1- ]  literal  i -    \ logaritmische klasse
            b+b leave
        then 2*
    loop ;


\ ------------------- some small jokes -------------------
\ and back... (antilog)
hex : -2LOG ( logx -- x )
    >r  r@ FF and 100 or
    r>  8 rshift 8 - s>d
    if abs rshift else lshift then ;

\ a very conveniant square
: SQRT ( u -- y ) 							\ y = sqrt( u ) (unexpectedly accururate)
    2log 2/ -2log ;

\ <><>
