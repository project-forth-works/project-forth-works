\ This version eUSCI_B1 runs on noForth C5994 version 200202ff.
\
\ eUSCI hardware SPI on MSP430FR5949 using port-2.
\ SPI i/o interfacing the nRF24L01 with two or more Launchpad boards
\ Micro Launchpads, Egel kits & other boards.
\
\ Connect the SPI lines of eUSCI-A1 P2.4=CLOCKPULSE, P2.6=DATA-IN,
\ P2.5=DATA-OUT, P2.3=CSN, P2.2=CE and P2.7=IRQ of the nRF24L01.
\
\ Note that decoupling is very important right near the nRF24l01 module. The
\ MLP FR5 has an extra 22uF near the power connections.
\
\ More SPI info on page 795ff of SLAU367O.PDF  Configuration of the pins on
\ page 90ff of SLAS704G.PDF
\
\ SPI eUSCI master
\
\                   MSP430FR5949
\              ^  -----------------
\             /|\|              XIN|- Optional 32.768 kHz xtal
\              | |                 |
\              --|RST          XOUT|- Idem
\                |                 |
\          IRQ ->|P2.7         P2.5|-> Data Out (UCA1SIMO)
\                |                 |
\           CE <-|P2.2         P2.6|<- Data In (UCA1SOMI)
\                |                 |
\          CSN <-|P2.3         P2.4|-> Serial Clock Out (UCA1CLK)
\                |                 |
\                |             P1.4|-> Power out
\
\ Concept: Willem Ouwerkerk & Jan van Kleef, october 2014
\ Current version: Willem Ouwerkerk, januari 2020
\
\ Launchpad documentation for eUSCI SPI
\
\ Port P2 is used for interfacing the nRF24L01+, P1.4 is power out
\
\ P1.4  - Output                  \ Mosfet power output max. 12 Volt
\ P2.2  - CE                      \ Device enable high  x1=Enable
\ P2.7  - IRQ                     \ Active low output   x0=Interrupt
\ P2.3  - CSN                     \ SPI enable low      x1=Select
\ P2.4  - CLOCKPULSE              \ Clock               x1=Clock
\ P2.5  - DATA-OUT                \ Data bitstream out  x1=Mosi
\ P2.6  - DATA-IN                 \ Data bitstream in   x0=Miso
\ PJ.1  - Led
\ PJ.0  - Switch S2
\
\
\ Used register adresses:
\ Addresses  - Labels       - Bit patterns
\ 1CC   15C  - WDTCL        - Off already
\ 20A   20A  - P1SEL0       - 00C
\ 20C   20C  - P1SEL1       - 00C
\ 680   680  - UCB1CTLW0    - FF1
\ 682   682  - UCB1CTLW1    - 000
\ 686   686  - UCB1BR0      - 050
\ 688   688  - UCB1STATW    - sss USCI status
\ 68C   68C  - UCB1RXBUF    - rrr RX Data
\ 68E   68E  - UCB1TXBUF    - ttt TX Data
\ 694   694  - UCB1I2C0A    - ooo NC
\ 6A0   6A0  - UCB1I2CSA    - 042 /2
\ 6AA   6AA  - UCB1CIE      - 000 USCI interrupt enable
\ 6AC   6AC  - UCB1IFG      - 002 = TX ready, 001 = RX ready
\
\
\ Label    P1  P2  P3  P4  P5  P6  P7  P8  PJ   Function
\ -----------------------------------------------------
\ PxIN     200 201 220 221 240 241 260 261 320  Input
\ PxOUT    202 203 222 223 242 243 262 263 322  Output
\ PxDIR    204 205 224 225 244 245 264 265 324  Direction
\ PxREN    206 207 226 227 246 247 266 267 326  Resistor enable
\ PxSEL0   20A 20B 22A 229 24A 24B 26A 26B 32A  Select 0
\ PxSEL1   20C 20D 22C 22D 24C 24D 26C 26D 32C  Select 1
\ PxIV     20E 21E 22E 22F 24E 24E 26E 26E      Interrupt vector word
\ PxSELC   210 211 230 231 250 251 260 271 336  Complement selection
\ PxIES    218 219 238 239 258 259 268 279      Interrupt edge select
\ PxIE     21A 21B 23A 23B 25A 25B 26A 27B      Interrupt on
\ PxIFG    21C 21D 23C 23D 25C 25D 26C 27D      Interrupt flag
\
\ 680 = eUSCI-B1  - Start of eUSCI registers
\
\ nRF basic timing:
\   Max. SPI clock:         8 MHz
\   Powerdown to standby:   1,5 ms
\   Standby to TX/RX:       0,13 ms
\   Transmit pulse CE high: 0,01 ms
\
\ Sensitivity: 2Mbps – -83dB, 1Mbps – 87dB, 250kbps – -96dB.
\ Receiving current: 2Mbps – 15mA, 1Mbps – 14.5mA, 250kbps – 14mA
\
\ On board PCB antenna, transmission distance reach 240M in open area, but
\ 2.4G frequency is not good to pass through walls, also interfere by
\ 2.4G wifi signal significantly.
\
\ Software parts to adjust for a different clock speed:
\ 1) SPI-ON       - SPI clock speed
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
\ : /MS       ( u -- )    0 ?do  280 0 do loop  loop ;
\
\ value ACK?              \ Remember IRQ flag
\ : IRQ?      ( -- flag )     2 220 bit* 0=  dup to ack? ;
\


hex  v: inside also  definitions
\ NOTE: This value must be adjusted for different clock speeds & MPU's!!!
\ It is the timeout for receiving an ACK handshake after a transmit!!
\ 300 constant #IRQ     \ Delay loops for XEMIT)    (8 MHz)
  600 constant #IRQ     \ 16 MHz

value T?                \ Tracer on/off
: TEMIT     t? if  dup emit  then  drop ;  \ Show copy of char
v: extra definitions
: TRON      true to t? ;    : TROFF     false to t? ;
: LED-ON    2 322 *bis ;    : LED-OFF   2 322 *bic ;
: POWER-ON  10 202 *bis ;   : POWER-OFF  10 202 *bic ;
: POWER-BIP 10 202 *bix ;
: /MS       ( u -- )    ms# >r  r@ 0A / to ms#  ms  r> to ms# ;

value ACK?              \ Remember IRQ flag
v: inside definitions
code IRQ?   ( -- flag ) \ Flag is true when IRQ = low
    8324 , 4784 , 0 ,   \ tos sp -) mov
    B0F2 , 80 ,  201 ,  \ 80 # 201 & .b bit \ P2IN
    7707 ,              \ tos tos subc
    4782 , adr ack? ,   \ tos adr ack? & mov  \ Save tos in ACK?
    next                \ next
end-code

: RESPONSE? ( -- flag )     \ Leave true when an IRQ was received
    false  #irq 0 do  irq? if  1-  leave  then  loop ;


                    ( USCI-B1 SPI interface to nRF24L01+ )

code CE-HIGH    ( -- )  ( D2F2 ,  203 , ) #4 203 & .b bis  next end-code
code CE-LOW     ( -- )  ( C2F2 ,  203 , ) #4 203 & .b bic  next end-code
: SPI-SETUP     ( -- )
    spi-on
    10 204 *bis     \ P1DIR     P1.4 is power output 
    01 326 *bis     \ PJREN     PJ.0  Resistor on
    02 324 c!       \ PJDIR     PJ.1 is LED
    01 322 c!       \ PJOUT     Red LED off, Pullup on PJ.0
    0C 205 c!       \ P2DIR     P2.2=CE & P2.3=CSN, P2.7=IRQ for SPI
    80 207 *bis     \ P2REN     P2.7 resistor on
    88 203 c! ;     \ P2OUT     P2.2 CE=0, P2.3 CSN=1, P2.7 IRQ = pullup     

spi-setup   \ Activate SPI


                ( Read and write to and from nRF24L01+ )

value #CH               \ Used channel number
v: extra definitions
value #ME               \ Later contains node number
v: inside definitions
\ The first written byte returns internal status always
\ It is saved in the value STATUS using SPI-COMMAND
: GET-STATUS    ( -- s )    {spi  FF spi-i/o  spi} ; \ CSN
: SPI-COMMAND   ( c -- )    {spi  spi-i/o drop ; \ CSN
\ Reading and writing to registers in the 24L01
: WMASK       ( b1 -- b2 )  1F and  20 or ;
: READ-REG      ( r -- b )  1F and spi-command  spi-in  spi} ;
: WRITE-REG     ( b r -- )  wmask spi-command  spi-out spi} ;
\ Write the communication addresses, of pipe-0 default: E7E7E7E7E7
: WRITE-ADDR  ( trxa -- )   wmask spi-command  5 for spi-out next  spi} ;
: SET-MY-ADDR   ( -- )      F0 F0 F0 F0 #me 0B write-addr ; \ Set ME own receive address


                ( nRF24L01+ control commands and setup )

\ Empty RX or TX data pipe
: FLUSH-RX      ( -- )      E2 spi-command spi} ;   \ Remove received data
: FLUSH-TX      ( -- )      E1 spi-command spi} ;   \ Remove transmitted data
: RESET         ( -- )      70 7 write-reg ;        \ Reset IRQ flags
: PIPES-ON      ( mask -- ) 3F and  2 write-reg ;   \ Set active pipes
: WAKEUP        ( -- )      0E 0 write-reg ;  \ CRC 2 bytes, Powerup
: >CHANNEL      ( +n -- )   5 write-reg ;     \ Change RF-channel 7-bits

value RF                \ Contains nRF24 RF setup
\ Bitrate conversion table: 0=250 kbit, 1=1 Mbit, 2=2 Mbit, 3=250 kBit.
    20 c, 00 c, 08 c,  20 c, align \ 250 kbit, 1 Mbit, 2 Mbit
: RF!   ( db bitrate -- )   b+b to rf ; \ Save RF-settings
: RF@   ( -- db bitrate )   rf b-b ;    \ Get RF-settings

\ db:  0 = -18db, 1 = -12db, 2 = -6db, 3 = 0db )
\ bitrate:  0 = 250 kbit, 1 = 1 Mbit, 2 = 2 Mbit
: >RF           ( db bitrate -- )       \ Change nRF24 RF settings
    3 and  [ ' rf >body cell+ ] literal \ Address of conversion table
    + c@ >r  3 and 2*  r> or  6 write-reg ;

3 1 rf!


\ Dynamic payload additions
20 constant #LEN            \ Payload size max. 32 bytes
value LEN                   \ Contains current length of the payload
value MLEN                  \ Remember length of received payload
: >LEN      ( +n -- )       1 max  #len umin  to len ; \ Set dynamic payload length
: NORM      ( -- )          3 >len ; \ Default payload length

\ Elementary command set for the nRF24L01+
                    
: SETUP24L01    ( -- )                               
    norm 3 1C write-reg \ Allow dynamic payload on Pipe 0 & 1
    3 1C write-reg      \ Allow dynamic payload on Pipe 0 & 1
    6 1D write-reg      \ Enable dynamic payload, ACK on!
    0C 0 write-reg      \ Enable CRC, 2 bytes
     3 1 write-reg      \ Auto Ack pipe 0 & 1
     2 pipes-on         \ Pipe 1 on
    set-my-addr         \ Set receive address
     3 3 write-reg      \ Five byte address
    1F 4 write-reg      \ Retry after 500 us & 15 retry's
    #ch >channel        \ channel #CH to start with
    rf@ >rf             \ 1 Mbps, max. power
    reset               \ Enable CRC, 2 bytes & reset flags
    flush-rx  flush-tx  \ Start empty
    wakeup  0F /ms      \ Power up
    led-off ;


v: inside definitions
\ Format: Admin, Dest. node, Org. node, Sub node, Command, Data-0, Data-1, Data-2, Data-3
create 'READ    #len allot  \ Receive buffer
create 'WRITE   #len allot  \ Transmit buffer

\ : WRITE-ACK ( +n -- )
\    7 and A8 or spi-command \ Store ACK payload for pipe +n
\    'write len for  count spi-out  next  drop  spi} ;

: WRITE-DTX? ( -- 0|20 )        \ Send #len bytes payload & leave 20 if an ACK was received
    A0 spi-command 'write len   \ Store (dynamic) payload for pipe-0
    for  count spi-out  next  drop  spi}
    ce-high  noop noop noop noop noop  ce-low     \ P2OUT  Transmit pulse on CE
    response? drop  7 read-reg 20 and ; \ Wait for ACK

: READ-DRX? ( -- f )                \ Receive 1 to 32 bytes
    60 spi-command  0 spi-i/o spi}  \ Read payload size
    dup 20 > if  flush-rx  drop false exit  then \ Check if invalid!
\   t? if  ch D emit dup .  then    \ Possible debug info
    to mlen  61 spi-command  'read mlen bounds
    ?do  0 spi-i/o i c!  loop   spi}  true ;

: '>PAY     ( +n -- a )     'write + ;  \ Leave address of TX payload
: >PAY      ( b +n -- )     '>pay c! ;  \ Store byte for TX payload
: 'PAY>     ( +n -- a )     'read + ;   \ Leave address of RX payload
: PAY>      ( +n -- b )     'pay> c@ ;  \ Read byte from RX payload


                    ( Send and receive commands for nRF24L01+ )

: WRITE-MODE    ( -- )          \ Power up module as transmitter
    ce-low  wakeup              \ Receive off, wakeup transmitter
    1 pipes-on  reset  2 /ms ;  \ Reset flags & pipe-0 active, wait 200 microsec.

: READ-MODE     ( -- )
    0F 0 write-reg  2 pipes-on  \ Power up module as receiver, activate pipe-1
    reset  ce-high  2 /ms ;     \ Enable receive mode, wait 200 microsec.

A constant #TRY                 \ Transmit attempts
8 constant #RETRY               \ Re-transmit attempts for XEMIT
: XEMIT?        ( c -- +n )     \ +n = #TRY when transmit has failed
    0 >pay  0  #try 0 do        \ Try it #TRY * ARC = dm 150 times max.
        write-dtx? if leave then \ Ready when it was an Ack!
        flush-tx  reset  1+     \ Reset flags & empty pipeline, count failures
        dup /ms  #ch >channel   \ Variable repeat time, clear packet loss
    loop
    flush-tx  reset ;

value #FAIL     \ Note XEMIT failures
: BUSY      ( -- )
    40 0 do                             \ Wait while a channel is busy
        read-mode  2 /ms  9 read-reg 0= \ Check for no carrier?
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
    #fail #retry = until            \ 150 * #RETRY = 1200 retries in total
    drop  read-mode ;

: XKEY          ( -- c )
    begin
        #retry 0 do                 \ Do eight receive attempts
            7 read-reg 40 and       \ Leave 40 when payload was received
        ack?  and 0= while          \ and IRQ noticed, not?
            setup24l01  read-mode   \ Then restart 24L01
            response? drop          \ Pickup retry
        loop
        ce-low  0  exit     \ Failed, leave zero & to standby II
        then
        unloop  read-drx?   \ Yes, read payload packet
    until  0 pay>           \ Now read command from packet
    reset  flush-rx         \ Empty pipeline
    ce-low ;                \ To standby II

\ Set destination address to node from stack, receive address is my "me"
: SET-DEST      ( node -- )
    dup >r  1 >pay  #me 2 >pay      \ Set Destination & origin nodes
    F0 F0 F0 F0 r@ 0A write-addr    \ Receive address P0
    F0 F0 F0 F0 r> 10 write-addr ;  \ Transmit address

v: fresh
shield 24L01\   freeze

\ End ;;;
