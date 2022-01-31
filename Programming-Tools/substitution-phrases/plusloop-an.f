\ STEP? can help if you don't have +LOOP -- an 29jan2022
(*
        limit index DO ... delta +LOOP
   can be coded as
        limit index BEGIN ... delta STEP? UNTIL 2drop
        \ Loop parameters on data stack, I changes to DUP
   or
        limit index BEGIN 2>r ... 2r> delta STEP? UNTIL 2drop
        \ Loop parameters on return stack, I changes to R@
*)

\ ----- Code using S>D WITHIN 2R>
: STEP?             ( limit index delta -- limit index' stop? )
    s>d >r          \ "     "     "             r: delta<0?
    2dup +          \ "     "     delta index'
    2over within >r \ "     "     delta         r: delta<0? stop?
    + 2r> xor ;     \ "     index' stop?        r: -
\ ----- end


\ ----- The same function, simpler but a bit longer
: STEP?             ( limit index delta -- limit index' stop? )
    dup 2over -     \ "     "     "     delta limit-index
    dup 0= xor                                  ( limit=index -> -1 )
    u< 0=           \ "     "     "     stop?
    over 0< xor     \                           ( delta<0 -> invert stop? )
    >r + r> ;       \ "     index' stop?
\ ----- end


(*
\ With DO+LOOP
: T+  ( x y -- ) do i .      4 +loop ;
: T-  ( x y -- ) do i .     -4 +loop ;
: TT+ ( x y -- ) do i u.  2000 +loop ;
: TT- ( x y -- ) do i u. -2000 +loop ;
*)

\ With STEP?
hex
: T+  ( x y -- ) begin dup .      4 step? until 2drop ;
: T-  ( x y -- ) begin dup .     -4 step? until 2drop ;
: TT+ ( x y -- ) begin dup u.  2000 step? until 2drop ;
: TT- ( x y -- ) begin dup .  -2000 step? until 2drop ;

\ ---------- Tests
25 -4    T+
24 -4    T+
23 -4    T+
F000 0  TT+
0 0     TT+
\ ----------
-25 4    T-
-24 4    T-
-23 4    T-
-F000 0 TT-
0 0     TT-
\ ----------

(* Results
@)\ ----------  OK.0
@)25 -4    T+ -4 0 4 8 C 10 14 18 1C 20 24  OK.0
@)24 -4    T+ -4 0 4 8 C 10 14 18 1C 20  OK.0
@)23 -4    T+ -4 0 4 8 C 10 14 18 1C 20  OK.0
@)F000 0  TT+ 0 2000 4000 6000 8000 A000 C000 E000  OK.0
@)0 0     TT+ 0 2000 4000 6000 8000 A000 C000 E000  OK.0
@)\ ----------  OK.0
@)-25 4    T- 4 0 -4 -8 -C -10 -14 -18 -1C -20 -24  OK.0
@)-24 4    T- 4 0 -4 -8 -C -10 -14 -18 -1C -20 -24  OK.0
@)-23 4    T- 4 0 -4 -8 -C -10 -14 -18 -1C -20  OK.0
@)-F000 0 TT- 0 E000 C000 A000 8000 6000 4000 2000  OK.0
@)0 0     TT- 0  OK.0
@)\ ----------  OK.0
*)

\ <><>
