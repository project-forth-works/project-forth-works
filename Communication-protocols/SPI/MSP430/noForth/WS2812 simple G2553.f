(* WS2812 ledstrip using SPI on MSP430G2553

Note that this code needs a 16 MHz DCO clock frequency
Because the strict timing for WS2812 and alike LEDs the basic
driver has to be coded in assembly. At least on the MSP430!
These are the words ONEBYTE and RENEW

P1.7  - DATA-OUT                \ Data bitstream out  x1=Mosi

You configure this code to connect 1 to 1000 leds, note that at full
power each led consumes ~60 mA so 1000 * 60 = 60.000 mA = 60 Amp!!!

The word DEMO shows some colors on the connected LEDs

*)

dm 40  constant #LEDS           \ Note here the number of WS2812 leds connected
create 'RGB  3 allot  align     \ Color buffer

: >RGB          ( r g b -- )    \ Write down colour scheme in buffer
    'rgb >r  r@ 2 + c!  r@ 1+ c!  r> c! ;

\ The databyte for WS2812 must be present in the register MOON !
\ High-bit: H=625ns, L=375ns, Low-bit: H=375ns, L=625ns
routine ONEBYTE ( -- adr )
    moon swpb                   \ Low databyte to high byte
    #8 day mov                  \ One byte = 8 bits
    begin,
        begin,  #8 3 & .b bit cs? until, \ IFG2  Pulse ready?
        moon moon add           \ Next bit to carry
        cs? if,                 \ Bit high?
            1F # 6F & .b mov    \ UCB0TXBUF  Yes, make high pulse
        else,                   \ No,
            moon moon mov       \ Stretch low off time
            moon moon mov
            07 # 6F & .b mov    \ UCB0TXBUF  Make low pulse
        then,
        #1 day sub              \ Count bits
    =? until,
    rp )+ pc mov  ( ret )
end-code

code RENEW      ( adr -- )  \ Send new color data from adr to #leds
    tos w mov               \ Color array to register w
    #leds # sun mov         \ Set number of leds (40)
    begin,
        tos w mov           \ Color array to register w
        #0 sun cmp
    <>? while,
        w )+ moon .b mov    \ Get R data & increase to next
        onebyte # call      \ Send it
        w )+ moon .b mov    \ Get G data & increase to next
        onebyte # call      \ Send it
        w )+ moon .b mov    \ Get B data & increase to next
        onebyte # call      \ Send it
        #1 sun sub
    repeat,
    sp )+ tos mov           \ Pop stack
    next
end-code

: LED-SETUP     ( -- )
    01 69 *bis          \ UCB0CTL1  Reset USCI
    80 26 *bis          \ P1SEL     P1.7 is SPI out (SIMO)
    80 41 *bis          \ P1SEL2
    09 68 c!            \ UCB1CTL0  Clk=low, LSB first, 8-bit
    80 69 *bis          \ UCB1CTL1  USCI clock = SMClk
    02 6A !             \ UCB1BR0   Clock is 16Mhz/2 = 8 MHz
    00 6C c!            \ UCB0MCTL  Not used must be zero!
    01 69 *bic ;        \ UCB0CTL1  Free USCI

: ON            ( -- )          'rgb renew ;    \ Renew globe from color buffer
: >LEDS         ( r g b -- )    >rgb  on ;      \ Test color scheme


\ Small test program, first some colors
: GREEN         ( -- r g b )    00 30 00 ;
: LGREEN        ( -- r g b )    1C 36 00 ;
: RED           ( -- r g b )    20 00 00 ;
: ORANGE        ( -- r g b )    36 18 00 ;
: BLUE          ( -- r g b )    00 00 30 ;
: LBLUE         ( -- r g b )    00 18 18 ;
: PINK          ( -- r g b )    20 00 20 ;
: WHITE         ( -- r g b )    18 18 18 ;
: BLACK         ( -- r g b )    00 00 00 ;

: .RGB          ( -- )          'rgb count . count . c@ . ; \ Show last used color
: FLASH         ( c2 c1 -- )    >leds 400 ms  >leds 400 ms ; \ Show two colors

: DEMO          ( -- )
    green lgreen flash   lblue blue flash
    orange red flash   white pink flash   black orange flash ;

: SHOW          ( -- )          led-setup  1 ms  demo ;

' show  to app
shield WS2812\  freeze
