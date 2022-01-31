\ Day of the week -- an 29jan2022
\ Finally, a more professional approach.

\ : M, ( adr len -- ) 0 ?do count c, loop drop ;
: PARSE, [char] , parse dup c, m, ;
create (MESI)
 parse, Gennaio, parse, Febbraio, parse, Marzo,
 parse, Aprile,  parse, Maggio,   parse, Giugno,
 parse, Luglio,  parse, Agosto,   parse, Settembre,
 parse, Ottobre, parse, Novembre, parse, Dicembre,
 parse, ?,
decimal
: .MESE ( n -- )   \ n in [1,12]
    1- 12 umin (mesi) swap 0
    ?do count + loop
    count type space ;
\ <><>
