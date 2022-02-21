(* Basic nRF24 bidirectional test routines

Recieve T, increase counter & transmit : and counter back

\ B+B     ( bl bh -- 16-bit ) Combine two bytes to a 16-bit word

*)

: KICK-NRF24    ( -- )
    1 to #me  55 to #ch  1 to rf
    b0-spi-setup  5 ms  setup24L01
    0 set-dest  get-status .  troff ;

\ Receiver software, does no longer hang!
\ Trace info: <cr> #me - T=" - counter
\         or: <cr> #me - "xXfault "
: RECEIVER   ( -- )
    kick-nrf24  ." Receiver " #me .
    10 2A *bis  10 029 *bis         \ P2DIR, P2OUT  Power mosfet on
    100 ms  10 29 *bic   00         \ P2OUT   and off, init. counter
    read-mode
    begin
        response? if                \         Action on nRF24? 
          cr  #me 1 .r              \         Yes, show node number
          xkey dup [char] T = if    \         Char 'T' received?
            emit  ." = "            \         Yes, show
            10 29 *bix              \ P2OUT   Toggle power mosfet output
            dup b-b 6 >pay  5 >pay  \         Counter as payload
            [char] : xemit          \         Send ':'  & counter back
            dup u.  1+              \         Show & increase counter
          else
            drop  ." RXfault "
          then
        then
        led-off
    key? until  drop ;              \         Remove counter

' receiver  to app
shield RECEIVER\  freeze