\ Basic nRF24 bidirectional TRANSMIT routine
\
\ Transmit T & receive : and a count as answer
\
\ Extra words: MS
\ *BIS    ( mask addr -- )    Set the bits represented by mask at address
\ *BIC    ( mask addr -- )    Clear the bits represented by mask at address
\ *BIX    ( mask addr -- )    XOR the bits represented by mask with the bits at address
\ B+B     ( bl bh -- 16-bit ) Combine two bytes to a 16-bit word
\

0 value WAIT      \ Hold on/off period time
: KICK-NRF24    ( -- )
    0 to #me  55 to #ch  1 to rf
    spi-setup  5 ms  setup24L01  7 >len
    1 set-dest  get-status .  troff ;

: TRANSMIT      ( delay -- )
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

: TRANSMITTER     50 transmit ;

\ End ;;;
