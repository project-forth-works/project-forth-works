\ STEP? can help if you don't have +LOOP -- an 31jan2022
(*
        limit index DO ... delta +LOOP
   can be coded as
        limit index BEGIN ... delta STEP? UNTIL 2drop
        \ Loop parameters on data stack, I changes to DUP
   or
        limit index BEGIN 2>r ... 2r> delta STEP? UNTIL 2drop
        \ Loop parameters on return stack, I changes to R@
*)

\ ----- Code using WITHIN
: STEP?             ( limit index delta -- limit index' stop? )
    s>d >r          \ "     "     "             r: deltasign
    2dup +          \ "     "     delta idx'
    2over within >r \ "     "     delta         r: deltasign stop?
    + 2r> xor ;     \ "     idx'  stop?         r: -
\ ----- End

\ ----- Code without WITHIN
: STEP?             ( limit index delta -- limit index' stop? )
    s>d over 2>r +  \ limit index'                  r: deltasign delta
    2dup - negate   \ "     "      idx'-lim
    dup r> -        \ "     "      "        idx-lim r: deltasign
    u<              \ "     "      stop?
    r> xor ;        \ delta<0? -> invert stop?      r: -
\ ----- End

(*
\ With DO+LOOP
: T1+ ( x y -- ) do i .      1 +loop ;
: T+  ( x y -- ) do i .      4 +loop ;
: TT+ ( x y -- ) do i u.  2000 +loop ;  \ For 16b forth!
: T1- ( x y -- ) do i .     -1 +loop ;
: T-  ( x y -- ) do i .     -4 +loop ;
: TT- ( x y -- ) do i u. -2000 +loop ;  \ For 16b forth!
*)

\ With STEP?
hex
: T1+ ( x y -- ) begin dup .      1 step? until 2drop ;
: T+  ( x y -- ) begin dup .      4 step? until 2drop ;
: TT+ ( x y -- ) begin dup u.  2000 step? until 2drop ;
: T1- ( x y -- ) begin dup .     -1 step? until 2drop ;
: T-  ( x y -- ) begin dup .     -4 step? until 2drop ;
: TT- ( x y -- ) begin dup .  -2000 step? until 2drop ;

\ ---------- tests
 4 -4    t1+
 25 -4    t+
 24 -4    t+
 23 -4    t+
 F000 0  tt+
 0 0     tt+
\ ----------
 -4 4    t1-
 -25 4    t-
 -24 4    t-
 -23 4    t-
 -F000 0 tt-
 0 0     tt-
 \ ----------

(* Results
@)\ ---------- tests  OK.0
@) 4 -4    t1+ -4 -3 -2 -1 0 1 2 3  OK.0
@) 25 -4    t+ -4 0 4 8 C 10 14 18 1C 20 24  OK.0
@) 24 -4    t+ -4 0 4 8 C 10 14 18 1C 20  OK.0
@) 23 -4    t+ -4 0 4 8 C 10 14 18 1C 20  OK.0
@) F000 0  tt+ 0 2000 4000 6000 8000 A000 C000 E000  OK.0
@) 0 0     tt+ 0 2000 4000 6000 8000 A000 C000 E000  OK.0
@)\ ----------  OK.0
@) -4 4    t1- 4 3 2 1 0 -1 -2 -3 -4  OK.0
@) -25 4    t- 4 0 -4 -8 -C -10 -14 -18 -1C -20 -24  OK.0
@) -24 4    t- 4 0 -4 -8 -C -10 -14 -18 -1C -20 -24  OK.0
@) -23 4    t- 4 0 -4 -8 -C -10 -14 -18 -1C -20  OK.0
@) -F000 0 tt- 0 -2000 -4000 -6000 -8000 6000 4000 2000  OK.0
@) 0 0     tt- 0  OK.0
@) \ ----------  OK.0
*)

\ <><>
