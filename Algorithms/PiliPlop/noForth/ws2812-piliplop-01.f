\ PiliPlop used on WS2812 to flow smooth from one color to another

hex
\ Generic Forth needs these additional words: UMIN  ABS  +!  1+  */  MS
\ Note that MS is a software timed loop and the value 190 should
\ be adjusted for each individual Forth system! This value is
\ about correct for an 8 MHz compact noForth system.

3 constant #COLORS
: VARIABLES    create here ,  cells allot  does> @ swap cells + ; \ Array of cells
: RANGE         ( u1 s1 -- u2 s2 ) 2 umin >r  FF umin  r> ; \ WS2812 limits
#colors variables SHERE
#colors variables THERE
#colors variables DIRECTION
#colors variables TANK
#colors variables USAGE
value STEPS         \ Largest color change in steps
value WAIT          \ Wait time after each color change

: PREPARE       ( -- )
    0 to steps  #colors 0 do
        i there @  i shere @            \ Finish & start
        2dup u< 2* 1+  i direction !    \ 1 or -1
        - abs  dup i usage !            \ Positive distance
        steps umax  to steps            \ Keep largest distance
    loop
    #colors 0 do  steps 2/  i tank !  loop ; \ Tanks half full

: ONE-STEP      ( -- )
    #colors 0 do
        i tank @  i usage @  -          \ Subtract USAGE from TANK
        dup i tank !  0< if             \ Save & check for empty?
            steps  i tank +!            \ Yes, fiil TANK with STEPS
            i direction @  i shere +!   \ Add DIRECTION to SHERE
            i shere @  i 'rgb + c!      \ SHERE is current process color value
        then
    loop 
    on  wait ms ;   \ Activate next WS2812 color & wait

value REST          \ Variable stable time for each destination color
: ALL-ONCE      ( -- )          steps 0 do one-step loop ;     \ Flow to next color
: (GO)          ( -- )          prepare  all-once  rest ms ;   \ Perpare next color, flow & hold it
: (1COLOR)      ( c l -- )      range there ! ;                \ Store color 'l'
: >COLOR        ( r g b -- )    #colors 0 do 2 i - (1color) loop ; \ Set dest. color from stack
: GO            ( r g b -- )    >color  (go) ;                 \ Go flow to dest. color from stack

value PERIOD        \ Color change period in seconds
: >SPEED        ( u -- )        140 umin  to wait ;            \ Set color STEP duration
: .SPEED        ( -- )          wait u. ;                      \ Show STEP duration
: >REST         ( u -- )        to rest ;                      \ Set hold time for destination color
: 1COLOR        ( c l -- )      (1color)  (go) ;               \ Change one color & flow to it
: WHAT          ( -- b g r )    #colors 0 do 2 i - shere @  loop ; \ Leave reversed RGB color data

: .COLORS       ( -- )          \ Show RGB data, STEP time & REST time in millisec.
    what  #colors 0 do . loop space  .speed  rest u. ;

: MOVE-ALL      ( r g b -- )    cr .colors  go ;               \ GO with color info
: STEPSIZE      ( -- )          period  dm 1000  steps */  to wait ; \ Calc WAIT time from PERIOD
: >PERIOD       ( sec -- )      to period  stepsize ;          \ Set PERIOD in seconds
: GOTIMED       ( r g b -- )    >color  prepare  stepsize  all-once ; \ GO with PERIOD time color change

: SETUP-PILI    ( -- )          \ Initialise PiliPlop data structures
    #colors 0 do  0  i shere !  loop
    #colors 0 do  0  i there !  loop
    5 >speed  200 >rest ;       \ 5 ms for each color step, hold final color 512 ms

: DEMO2         ( -- )          \ Change color in default steps of 5 ms
    led-setup  10 ms  setup-pili
    begin
        red go        green go
        blue go       white go
    key? until
    black go ;

: DEMO3         ( -- )          \ Change color in 5 second periods
    led-setup  10 ms  setup-pili  0 >rest  5 >period
    begin
        red gotimed   green gotimed
        blue gotimed  white gotimed
    key? until
    black gotimed ;

\ shield piliplop\
\ ' demo2  to app   freeze
    
\ End ;;;
