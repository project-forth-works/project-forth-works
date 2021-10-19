(* WS2812 ledstrip using SPI on MSP430FR5949

P2.5  - DATA-OUT                \ Data bitstream out  x1=Mosi

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
        begin,  #2 5FC & .b bit cs? until, \ UCA1IFG  Pulse ready?
        moon moon add           \ Next bit to carry
        cs? if,                 \ Bit high?
            1F # 5EE & .b mov   \ UCA1TXBUF  Yes, make high pulse
        else,                   \ No,
            moon moon mov       \ Stretch low off time
            moon moon mov
            07 # 5EE & .b mov   \ UCA1TXBUF  Make low pulse
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
        w )+ moon .b mov    \ Get R data & increase to next
        onebyte # call      \ Send it
        w )+ moon .b mov    \ Get G data & increase to next
        onebyte # call      \ Send it
        w )+ moon .b mov    \ Get B data & increase to next
        onebyte # call      \ Send it
        #1 sun sub
    0=? until,
    sp )+ tos mov           \ Pop stack
    next
end-code

: LED-SETUP     ( -- )
    01 5E0 **bis        \ UCA1CTLW Reset eUSCI
    20 20B *bic         \ P2SEL0    P2.5 is SPI out
    20 20D *bis         \ P2SEL1    SPI active
    8981 5E0 !          \ UCA1CTLW  Clk=low, LSB first, Master, Synch, 3-wire, SMClk
    02 5E6 !            \ UCA1BRW   Clock is 16Mhz/2 = 8 MHz
    01 5E0 **bic ;      \ UCA1CTLW  Free eUSCI

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
