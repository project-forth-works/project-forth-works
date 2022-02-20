\ Basic nRF24 bidirectional test routines
\
\ Recieve T, increase counter & transmit : and counter back
\

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
    begin
        read-mode  cr #me .         \         Extra statusflag RESET added
        xkey dup [char] T = if
            emit  [char] = emit     \         Get command & show
            10 29 *bix              \         P2OUT  Toggle power mosfet output
            dup b-b 6 >pay  5 >pay  \         Counter as payload
            led-on  write-mode      \         to write mode
            5 0 do
            [char] : xemit? 0A = while \      Succeed?
            loop
            ." TXfault " setup24l01 
            else
                dup u.  1+  i .  unloop \      Yes, send counter back, print & incr.
            then
        else
            drop  ." RXfault " setup24l01
        then
        led-off
    key? until  drop ;              \         Remove counter

\ End ;;;
