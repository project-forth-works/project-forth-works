(* Educational demo applications

    <NEXT?  - Reverse order bit table node available test
    KNIGHT  - Wireless knight rider demo
    RUNNER  - Wireless running light
    FLASH1  - Flash all nodes
    FLASH2  - Double flasher on all nodes

*)

v: inside also
: DOWN?     ( a -- false | node true )  \ Reverse order table readout
    #n for              \ Test all bits
        i over get*     \ Node bit set?
        if  i swap *clr  r> true exit  then
    next  drop  false ; \ Nothing found

: KNIGHT   ( -- )      \ Knight rider on all outputs in my network
    run  begin
        all >user  A0 <wait>
        begin  user up? while  on   80 <wait>  repeat
        all >user  A0 <wait>
        begin  user down? while  off  80 <wait>  repeat
    halt? until ;


: RUN-FORW  ( -- )      \ Running light on all outputs in my network
    run  begin
        all >user
        begin  user up? while
        dup on  100 <wait>
        off  30 <wait>  repeat
    halt? until ;

: RUN-BACKW ( -- )      \ Running light on all outputs in my network
    run  begin
        all >user
        begin  user down? while
        dup on  100 <wait>
        off  30 <wait>  repeat
    halt? until ;



: FLASH1    ( -- )      \ Flash all outputs in my network
    run  begin  all-on  80 <wait>  all-off  300 <wait>  halt? until ;



: FLASH2    ( -- )      \ Double flash all outputs in my network
    run  begin
        all-on  20 <wait>  all-off  80 <wait>
        all-on  20 <wait>  all-off 300 <wait>
    halt? until ;

: START-MESH ( -- )
    startnode  cr build  flash2 ;

v: fresh
' start-mesh  to app   shield mesh\  freeze

\ End ;;;
