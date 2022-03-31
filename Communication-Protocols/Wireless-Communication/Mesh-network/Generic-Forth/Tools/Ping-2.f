\ Check node connection/availability max. 128 milliseconds
\
\ Show response time of tested node and the connections of this node

: PING      ( node -- )
    base @ >r  decimal                  \ Number base to decimal
    0  3 0 ?do                          \ Init. error counter
        cr ." Node " over .  ." ping " i . \ Show node nmbr & attempt number
        80 >ms  over ch P >node  <<wait>> \ Ping 'node' with 128 millisec. timeout
        (ms 80 < if                     \ Succeeded?
            ."  time is "  (ms .  ." ms " \ Yes, show time duration 
        else
            ."  timeout "  1+           \ No, failed incr. error counter
        then
    loop  nip 
    r> base !  3 < if                   \ Restore number base & not all attempts failed?
        cr ." Direct " data-buffer .map \ Yes, then show node maps of pinged node
        ."  indirect " data-buffer 2 + .map
    then ;

\ End ;;;
