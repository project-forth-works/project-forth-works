\ Usage examples for 'Primitive-string-word-set.f'

20 $variable LIBRARY$  21 allot

: LIBPATH   ( -- a u )      s" c:\GenericForth\Lib" ;
: .LIB      ( -- )          library$ $@ $. ;

: LIB-FILE" ( "name" -- )
    libpath library$ $!           \ Set path to library files
    [char] \ library$ $c+!        \ Add backslash
    [char] " parse library$ $+! ; \ Add wanted file to path
    
lib-file" Circular buffer V0.00.f"   .lib
lib-file" PiliPlop.f"  .lib

\ End ;;;
