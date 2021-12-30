\ I2C driver for SSD1306, a 128x32 pixels OLED screen.
\ Add separate files with a small, big, bold & graphic character set.

hex
0 value INV?                \ Partly inverted display?
: INV       ( b1 -- b2 )    inv? invert xor ;
: WHITE     ( -- )          true to inv? ;
: BLACK     ( -- )          false to inv? ;
: {ol       ( b -- )        78 {i2write ;           \ Start an oled command: b=00 or old data: b=40
                                                    \ Single byte command: b=80, single byte data: b=C0 
: {DATA     ( -- )          40 {ol ;                \ Start OLED data stream
: >DATA     ( b -- )        inv  i2out ;            \ Single pixel row
: END}      ( -- )          i2stop} ;               \ End data stream
: DATA}     ( b -- )        inv i2out} ;            \ End OLED data stream
: {CMD      ( -- )          00 {ol ;                \ Start OLED command stream
: >CMD      ( b -- )        i2out ;                 \ Output extra command
: CMD}      ( b -- )        i2out} ;                \ End an OLED command stream
: CMD       ( b -- )        80 {ol  i2out} ;        \ Single byte oled command
: 2CMD      ( b1 b0 -- )    {cmd  >cmd  i2out} ;    \ Dual byte oled command
: >BRIGHT   ( b -- )        81 2cmd ;               \ b = 0 to 255 (max. brightness)
: ON/OFF    ( flag -- )     1 and  AE or cmd ;      \ Display on/off
: INVERSE   ( flag -- )     1 and  A6 or cmd ;      \ Invert whole display to black or white

0 value X   0 value Y
: XY        ( x y -- )          \ Set OLED column and row
    {cmd                        \ Command stream
    dup to y  7 and B0 or >cmd  \ Set page
    dup to x  dup 0F and >cmd   \ Set column
    F0 and 4 rshift 10 or cmd} ;

: DISPLAY-SETUP ( -- )
    i2c-setup               \ Init. 400kHz I2C
    false on/off            \ Display off
    {cmd                    \ Start oled-command stream
    0A8 >cmd  01F >cmd      \ Set multiplexer ratio
    0D5 >cmd  080 >cmd      \ Set oscillator clock
    0D3 >cmd  000 >cmd      \ Display offset = 0
    040 >cmd                \ Display starts at line 0
    08D >cmd  014 >cmd      \ Charge pump on
    0A0 >cmd                \ Mirror X-axis = A1
    0C0 >cmd                \ Mirror Y-axis = C8
    0DA >cmd  002 >cmd      \ Alternate Com pin map
    0D9 >cmd  022 >cmd      \ Set precharge cycles to high cap.
    0DB >cmd  040 >cmd      \ VCOMH voltage to max.
    0A4 >cmd                \ Enable rendering from GDRAM
    020 >cmd  000 cmd}      \ Horizontal display mode, end stream
    C0 >bright              \ Set contrast to 75%
    false inverse  white    \ Oled in normal mode
    true on/off ;           \ Display on

: &FILL         ( +n b -- ) \ Pattern 'b' to +n columns
    {data   swap            \ Start oled-data stream
    begin                   \ Whole screen buffer
        over >data          \ Output pattern
    1- ?dup 0= until  end}  drop ; \ End stream

: .BITROW   ( a +n -- )     \ Output half of +Nx14 (big) character
    {data  0 >data  0 do
        count >data  1+     \ Output every second bit row
    loop  drop
    0 data} ;

: &EOL          ( -- )          {data  0 do  0 >data  loop  i2stop} ;
: &ERASE        ( -- )          480 0 &fill ;       \ Erase screen
: &HOME         ( -- )          0 0 xy ;            \ To upper left corner
: &PAGE         ( -- )          &erase  &home ;
: &CR           ( -- )          0 y 2 + xy ;
0 value O-EMIT  \ OLED emit vector
: &EMIT         ( c -- )        o-emit execute ;
: &SPACE        ( -- )          bl &emit ;
: &SPACES       ( u -- )        0 do  &space  loop ;
: &TYPE         ( a u -- )      bounds do  i c@ &emit  loop ;
: &U.           ( n -- )        0 <# #s #> &type &space ;
: C>N           ( c -- +n )     bl - ;  \ Convert char to bitmap index number

: &"            ( -- )          \ ." voor OLED
    postpone s"  postpone &type ;  immediate

: XY"       ( x y ccc -- )      \ XY" voor OLED
    postpone xy  postpone &" ; immediate

\ End ;;;
