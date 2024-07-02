\ ----- String handeling with overflow protected string-variables -----
\ [jh jan2024] [based on ideas and work by: Albert Nijhof dated: 09dec2021 and ALbert van de Horst]

\ Functional differences with the version of Albert Nijhof:
\ 1). a new string is defined and initialised with $VARIABLE, no need for SET$
\ 2). length is an unsigned number
\ This mandates the use of the non-standard words: UMIN U>=
\ Example implementations for these are provided - comment these out
\ if your system provides these as (fast) primitives

: UMIN ( u1 u2 -- smallest_u )
    2dup u> if swap drop else drop then ;
: U>= ( u1 u2 -- f/t )
    swap u> 0= ;

\ ***** SUPPORT WORDS

: GET$  ( $var -- adr len )    @ @+ ;
: ADR$  ( $var -- adr )     @ cell+ ;
: LEN$  ( $var -- len )         @ @ ;
: MAX$  ( $var -- max )     cell+ @ ;
: DEL$  ( $var -- )      @ 0 swap ! ;
: 3DROP ( m n o -- ) drop drop drop ;


\ ***** CREATION NEW STRING-VARIABLE

: $VARIABLE ( maxlen _$variable_ "name" -- ) \ creates new $var and empty string
    here over cell+             \ ( max buf max+4 )
    allot align                 \ ( max buf ) space for: (count-cell + max_len + align) alloted
    dup 0 swap !                \ ( max buf ) make sure created string is empty
    create , , ;                \ create definition with buffer-address & maxlen there after


\ ***** STRING MANIPULATION ROUTINES

: ADD$ ( a u $var -- ) \ add string to $variable
    @+ >r                       \ r: buffer-address
    @ r@ @ -                    \ free space
    umin                        \ overflow protection
    r@ @+ +                     \ a u endadr
    over r> +!                  \ update count
    swap move ;

: SET$ ( a u $var -- ) \ put string in $variable - overwrites new string in existing $var
    dup del$ add$ ;

: CADD$ ( char $var -- ) \ add a character to end of $variable
    @+ >r                       \ r: buffer-address
    r@ @ swap @                 \ buffer not full?
    < if r@ @+ + c!             \ store char
        1 r> +!                 \ update count
    else r> 2drop
    then ;

: <COPY$> ( a l s $var -- ) \ support-word - moves string within string-variable - handles max
    >r 2dup + r@ max$           \ ( a l s l+s max )
    u> if                       \ ( a l s )
        nip dup                 \ ( a s s )
        r@ adr$ + swap          \ ( a adr+s s )
        r> max$ swap -          \ ( a adr+s max-s ) ready for move
    else
        r> adr$ + swap          \ ( a adr+s l ) ready for move
    then move ;

: OVERWRITE$ ( a l s $var -- ) \ overwrite a $var with a string from point s
    >r                          \ ( a s l ) r: $var
\ check for l=0 -> exit
    over 0= if                  \ ( a l s l=0? )
        rdrop 3drop exit
    then                        \ ( a l s )
\ check for s u> len$ -> exit
    dup r@ len$ u> if           \ ( a l s s>len$? )
        rdrop 3drop exit
    then                        \ ( a l s )
\ first handle (l+s) u> max
    2dup + r@ max$ u> if        \ l+s > max ( a l s )
        r@ <copy$>
        r@ max$ r> @ !          \ update len$=max$
        exit
    then                        \ ( a l s )
\ next handle (l+s) u> len$
    2dup + r@ len$ u> if        \ ( a l s )
        2dup + r@ @ !           \ update len#=l+s
        r> <copy$>
        exit
    then
\ other cases
    r> <copy$> ;

: INSERT$ ( a l s $var -- ) \ insert string at location s
    >r                          \ ( a s l ) r: $var
\ check for l=0 -> exit
    over 0= if                  \ ( a l s l=0? )
        rdrop 3drop exit
    then                        \ ( a l s )
\ check for s u> len$ -> exit
    dup r@ len$ u> if           \ ( a l s s>len$? )
        rdrop 3drop exit
    then                        \ ( a l s )
\ handle (l+s) u>= max -> no move needed
    2dup + r@ max$ u>= if       \ l+s > max ( a l s )
        r@ <copy$>
        r@ max$ r> @ !          \ update len$=max$
        exit
    then                        \ ( a l s )
\ handle (l+len$) u>= max$
    over                        \ ( a l s l )
    r@ len$ +                   \ ( a l s l+len$ )
    r@ max$ u>= if              \ ( a l s )
        2dup dup                \ ( a l s l s s )
        r@ adr$ +               \ ( a l s l s adr$+s )
        -rot + dup              \ ( a l s adr$+s l+s l+s )
        r@ adr$ + swap          \ ( a l s adr$+s adr$+l+s l+s )
        r@ max$ swap -          \ ( a l s adr$+s adr$+l+s len$'=max-l-s ) ready for move
        move                    \ ( a l s )
        r@ <copy$>              \ ( -- )
        r@ max$ r> @ !          \ update len$=max$
        exit
    then                        \ ( a l s )
\ handle rest of cases
    2dup dup r@ adr$ +          \ ( a l s l s adr$+s )
    -rot                        \ ( a l s adr$+s l s )
    + r@ adr$ +                 \ ( a l s adr$+s adr$+l+s )
    r@ len$                     \ ( a l s adr$+s adr$+l+s len$ ) ready for move
    move                        \ ( a l s )
    over r@ len$ + r@ @ !       \ ( a l s ) update len
    r> <copy$> ;                \ ( -- )


: LSUB$ ( i $var -- ) \ del i chars from left side of string and close the gap
    @ >r                        \ r: buffer-address
    r@ @ over u<=               \ ( i len i )
    if drop 0 r> !              \ delete string by setting len to zero
    else                        \ ( i ) here i < len -> crop string
        r@ cell+                \ ( i str-addr )
        2dup + swap             \ ( i str+i str )
        rot r@ @ swap -         \ ( str+i str len-i ) - ready for move
        dup r> ! move           \ ( -- ) update len - move
    then ;

: RSUB$ ( i $var -- ) \ del i chars from right side of string
    @ swap over @               \ get len
    tuck umin -                 \ calc new_len
    swap ! ;                    \ store len in buffer

: MIDSUB$ ( s i $var -- ) \ delete i chars from mid of string, starting at s, and close the gap
    >r                          \ ( s i ) r: $var
    swap                        \ ( i s ) r: $var
    r@ len$ umin                \ ( i to_point ) r: $var - calc to_point
    swap over                   \ ( to_point i to_point ) r: $var
    r@ len$ swap - umin         \ ( to_point gap ) r: $var
    over                        \ ( to_point gap to_point ) r: $var
    r@ adr$ + -rot              \ ( des_addr to_point gap ) r: $var

    2dup r@ adr$ + +            \ ( des to_point gap addr+gap+to_point ) r: $var
    r@ adr$ r@ len$ + umin      \ ( des to_point gap src ) r: $var
    -rot                        \ ( des src to_point gap ) r: $var
    r@ len$                     \ ( des src to_point gap len ) r: $var

    2dup swap -                 \ ( des src to_point gap len len' ) r: $var
    r> @ !                      \ ( des src to_point gap len ) - update len$

    swap - swap -               \ ( des src len-gap-to_point )
    >r swap r>                  \ ( src des len' ) ready for move
    move ;


\ ***** SELECT PART OF STRING -- NO CHANGES IN STRING

: RSEL$ ( n $var -- adr len ) \ selects string with n chars from right
    dup >r len$ umin            \ ( lowest_of_(n len) )
    dup r@ len$ swap -          \ ( n' len-n' )
    r> adr$ + swap ;            \ ( addr+len-len_n' len_n' )

: LSEL$ ( n $var -- addr len ) \ selects string with n chars from right
    dup len$                    \ ( n $var len )
    rot umin                    \ ( $var len_n )
    swap adr$ swap ;            \ ( adr len' )

: MIDSEL$ ( s l $var -- addr len ) \ selects string from s with l chars
    >r over                     \ ( s l s ) r: $var
    r@ len$ swap -              \ ( s l len-s ) r: $var
    umin swap                   \ ( l' s ) r: $var
    r@ adr$ +                   \ ( l' addr+s ) r: $var
    r@ adr$ r> len$ +           \ ( l' addr+s addr+len
    umin swap ;                 \ ( addr+s l' )


\ ***** OTHER FUNCTIONALITY

: CLEAN$ ( $var -- ) \ fills area between end of string and max with zeroes
    dup adr$ >r                 \ $var r: buf
    dup max$ swap len$          \ max len
    over umin dup               \ max min_len min_len
    r> + -rot -                 \ buf+len max-min_len
    0 fill ;

: TYPE$ ( $var -- ) \ types upto 2500 chars of $variable
    get$ 2500 min type ;

\ ***** END OF CODE
