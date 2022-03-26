(* Check node connection/availability max. 128 milliseconds

\ Test de tijdsduur voor het controleren van de aanwezigheid van één node 1 ms tot 3 ms
: WRITE-TX? ( -- 0|20 )     \ Send #PAY bytes payload & leave 20 if an ACK was received
    A0 spi-command  'write  #pay        \ Store payload
    for  count spi-out  next  drop  deactivate 
    ce-high  noop noop noop  ce-low     \ Transmit pulse on CE
    response? drop  7 read-reg 20 and ; \ Wait for ACK
    

: PRESENT   ( node -- )         \ Not found takes 3 millisec, found takes 1 millisec.
    ." Node " dup .  80 >ms 
    set-dest  write-mode        \ Activate write mode
    ch | 4 >pay write-tx?  ms) >r \ Send scan command token
    0= if  ." not "  then       \ Try if connection, failed ?
    flush-tx  reset  #ch >channel \ Close transmit action
    80 r> -  ." found in "  .   \ Show used time 
    ." ms "  read-mode  ready ; \ Finish properly

*)

v: inside also
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

v: fresh
\ End ;;;
