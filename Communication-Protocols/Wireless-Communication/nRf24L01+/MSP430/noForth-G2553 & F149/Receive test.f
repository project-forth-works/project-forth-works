(* Basic nRF24 bidirectional test routines

Recieve T, increase counter & transmit : and counter back

\ Extra words: MS
\ *BIS    ( mask addr -- )    Set the bits represented by mask at address
\ *BIC    ( mask addr -- )    Clear the bits represented by mask at address
\ *BIX    ( mask addr -- )    XOR the bits represented by mask with the bits at address
\ B-B     ( 16-bit -- bl bh ) Split 16-bit to a low byte & high byte

*)

: KICK-NRF24    ( -- )
    1 to #me  55 to #ch  1 to rf
    spi-setup  5 ms  setup24L01  7 >len
    0 set-dest  get-status .  troff ;

\ Trace info: <cr> #me - T=" - counter
\         or: <cr> #me - "xXfault "
: RECEIVER   ( -- )
    kick-nrf24  ." Receiver " #me .
    power-on  100 ms  power-off  00 \ Init. counter
    read-mode
    begin
        response? if                \ Action on nRF24? 
          cr  #me 1 .r              \ Yes, show node number
          xkey dup [char] T = if    \ Char 'T' received?
            emit  ." = "            \ Yes, show
            power-bip               \ Toggle power output
            dup b-b 6 >pay  5 >pay  \ Counter as payload
            [char] : xemit          \ Send ':'  & counter back
            dup u.  1+              \ Show & increase counter
          else
            drop  ." RXfault "
          then
        then
        led-off
    key? until  drop  power-off ;   \ Remove counter

' receiver  to app
shield RECEIVER\  freeze
