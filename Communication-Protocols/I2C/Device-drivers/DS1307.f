\ RTC, timer & alarm clock with a DS1307
\ Words from the well-known-words list: <>

hex
\ BCD conversion routines
: >BCD      ( bin -- bcd )  0A /mod  4 lshift + ;
: BCD>      ( bcd -- bin )  >r  r@ 4 rshift 0A *  r> 0F and  + ;

\ Set data 'x' at address 'addr' from DS1307.
: !CLOCK    ( x addr -- )       \ set x in address addr
    68 device!  2 {i2c-write  bus! bus! i2c} ; \ send chip address & clock address

\ Read data 'x' from address 'addr' from DS1307.
: @CLOCK    ( addr -- x )       \ Read de contents from adr, x
    68 device!  1 {i2c-write  bus! i2c}
    1 {i2c-read  bus@ i2c} ;    \ Read data 
    
\ Set & read time to/from DS1307. s(ec) m(in) and h(our) are in decimal!
: SET-CLOCK ( s m h -- ) 2 !clock  >bcd 1 !clock  >bcd 0 !clock ;    
: GET-SEC   ( -- sec )   0 @clock bcd> ;
: GET-MIN   ( -- min )   1 @clock bcd> ;
: GET-CLOCK ( -- s m h ) get-sec  get-min  2 @clock bcd> ;


\ Examples, two free RAM locations in DS1307 we use for 
\ the alarm function and one location for the second tick
08 constant MINS        \ Remember minutes
09 constant SECS        \ Remember seconds
0A constant TIK         \ Seconds tick

: SET-ALARM  ( s m -- )  mins !clock  secs !clock ;
: ALARM?     ( -- f )    get-sec secs @clock =  get-min mins @clock =  and ;
: NEXT-ALARM ( -- )      0A 0 set-alarm  0 0 0 set-clock ;

: TICK      ( -- ) 
    get-sec  tik @clock  <> if  \ Second passed ?
        get-sec  tik !clock     \ Yes, save second
        ch . emit               \ Showing ticks
    then ;


\ Three RTC example programs
: ALARM     ( -- )              \ Perform 10 sec. alarm cycle
    i2c-on  cr ." Start " 
    begin
        next-alarm
        begin  tick  alarm? until \ Wait for alarm. show seconds
        cr ." Ready, wait for next alarm"
    key? until ;


: TIMER     ( sec min -- )      \ Show timer
    i2c-on 
    set-alarm   0 0 0 set-clock \ Next alarm time
    begin  tick  alarm? until   \ wait for alarm, show seconds pulse
    begin  cr ." Ready "  key? until ;


: .TIME     ( -- )
    get-clock  . ." Hr "  . ." Min "  . ." Sec " ;

\ Every second the time is displayed
\ First set the time using SET-CLOCK  ( s m h -- )
: CLOCK     ( -- )
     i2c-on  base @ >r  decimal
     begin
         get-sec  tik @clock  <> if
            get-sec  tik !clock
            cr ." Time " .time 
         then
    key? until
    r> base ! ;

\ End ;;;
