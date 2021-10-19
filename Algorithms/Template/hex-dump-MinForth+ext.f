\ Dump utility in Minimal Forth with use of the extension word set (WO 2021-09-16)
\ This source code provides a simple HEX dump utility.
\
\ Memory is accessed by C@ output is perfomed by EMIT.
\ So this dump utility can be used also on quite limited systems.
\
\ Usage:
\   <addr> <len> DUMP
\
\ 4400 40 dump
\ 4400: 36 45 16 B3 01 20 30 46 36 90 00 90 07 34 07 93 |6E    0F6    4  |
\ 4410: 37 44 03 20 36 80 01 88 05 56 00 4F 36 90 00 70 |7D  6    V O6  p|
\ 4420: 06 34 06 11 24 83 84 47 00 00 07 46 00 4F 36 80 | 4  $  G   F O6 |
\ 4430: 01 78 05 56 00 4F 00 00 83 84 4E 4F 4F 50 00 44 | x V O    NOOP D|

: BOUNDS    ( a u -- ae ab )  over + swap ;
: PEMIT     ( c -- )          dup 7F < and  BL max  emit ;    \ Protected EMIT
: PTYPE     ( a u -- )        bounds do i c@ pemit loop ;     \ Protected TYPE
: .BYTE     ( c -- )          0 <# # # #> type space ;        \ Print hex byte
: .ADDR     ( x -- )          0 <# # # # # #> type ;          \ Print 16-bit hex address
\ : .ADDR     ( x -- )          0 <# # # # # # # #> type ;    \ Print 24-bit hex address

: DUMP  ( a u -- )
    hex  0 do
        cr  dup .addr ." : "                \ Print address (six wide)
        dup 10 bounds do  i c@ .byte  loop  \ Dump 16 bytes in hex.
        [char] | emit  dup 10 ptype ." | "  \ Print 16 bytes in visible ASCII
        10 +  key? if leave then            \ Adjust address & test for key
    10 +loop  drop ;                        \ Next 16 bytes

\ End ;;;
