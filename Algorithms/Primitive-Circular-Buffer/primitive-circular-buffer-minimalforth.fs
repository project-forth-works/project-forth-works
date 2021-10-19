    \ primitive circular buffer in Minimal Forth                   uh 2021-07-29

    \ Some missing contemporary words: -ROT BOUNDS 2DROP FILL

    \ ALLOT : assume n ALLOT reserves n address units of data space (RAM)
    \ HERE  : assume HERE returns the next available data space ( RAM ) address
   
    : -ROT ( x1 x2 x3 -- x3 x1 x2 ) ROT ROT ;

    : BOUNDS ( c-addr1 u -- c-addr2 c-addr1 ) OVER + SWAP ;

    : 2DROP ( x1 x2 -- )  DROP DROP ;

    : FILL  ( c-addr u c -- ) 
        OVER IF 
           -ROT BOUNDS DO  DUP I C!  LOOP DROP
        ELSE
           DROP 2DROP
        THEN 
    ;
    \ -----------------------------------------------------------------
    \ Primitive Circular Buffer
    
    8 CONSTANT k  \ k must be a power of 2 so that wrapping can be done by masking
    VARIABLE idx  0 idx !
    HERE k CELLS ALLOT  CONSTANT circular-buffer    

    circular-buffer  k CELLS  0 FILL

    : 'item ( -- addr ) 
        circular-buffer idx @ CELLS + ;

    : wrap-around ( u1 -- u2 )
        k 1 - AND 
    ;

    : store-new-value ( x -- )
        'item !
        idx @  1 + wrap-around  idx ! 
    ;

    : read-oldest-value ( -- x )
        'item @
    ;

    : read-ith-oldest-value ( i -- x ) \ 0: oldest … k-1: youngest
        idx @ + wrap-around  CELLS  circular-buffer +  @  
    ;
