\ Interfacing HC-SR04, US-015, RCW-0001, etc. ultrasonic distance sensor.
\ Port input & output at P1 & P2 with MSP430G2553.

\  Address 020 = P1IN    - port-1 input register
\  Address 021 = P1OUT   - port-1 output register
\  Address 022 = P1DIR   - port-1 direction register
\  Address 027 = P1REN   - port-1 resistor enable
\  Address 029 = P2OUT   - port-2 output register
\  Address 02A = P2DIR   - port-2 direction register
\
\ HC-SR04
\  Echo = P1.3
\  Trig = P1.4
\
\ The protocol for this sensor is:
\ 1- Give trigger pulse of at least 10us at 'Trig'.
\ 2- Wait for 'Echo' to go high
\ 3- Wait for 'Echo' to go low while counting the pulselength
\ 4- Convert the resulting number to centimeter
\
\ This example is software timed so very much dependant of the
\ clock frequency and the Forth implementation. Note that:
\ activated interrupts will influence the result.
\
\ This formula is correct for an 8 MHz MSP430:  20 93 */
\ You must adjust the scaling values for different CPU's & Forth systems.
\
\ The usable range of most Chinese HC-SR04 clones is only 2cm to 220cm.
\
\ Not in Generic Forth: MS 

hex
\ Words with hardware dependencies:
: *BIS  ( mask addr -- )        tuck c@ or  swap c! ; 
: *BIC  ( mask addr -- )        >r  invert  r@ c@ and  r> c! ;
: BIT*  ( mask addr -- b )      c@ and ;

: US-ON     ( -- )
    08 22 *bic      \ P1DIR  P1.3 Input with pullup
    08 27 *bis      \ P1REN
    08 21 *bis      \ P1OUT
    10 22 *bis      \ P1DIR  P1.4 Output
    10 21 *bic      \ P1OUT
    3F 2A *bis ;    \ P2DIR  Six leds

\ The trigger pulse must be about 10 microseconds. The formula below 
\ is only correct for an 8 MHz MSP430 running noForth:  20 93 */
: DISTANCE  ( -- distance in cm )
    10 21 *bis  noop noop noop  10 21 *bic  \ P1OUT  Trigger
    begin  8 20 bit* until                  \ P1IN   Wait for echo
    0  begin  1+  8 20 bit* 0= until        \ P1IN   Measure echo
    dm 20 dm 93 */ ;    ( Scale result to centimeter )

: FLASH     ( -- )  3F 29 *bis 200 ms  3F 29 *bic 200 ms ; \ P2OUT

: MEASURE   ( -- )              \ Show distance in 2 cm steps
    us-on  flash  begin  distance 2/ 29 c!  40 ms  key? until ; \ P2OUT

shield US\  freeze

\ End