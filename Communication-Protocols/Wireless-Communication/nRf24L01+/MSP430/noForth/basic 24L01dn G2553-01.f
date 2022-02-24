\ This version-01, USCI_B0 runs on noForth C2553 version 200202 & later.
\
\ USCI hardware SPI on MSP430G2553 using port-1 & port-2.
\ SPI i/o interfacing the nRF24L01 with two or more Launchpad boards
\ Micro Launchpads and/or Egel kits.
\
\ Connect the SPI lines of USCIB P1.5=CLOCKPULSE, P1.6=DATA-IN, P1.7=DATA-OUT
\ P1.4=CSN,  P2.3=CE of the nRF24L01. On the Egel kit it's just putting the
\ module in the connector marked nRF24L01!!
\
\ Note that decoupling is very important right near the nRF24l01 module. The
\ Egel kit vsn-2 has an extra 22uF near the power connections. The Launchpad
\ and the Egel kit vsn-1 need an extra 10uF or more for decoupling!!
\
\ More info on page 445 of SLAU144J.PDF  Configuration of the pins on
\ page 49 of SLAS735J.PDF
\
\ SPI USCI master
\
\                    MSP430G2xx3
\              ^  -----------------
\             /|\|              XIN|- Optional 32.768 kHz xtal
\              | |                 |
\              --|RST          XOUT|- Idem
\                |                 |
\          IRQ ->|P2.5         P1.7|-> Data Out (UCB0SIMO)
\                |                 |
\           CE <-|P2.3         P1.6|<- Data In (UCB0SOMI)
\                |                 |
\          CSN <-|P1.4         P1.5|-> Serial Clock Out (UCB0CLK)
\                |                 |
\          LED <-|2.0          P2.4|-> Power out
\
\ Concept: Willem Ouwerkerk & Jan van Kleef, october 2014
\ Current version: Willem Ouwerkerk, 28 januari 2021
\
\ Launchpad & Egel kit documentation for USCI SPI
\
\ P1 & P2 are used for interfacing the nRF24L01+
\ P2.3  - CE                      \ Device enable high  x1=Enable
\ P2.5  - IRQ                     \ Active low output   x0=Interrupt
\ P1.4  - CSN                     \ SPI enable low      x1=Select
\ P1.5  - CLOCKPULSE              \ Clock               x1=Clock
\ P1.6  - DATA-IN                 \ Data bitstream in   x0=Miso
\ P1.7  - DATA-OUT                \ Data bitstream out  x1=Mosi
\ P2.0  - Led red                 \ XEMIT led
\ P2.4  - Power led               \ Power output 2 Amp.
\ P1.0  - Analog input            \ Optional
\ P1.3  - Switch S2               \ Default
\
\ Free I/O:   P1.0, P2.1, P2.2, P2.6, P2.7
\
\ Used P1 & P2 register adresses:
\ 20 = P1IN      - Input register
\ 21 = P1OUT     - Output register
\ 22 = P1DIR     - Direction register
\ 26 = P1SEL     - Configuration register 1
\ 27 = P1REN     - Resistance on/off
\ 41 = P1SEL2    - Configuration register 2
\ 29 = P2OUT     - Output register
\ 2A = P2DIR     - Direction register
\ 2E = P2SEL     - Configuration register 1
\ 2F = P2REN     - Resistance on/off
\
\ nRF basic timing:
\    Max. SPI clock:         8 MHz
\    Powerdown to standby:   1,5 ms
\    Standby to TX/RX:       0,13 ms
\    Transmit pulse CE high: 0,01 ms
\
\ Sensitivity: 2Mbps – -83dB, 1Mbps – 87dB, 250kbps – -96dB.
\ Receiving current: 2Mbps – 15mA, 1Mbps – 14.5mA, 250kbps – 14mA
\
\ On board PCB antenna, transmission distance reach 240M in open area, but
\ 2.4G frequency is not good to pass through walls, also interfere by
\ 2.4G wifi signal significantly.
\
\ Software parts to adjust for different clock speeds:
\ 1) B0-SPI-SETUP - SPI clock speed
\ 2) #IRQ         - Software timing loop to wait for ACK
\ 3) WRITE-DTX?   - Transmit pulse CE (10 µsec software timing)
\
\ Dynamic payload length
\
\ 1) SPI-commands 60  - Leest lengte van ontvangen payload, die staat in het tweede byte
\                 A8  - Zet lengte van payload on pipe 0 t/m 7 en 1 t/m 32 databytes (LSB eerst)
\ 2) Registers    1C  - Activeer de dynamic payload voor een of meer 'data pipes'
\                 1D  - Dynamic payload configuratie en aan/uit
\
\ Dynamic payload format from 1 to 32 bytes:
\ |   0   |  1  |  2  |    3   |  4  |  5 to 31   |
\ |-------|-----|-----|--------|-----|------------|
\ |Command|Dest.|Orig.|Sub node|Admin|d00| to |d1A|
\
\ 0 pay>  = Command for destination      1 pay>       = Destination node
\ 2 pay>  = Origin node                  3 pay>       = Address of sub node
\ 4 pay>  = Administration byte          5 to 31 pay> = Data 0x1A (#26) bytes
\
\ Extra routines needed:
\
\ /MS     ( u -- )            Wait in steps of 100 µsec.
\ *BIS    ( mask addr -- )    Set the bits represented by mask at address
\ *BIC    ( mask addr -- )    Clear the bits represented by mask at address
\ BIT*    ( mask addr -- b )  Leave the bits b from mask that were high at address
\ B+B     ( bl bh -- 16-bit ) Combine two bytes to a 16-bit word
\ B-B     ( 16-bit -- bl bh ) Split 16-bit to a low byte & high byte
\
\ MSP430 assembly code for speed up:
\ code IRQ?   ( -- flag )   \ Flag is true when IRQ = low
\    tos sp -) mov
\    20 # 28 & .b bit       \ P2IN
\    tos tos subc
\    tos adr ack? & mov     \ Save tos in ACK?
\    next
\ end-code
\
\ /MS routine for noForth:
\ : /MS       ( u -- )    ms# >r  r@ 0A / to ms#  ms  r> to ms# ;
\

hex
\ NOTE: This value must be adjusted for different clock speeds & MPU's!!!
\ It is the timeout for receiving an ACK handshake after a transmit!!
  200 constant #IRQ     \ Delay loops for XEMIT)    (8 MHz)
\ 400 constant #IRQ     \ 16 MHz

value T?                \ Tracer on/off
: TEMIT     t? if  dup emit  then  drop ;  \ Show copy of char
: TRON      true to t? ;    : TROFF     false to t? ;
: LED-ON    1 29 *bis ;     : LED-OFF   1 29 *bic ;
: /MS       ( u -- )    0 ?do  140 0 do loop  loop ;

value ACK?              \ Remember IRQ flag
: IRQ?      ( -- flag )     20 28 bit* 0=  dup to ack? ;

: RESPONSE? ( -- flag )     \ Leave true when an IRQ was received
    false  #irq 0 do  irq? if  1-  leave  then  loop ;

                    ( USCI-B0 SPI interface to nRF24L01+ )

: B0-SPI-SETUP  ( -- )
    spi-on
    19 2A *bis      \ P2DIR     P2.3 is CE, P2.0=Led, P2.4 is power out
    20 2A *bic      \ P2DIR     P2.5 is input
    20 2F *bis      \ P2REN     P2.5 resistor on (IRQ)
    21 29 *bis      \ P2OUT     P2.5 pullup, led on
    08 29 *bic ;    \ P2OUT     ce  = 0 (Red led off = 9)


                ( Read and write to and from nRF24L01 )

value #CH             \ Used channel number
value #ME             \ Later contains node number
\ The first written byte returns internal status always
\ It is saved in the value STATUS using SPI-COMMAND
: GET-STATUS    ( -- s )    {spi  FF spi-i/o  spi} ;
: SPI-COMMAND   ( c -- )    {spi  spi-out ;
\ Reading and writing to registers in the 24L01
: WMASK       ( b1 -- b2 )  1F and  20 or ;
: READ-REG      ( r -- b )  1F and  spi-command  0 spi-i/o  spi} ;
: WRITE-REG     ( b r -- )  wmask spi-command  spi-out  spi} ;
\ Write the communication addresses, of pipe-0 default: E7E7E7E7E7
: WRITE-ADDR  ( trxa -- )   wmask spi-command  5 0 do spi-out loop  spi} ;
: SET-MY-ADDR   ( -- )      F0 F0 F0 F0 #me 0B write-addr ; \ Set ME own receive address


                ( nRF24L01+ control commands and setup )

\ Empty RX or TX data pipe
: FLUSH-RX      ( -- )      E2 spi-command  spi} ; \ Remove received data
: FLUSH-TX      ( -- )      E1 spi-command  spi} ; \ Remove transmitted data
: RESET         ( -- )      70 7 write-reg ;            \ Reset IRQ flags
: PIPES-ON      ( mask -- ) 3F and  2 write-reg ;       \ Set active pipes
: WAKEUP        ( -- )      0E 0 write-reg ;    \ CRC 2 bytes, Powerup
: >CHANNEL      ( +n -- )   5 write-reg ;       \ Change RF-channel 7-bits

value RF              \ Contains nRF24 RF setup
\ Bitrate conversion table: 0=250 kbit, 1=1 Mbit, 2=2 Mbit, 3=250 kBit.
    20 c, 00 c, 08 c,  20 c, \ 250 kbit, 1 Mbit, 2 Mbit
: RF!   ( db bitrate -- )   b+b to rf ; \ Save RF-settings
: RF@   ( -- db bitrate )   rf b-b ;    \ Get RF-settings

\ db:  0 = -18db, 1 = -12db, 2 = -6db, 3 = 0db )
\ bitrate:  0 = 250 kbit, 1 = 1 Mbit, 2 = 2 Mbit
: >RF           ( db bitrate -- )       \ Change nRF24 RF settings
    3 and  [ ' rf >body cell+ ] literal \ Address of conversion table
    + c@ >r  3 and 2*  r> or  6 write-reg ;

3 1 rf! \ Initialise RF settings


\ Dynamic payload additions
20 constant #PAY            \ Payload size max. 32 bytes
value PAY                   \ Contains current length of the payload
: >LENGTH   ( +n -- )       1 max  20 umin  to pay ; \ Set dynamic payload length
: DEFAULT   ( -- )          7 >length ;

\ Elementary command set for the nRF24L01+
: SETUP24L01    ( -- )
( ) default             \ Default payload length
( ) 3 1C write-reg      \ Allow dynamic payload on Pipe 0 & 1
( ) 6 1D write-reg      \ Enable dynamic payload, ACK on!
    0C 0 write-reg      \ Enable CRC, 2 bytes
    03 1 write-reg      \ Auto Ack pipe 0 & 1
    02 pipes-on         \ Pipe 1 on
    set-my-addr         \ Set receive address
    03 3 write-reg      \ Five byte address
    1F 4 write-reg      \ Retry after 500 us & 15 retry's
    #ch >channel        \ channel #CH to start with
    rf@ >rf             \ 1 Mbps, max. power
    #pay 11 write-reg   \ #pay bytes payload in P0
    #pay 12 write-reg   \ #pay bytes payload in P1
    reset               \ Enable CRC, 2 bytes & reset flags
    flush-rx  flush-tx  \ Start empty
    wakeup  0F /ms      \ Power up
    led-off ;


\ Format: Command, Dest.node, Org.node, Sub.node, Aux, Data-0, Data-1, .. to Data-x

create 'READ    #pay allot  \ Receive buffer
create 'WRITE   #pay allot  \ Transmit buffer

: WRITE-DTX? ( -- 0|20 )        \ Send #PAY bytes payload & leave 20 if an ACK was received
    A9 spi-command 'write pay   \ Store dynamic payload for pipe-0
    0 do  count spi-out  loop  drop  spi}
    8 29 *bis  noop noop noop  8 29 *bic    \ P2OUT  Transmit pulse on CE
    response? drop  7 read-reg 20 and ;     \ Wait for ACK
    

: READ-DRX? ( -- f )            \ Receive 1 to 32 bytes
    60 read-reg dup 20 > if  flush-rx  drop false exit  then
    61 spi-command  'read swap bounds
    ?do  0 spi-i/o i c!  loop   spi}  true ;

: '>PAY     ( +n -- a )     'write + ;  \ Leave address of TX payload
: >PAY      ( b +n -- )     '>pay c! ;  \ Store byte for TX payload
: 'PAY>     ( +n -- a )     'read + ;   \ Leave address of RX payload
: PAY>      ( +n -- b )     'pay> c@ ;  \ Read byte from RX payload


                    ( Send and receive commands for nRF24L01 )

: WRITE-MODE    ( -- )          \ Power up module as transmitter
    8 29 *bic  wakeup           \ P2OUT  CE low, receive off, wakeup transmitter
    1 pipes-on  reset  2 /ms ;  \ Reset flags & pipe-0 active, wait 200 microsec.

: READ-MODE     ( -- )
    0F 0 write-reg  2 pipes-on  \ Power up module as receiver, activate pipe-1
    reset  8 29 *bis  2 /ms ;   \ P2OUT  Enable receive mode, wait 200 microsec.

A constant #TRY                 \ Transmit attempts
8 constant #RETRY               \ Re-transmit attempts for XEMIT
: XEMIT?        ( c -- +n )     \ +n = #TRY when transmit has failed
    0 >pay  0  #try 0 do        \ Try it 10 * ARC = 150 times max.
        write-dtx? if leave then \ Ready when it was an Ack!
        flush-tx  reset  1+     \ Reset flags & empty pipeline, count failures
        dup /ms  #ch >channel   \ Variable repeat time, clear packet loss
    loop
    flush-tx  reset ;

value #FAIL     \ Note XEMIT failures
: BUSY      ( -- )
    read-mode  40 0 do                  \ Wait while a channel is busy
        4 /ms  9 read-reg 0=            \ Check for no carrier?
        if  leave  then  ch . temit     \ Ready when no carrier
    loop ;

\ Node primitive XEMIT now with retry & restart after a failed XEMIT?
: XEMIT     ( c -- )
    0 to #fail  begin
        led-on
        busy  write-mode  dup temit \ Check carrier, show echo
        dup xemit? #try <> if       \ Send payload
            drop  led-off  read-mode  exit
        else
            led-off  incr #fail  setup24l01 \ TX failed, reinit.
        then
        #fail #me 1+ 2* * /ms       \ Variable retry time
    #fail #retry = until            \ (#TRY * 15)* #RETRY = 1200 retries in total
    drop  read-mode ;

: XKEY          ( -- c )
    begin
        begin
            7 read-reg 40 and 0=    \ Payload received?
        ack? and while              \ and IRQ noticed
            setup24l01  read-mode   \ No, restart 24L01
            response? drop
        repeat
        read-drx?        \ Yes read payload packet
    until  0 pay>       \ Now read command from packet
    reset  flush-rx     \ Empty pipeline
    8 29 *bic ;         \ To standby II

\ Set destination address to node from stack, receive address is my "me"
: SET-DEST      ( node -- )
    dup >r  1 >pay  #me 2 >pay      \ Set Destination & origin nodes
    F0 F0 F0 F0 r@ 0A write-addr    \ Receive address P0
    F0 F0 F0 F0 r> 10 write-addr ;  \ Transmit address


shield 24L01\   freeze

\ End ;;;
