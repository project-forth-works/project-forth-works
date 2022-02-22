\ Basic nRF24 bidirectional SEND & RECEIVE routines
\
\ Transmit T & receive : and a count as answer
\

0 value WAIT      \ Hold on/off period time
: KICK-NRF24    ( -- )
    0 to #me  55 to #ch  1 to rf
    b0-spi-setup  5 ms  setup24L01
    1 set-dest  get-status .  troff ;

: TRANSMIT      ( delay -- )
    kick-nrf24  to wait
    10 2A *bis  10 29 *bic          \ Output off
    ." Transmitter " #me . space
    begin
        cr  ch T xemit  #me 1 .r    \ Transmit T, show myself
        response? if                \ Wait for an answer
            xkey emit               \ Get it & show
            space 5 pay> 6 pay> b+b u. \ Fetch counter, show & wait
            wait ms
        then
    key? until ;

: TRANSMITTER     50 transmit ;

\ End ;;;
