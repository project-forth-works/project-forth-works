# Measuring distances

The idea is to measuring distance using ultrasonic sensors.  


## Ultrasonic sensors

The most well known ultrasonic sensor is the HC-SR04 but there are a lot
of different types available. Most use the same protocol. Some of them are
different.  


|  Sensor | Voltage |  Some data |
| -------- | ------------ | ----------------------- | 
| HC-SR04 | 5 Volt | Range 2 cm to 220 cm |
| US-015  | 5 Volt | Range | 8 cm to 350 cm |
| RCW-0001 | 3 to 5 Volt | 1 cm to 350 cm |
| US-100 | 2.4 to 5 Volt | 4 cm to 350 cm |

Most sensors have four wires and use two wires for communication.

```
1) VCC  = Mostly % Volt but some work from 2.4 Volt
2) TRIG = Trigger input ( 10 µsec. positive pulse )
3) ECHO = Result, the length of the positive pulse is the measured distance
4) GND  = Ground pin
```

## Pseudo code

|  Name | Function |
| -------- | ----------------------- | 
| `US-ON` | Activate I/O pins |
| `DISTANCE` | Do one measurement, leave scaled result |
| `MEASURE` | Print measured distance until a key is pressed |

```
Function: US-ON  ( -- )
  Initialise one output and one input with pullup
  Set the output low.

Function: DISTANCE  ( -- distance )
  Give 10 µsec. pulse in the trigger output
  Wait until the echo input goes high
  Initialise a counter
  Increase counter in a loop until echo goes low again
  Scale result, converting the count to a distance in centimeter

Function: MEASURE  ( -- )
  Perform US-ON the start an endless loop
  Perform DISTANCE,  Perform .  wait 40 millisec.
  Do this loop until a key is pressed 
```

## Generic Forth

```forth
\ This example uses bits P1.3 and P1.4 on the MSP430G2553 using noForth
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
    10 21 *bic ;    \ P1OUT

\ The trigger pulse must be about 10 microseconds. The formula below 
\ is only correct for an 8 MHz MSP430 running noForth:  20 93 */
: DISTANCE  ( -- distance in cm )
    10 21 *bis  noop noop noop  10 21 *bic  \ P1OUT  Trigger
    begin  8 20 bit* until                  \ P1IN   Wait for echo
    0  begin  1+  8 20 bit* 0= until        \ P1IN   Measure echo
    dm 20 dm 93 */ ;    ( Scale result to centimeter )

: MEASURE   ( -- )              \ Show distance in 2 cm steps
    us-on  begin  distance .  40 ms  key? until ;

``` 

More info look at the Egel project [chapter 8](https://home.hccnet.nl/willem.ouwerkerk/egel-for-msp430/egel%20for%20launchpad.html#e008), [chapter 13](https://home.hccnet.nl/willem.ouwerkerk/egel-for-msp430/egel%20for%20launchpad.html#e013) and/or [chapter 17](https://home.hccnet.nl/willem.ouwerkerk/egel-for-msp430/egel%20for%20launchpad.html#e017).  
