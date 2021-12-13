\ FFBASE enables the use of a temporaray number-base for the next word
\ it works interactively, for immediates and within definitions
\ This code is an adapted version of FFBASE written by A. Nijhof
\ see: https://home.hccnet.nl/anij/c/c211c.html (in Dutch, German version available on same web site)

\ definitions assumed to be available in your Forth:
\   WORD, FIND, >NUMBER

\ CAVE: this code will NOT run on all Forth-implementations


: (BASE) ( xt tempbase -- )
  base @ >r                     \ save base
  base !                        \ temp base
  execute                       \ call xt
  r> base ! ;                   \ reset base


: FFBASE ( tempbase ccc -- )

  CREATE \ ======================
  , immediate

  DOES> \ =======================
  @                             \ fetch temp base
  bl word                       \ get next word from input-stream as counted string
  dup                           \ keep 'addr' for 'convert to number part'

  find                          \ try to find in dictionary and return XT/imm-flag or 0x0
  dup 0 <                       \ was: 'S>D' which on most systems is equivalent to 'dup 0 <'
  state @ and                   \ non-zero on compiling_state=true AND not immediate

  if                            \ >> compile
    drop swap drop
    postpone literal            \ XT
    postpone literal            \ tempbase
    postpone (base)
  else
    if                          \ >> execute
        swap drop swap
        (base)
    else                        \ >> convert to a number if not found in dictionary
        drop swap               \ ( ccc_counted tempbase )
        base @ >r               \ save base
        base !                  \ temp base
        0 swap >number 			\ val,0 or val,+u
        r> base !               \ reset base
        if
        	." error in conversion " drop abort
        then
    then
  then
; \ =============================


\ and some numeric systems...
 1 ffbase UN \ unary
 2 ffbase BN \ binary
 3 ffbase TE \ ternary
 4 ffbase QA \ quaternary
 5 ffbase QI \ quinary
 6 ffbase SE \ senary
 7 ffbase SP \ septenary
 8 ffbase OC \ octal
 9 ffbase NO \ nonary
10 ffbase DM \ decimal
12 ffbase DU \ duodecimal
16 ffbase HX \ hexadecimal
20 ffbase VI \ vigesimal - who knew that?!
