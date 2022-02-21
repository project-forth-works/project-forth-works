\ Basic nRF24 bidirectional test routines
\
\ Transmit T & receive a count as answer
\

value WAIT
: KICK-NRF24    ( -- )
    0 to #me  55 to #ch  1 to rf
    b0-spi-setup  5 ms  setup24L01
    1 set-dest  get-status .  troff ;

: TRANSMIT1     ( delay -- )
    kick-nrf24  to wait
    ." Transmitter " #me . space
    begin
        cr  ch T xemit  #me 1 .r    \ Transmit T, show myself
        response? if                \ Wait for an answer
            xkey emit               \ Get it & show
            space 5 pay> 6 pay> b+b u. \ Fetch counter, show & wait
            wait ms
        then
    key? until ;

: TEST1     50 transmit1 ;

\ End ;;;
