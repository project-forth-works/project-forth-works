\ Graphic character set: 4 x 8 (code space: ~650 bytes)
\ From well known words: BOUNDS

hex
: |     ( bit| -- )
    0  0D parse  8 umin bounds
    do  2*  i c@ ch X =  -  loop  c, ;

create GRAPH    \ Graphic characters 8 x 16 pixels
| ........    \ B0 - 0
| ........
| ........
| ........

| XXXXXXXX    \ B1 - 1
| XXXXXXXX
| XXXXXXXX
| XXXXXXXX

| ......XX    \ B2 - 2
| ......XX
| ........
| ........

| ........    \ B3 - 3
| ........
| ......XX
| ......XX

| XX......    \ B4 - 4
| XX......
| ........
| ........

| ........    \ B5 - 5
| ........
| XX......
| XX......

| ......XX    \ B6 - 6
| ......XX
| ......XX
| ......XX

| XX......    \ B7 - 7
| XX......
| XX......
| XX......

| ..XXXXXX    \ B8 - 8
| ..XXXXXX
| ........
| ........

| ........    \ B9 - 9
| ........
| ..XXXXXX
| ..XXXXXX

| XXXXXX..    \ B10 - :
| XXXXXX..
| ........
| ........

| ........    \ B11 - ;
| ........
| XXXXXX..
| XXXXXX..

| XXXXXXXX    \ B12 - <
| XXXXXXXX
| ........
| ........

| ........    \ B13 - =
| ........
| XXXXXXXX
| XXXXXXXX

| ....XXXX    \ B14 - >
| ....XXXX
| ....XXXX
| ....XXXX

| XXXX....    \ B15 - ?
| XXXX....
| XXXX....
| XXXX....

| ..XXXXXX    \ B16 - @
| ..XXXXXX
| ..XXXXXX
| ..XXXXXX

| XXXXXX..    \ B17 - A
| XXXXXX..
| XXXXXX..
| XXXXXX..

| ......XX    \ B18 - B
| .......X
| ........
| ........

| ........    \ B19 - C
| ........
| .......X
| ......XX

| XX......    \ B20 - D
| X.......
| ........
| ........

| ........    \ B21 - E
| ........
| X.......
| XX......

| ....XXXX    \ B22 - F
| .....XXX
| ......XX
| .......X

| .......X    \ B23 - G
| ......XX
| .....XXX
| ....XXXX

| XXXX....    \ B24 - H
| XXX.....
| XX......
| X.......

| X.......    \ B25 - I
| XX......
| XXX.....
| XXXX....

| ..XXXXXX    \ B26 - J
| ...XXXXX
| ....XXXX
| .....XXX

| .....XXX    \ B27 - K
| ....XXXX
| ...XXXXX
| ..XXXXXX

| XXXXXX..    \ B28 - L
| XXXXX...
| XXXX....
| XXX.....

| XXX.....    \ B29 - M
| XXXX....
| XXXXX...
| XXXXXX..

| XXXXXXXX    \ B30 - N
| .XXXXXXX
| ..XXXXXX
| ...XXXXX

| ...XXXXX    \ B31 - O
| ..XXXXXX
| .XXXXXXX
| XXXXXXXX

| XXXXXXXX    \ B32 - P
| XXXXXXX.
| XXXXXX..
| XXXXX...

| XXXXX...    \ B33 - Q
| XXXXXX..
| XXXXXXX.
| XXXXXXXX

| X.....XX    \ B34 - R
| XX....XX
| XXX..XXX
| XXXXXXXX

| XXXXXXXX    \ B35 - S
| XXX..XXX
| XX....XX
| X......X

| XXXXXXXX    \ B36 - T
| .XXXXXX.
| ..XXXX..
| ...XX...

| ...XX...    \ B37 - U
| ..XXXX..
| .XXXXXX.
| XXXXXXXX

| ...XX...    \ B38 - V
| ........
| ........
| ........

| ........    \ B39 - W
| ........
| ........
| ...XX...

| XXXX....    \ B40 - X
| .XXX....
| ..XX....
| ...X....

| ...X....    \ B41 - Y
| ..XX....
| .XXX....
| XXXX....

| ....XXXX    \ B42 - Z
| ....XXX.
| ....XX..
| ....X...

| ....X...    \ B43 - [
| ....XX..
| ....XXX.
| ....XXXX

| ........    \ B44 - \
| ...XX...
| ...XX...
| ........

| ....XXXX    \ B45 - ]
| ....XXXX
| ........
| ........

| ........    \ B46 - ^
| ........
| ....XXXX
| ....XXXX

| XXXX....    \ B47 - _
| XXXX....
| ........
| ........

| ........    \ B48 - `
| ........
| XXXX....
| XXXX....

| ..XX....    \ B49 - a
| ..XX....
| ....XX..
| ....XX..

| ....XX..    \ B50 - b
| ....XX..
| ..XX....
| ..XX....

| XX......    \ B51 - c
| XX......
| ..XX....
| ..XX....

| ..XX....    \ B52 - d
| ..XX....
| XX......
| XX......

| ....XX..    \ B53 - e
| ....XX..
| ......XX
| ......XX

| ......XX    \ B54 - f
| ......XX
| ....XX..
| ....XX..

| ....XX..    \ B55 - g
| ....XX..
| ....XX..
| ....XX..

| ..XX....    \ B56 - h
| ..XX....
| ..XX....
| ..XX....

| XX....XX    \ B57 - i
| XX....XX
| XX....XX
| XX....XX

| ....XXXX    \ B58 - j
| ....XXXX
| ......XX
| ......XX

| ......XX    \ B59 - k
| ......XX
| ....XXXX
| ....XXXX

| XXXX....    \ B60 - l
| XXXX....
| XX......
| XX......

| XX......    \ B61 - m
| XX......
| XXXX....
| XXXX....

| ......XX    \ B62 - n
| ......XX
| XX......
| XX......

| XX......    \ B63 - o
| XX......
| ......XX
| ......XX
align

create CUSTOM  10 allot  \ Building place for custom graphics chars (p q r s)
: EMPTY     ( -- )       custom 10 0 fill ;
: OR!       ( +n a -- )  >r  r@ c@ or  r> c! ;

: >CC       ( +g +c -- )    \ Construct one of four custom patterns
    >r 4 * graph +  r>      \ Graphic char address
    2* 2* custom +          \ Custom char address
    4 0 do
        over i + c@  over i + or!
    loop  2drop ;

: .CUSTOM   ( +n -- )
    base @ >r  2 base !
    2* 2* custom +  4 bounds do
        cr i c@ s>d <# # # # # # # # # #> type space
    loop 
    r> base ! ;

: .G-ROW    ( a -- )            \ Output 4x8 (graphic) character
    4 {data  4 0 do
        count >data  incr x     \ Output bit row
    loop  drop
    i2c} ;

: GEMIT    ( c -- )
    80 x -  4 < if  drop exit  then  \ Line full? Yes stop!
    ch 0 -  dup 0< throw  dup 3F >   \ Custom char?
    if  40 -  2* 2* custom + .g-row exit  then
    2* 2* graph +  .g-row ;          \ Print graphic pattern

: GRAPHIC   ['] gemit  to o-emit ;


\ Example
: GRAPHICDEMO ( -- )                \ Display graphic token set
    display-setup  thin  &page
    &" Egel project"                \ Startup message
    0A 2 xy" Characters"            \ To line 2
    18 4 xy" by W.O."               \ To line 4

    key drop  graphic  &page
    ch 0 20 bounds do i &emit loop  \ All graphic characters
    0 1 xy ch P 20 bounds do  i &emit  loop
    0 3 xy 20 0 do  &" UT"  loop   \ Some patterns, build

    empty  dm 58 0 >cc  dm 60 0 >cc \ two custom chars  
           dm 59 1 >cc  dm 61 1 >cc \ out of default chars
    0 5 xy 20 0 do  &" pq"  loop ; \ Show both custom chars

\ End
