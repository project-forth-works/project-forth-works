\ Day of the week -- an-10jan2022
\ From number to name, not using the case statement

\   0   1   2   3   4   5   6
\   sun mon tue wed thu fri sat

\ For constant string length
: .DAY ( n -- )    \ n in [0,6]
    7 umin
    s" SunMonTueWedThuFriSat???" drop
    swap 3 * + 3 type space ;

\ 3 .day  -> wed
\ 8 .day  -> ???

\ For irregular string length
: .DAY ( n -- )    \ n in [0,6]
    7 umin
    s" 3Sun 3Mon 4Tues 6Wednes 5Thurs 3Fri 5Satur 1?" drop
    swap 0
    ?do begin count bl = until
    loop count [char] 0 - type
    ." day " ;

\ 3 .day  -> Wednesday
\ 9 .day  -> ???day

\ Try this for months. ( :septiembre )
\ : M, ( adr len -- ) 0 ?do count c, loop drop ;
decimal create (MESES)
ch " parse 5enero 7febrero 5marzo 5abril 4mayo 5junio 5julio "    m,
ch " parse 6agosto :septiembre 7octubre 9noviembre 9diciembre 1?" m,
    align
: .MES ( n -- )   \ n in [1,12]
    1- 12 umin (meses) swap 0
    ?do begin count bl = until
    loop count [char] 0 - type space ;

\ 9 .mes  -> septiembre
\ 0 .mes  -> ?

\ <><>
