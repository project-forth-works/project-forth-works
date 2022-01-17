\ Tools -- Formatted unsigned single hex number output, not using BASE
\ an-17jan2022

decimal
: .1HX ( x -- )     \ Print last digit of x in hex
    15 and                  \ lowest nibble
    9 over < 7 and +        \ for A..F
    [char] 0 +   emit ;

: .NHX ( x n -- )   \ Print last n digits of x in hex
    1 max 16 min >r                 \ x r: n
    r@ 1 ?do dup 4 rshift loop      \ collect on data stack
    r> 0 do .1hx loop space ;
\ ----- end of code -----

(*
Examples
decimal
19150 2 .nhx     \ CE
19150 3 .nhx     \ ACE
19150 4 .nhx     \ 4ACE
19150 8 .nhx     \ 00004ACE

\ .NHX version without DO-LOOP
: .NHX ( x n -- )   \ Print last n digits of x in hex
    swap >r   1 max 16 min dup          \ n n r: x
    begin 1- dup while r@ 4 rshift >r   \ collect on return stack
    repeat drop
    begin r> .1hx   1- dup 0= until drop space ;
*)
\ <><>

