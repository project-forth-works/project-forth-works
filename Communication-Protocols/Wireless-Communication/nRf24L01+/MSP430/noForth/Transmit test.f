(* Basic nRF24 bidirectional test routines

Transmit T & receive a count as answer

\ Extra words: MS
\ *BIS    ( mask addr -- )    Set the bits represented by mask at address
\ *BIC    ( mask addr -- )    Clear the bits represented by mask at address
\ B+B     ( bl bh -- 16-bit ) Combine two bytes to a 16-bit word

*)

value WAIT      \ Hold on/off period time
: KICK-NRF24    ( -- )
    0 to #me  55 to #ch  1 to rf
    b0-spi-setup  5 ms  setup24L01
    1 set-dest  get-status .  troff ;

: TRANSMIT1     ( delay -- )
    kick-nrf24  to wait  power-off
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

' test1  to app
shield TRANSMIT\
freeze
