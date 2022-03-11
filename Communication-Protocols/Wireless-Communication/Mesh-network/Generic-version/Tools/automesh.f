(* Automatic netwerk (one ring) simple buildup with demo programm
*)

: BUILD     ( -- )
    ." from " .status               \ Show nRF24 status
    scanx cr  ch s direct >others   \ SCANX on myself & all new found nodes
    hop cr  ch h direct >others     \ HOP on myself & all new found nodes
    info cr  ch i direct >others ;  \ Gather all node information & ready

: RUNNER    ( -- )      \ Running light on all outputs in my network
    run  begin
        all >user
        begin  user up? while
        dup on  100 <wait>
        off  30 <wait>  repeat
    halt? until ;

: START-MESH ( -- )
    startnode  cr build  cr runner ;

\ End ;;;
