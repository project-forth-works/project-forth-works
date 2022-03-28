\ Conditional compilation -- an 03mar2022
\ Needs [IF] [THEN] [ELSE]

\ ----- forth code -----
0 value VARIANT
: [IF ( ccc] -- )       \ ccc is case-sensitive
    bl word dup c@ 1 max
    begin 1 /string dup
          while over c@ variant =
    until then  nip
    postpone [IF] ; immediate
\ ----- end -----

(*
    [IF A]    -code- [THEN]   \ -code- is only for variant A
    [IF AB]   -code- [THEN]   \ for A and B
    [IF ACDE] -code- [THEN]   \ for A, C, D and E

Je wilt een generieke code schrijven die
slechts in enkele varianten iets verschilt.
Voorwaardelijke compilatie kan een oplossing zijn.
    Geef elke variant een letter.
    [IF leest het volgende "woord" uit de invoerstroom.

You want to write a generic code
that differs only slightly in some variants.
Conditional compilation can be a solution.
    Name each variant with a letter.
    [IF reads the next "word" from the input stream.

Sie wollen einen generischen Code schreiben der sich
nur in einigen Varianten geringfügig unterscheidet.
Die bedingte Kompilierung kann eine Lösung sein.
    Ordnen Sie jeder Variante einen Buchstaben zu.
    [IF liest das nächste "Wort" aus dem Eingabestrom.
*)

\ ----- Test
char A to variant
[IF AC]    1 [ELSE] 0 [THEN] .
[IF CA]    1 [ELSE] 0 [THEN] .
[IF B]     1 [ELSE] 0 [THEN] .
[IF BCEFD] 1 [ELSE] 0 [THEN] .
[IF 13%A]  1 [ELSE] 0 [THEN] .
[IF ]      1 [ELSE] 0 [THEN] .
: test1 [IF BCEFD] 1 [ELSE] 0 [THEN] . ;
char C to variant
: test2 [IF BCEFD] 1 [ELSE] 0 [THEN] . ;
test1
test2

(*
----- Test results
char A to variant  OK
[IF AC]    1 [ELSE] 0 [THEN] . 1  OK
[IF CA]    1 [ELSE] 0 [THEN] . 1  OK
[IF B]     1 [ELSE] 0 [THEN] . 0  OK
[IF BCEFD] 1 [ELSE] 0 [THEN] . 0  OK
[IF 13%A]  1 [ELSE] 0 [THEN] . 1  OK
[IF ]      1 [ELSE] 0 [THEN] . 0  OK
: test1 [IF BCEFD] 1 [ELSE] 0 [THEN] . ;  OK
char C to variant  OK
: test2 [IF BCEFD] 1 [ELSE] 0 [THEN] . ;  OK
test1 0  OK
test2 1  OK
( Have a look at SEE TEST1 and SEE TEST2 )

----- noForth code (VALUE and BL-WORD)
value VARIANT
: [IF ( ccc] -- )       \ ccc is case-sensitive
    bl-word dup c@ 1 max
    begin 1 /string dup
          while over c@ variant =
    until then  nip
    postpone [IF] ; immediate
*)
\ <><>
