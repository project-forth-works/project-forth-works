\ RTC, timer & alarm clock with a DS1307
\ Words from the well-known-words list: <>

hex
\ BCD conversion routines
: >BCD      ( bin -- bcd )  0A /mod  4 lshift + ;
: BCD>      ( bcd -- bin )  >r  r@ 4 rshift 0A *  r> 0F and  + ;

\ Set data 'x' at address 'addr' from DS1307.
: !CLOCK    ( x addr -- )   \ set x in address addr
    D0 {i2write  i2out} ;   \ send chip address & clock address

\ Read data 'x' from address 'addr' from DS1307.
: @CLOCK    ( addr -- x )   \ Read de contents from adr, x
    D0 {i2write  {i2read)  i2in} ;  \ Repeated start & read data 
    
\ Set & read time to/from DS1307. s(ec) m(in) and h(our) are in decimal!
: SET-CLOCK ( s m h -- ) 02 !clock  >bcd 01 !clock  >bcd 00 !clock ;    
: GET-SEC   ( -- sec )   00 @clock bcd> ;
: GET-MIN   ( -- min )   01 @clock bcd> ;
: GET-CLOCK ( -- s m h ) get-sec  get-min  02 @clock bcd> ;


\ Examples, two free RAM locations in DS1307 we use for 
\ the alarm function and one location for the second tick
08 constant MINS        \ Remember minutes
09 constant SECS        \ Remember seconds
0A constant TIK         \ Seconds tick

: SET-ALARM  ( s m -- )  mins !clock  secs !clock ;
: ALARM?     ( -- f )    get-sec secs @clock =  get-min mins @clock =  and ;
: NEXT-ALARM ( -- )      0A 00 set-alarm  0 0 0 set-clock ;

: TICK      ( -- ) 
    get-sec  tik @clock  <> if  \ Second passed ?
        get-sec  tik !clock     \ Yes, save second
        ch . emit               \ Showing ticks
    then ;


\ Three RTC example programs
: ALARM     ( -- )              \ Perform 10 sec. alarm cycle
    i2c-setup  cr ." Start " 
    begin
        next-alarm
        begin  tick  alarm? until \ Wait for alarm. show seconds
        cr ." Ready, wait for next alarm"
    key? until ;


: TIMER     ( sec min -- )      \ Show timer
    i2c-setup 
    set-alarm   0 0 0 set-clock \ Next alarm time
    begin  tick  alarm? until   \ wait for alarm, show seconds pulse
    begin  cr ." Ready "  key? until ;


: .TIME     ( -- )
    get-clock  . ." Hr "  . ." Min "  . ." Sec " ;

\ Every second the time is displayed
\ First set the time using SET-CLOCK  ( s m h -- )
: CLOCK     ( -- )
     i2c-setup  base @ >r  decimal
     begin
         get-sec  tik clock@  <> if
            get-sec  tik !clock
            cr ." Time " .time 
         then
    key? until
    r> base ! ;

\ End ;;;
