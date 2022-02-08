(*  This version Willem Ouwerkerk - March 2021 - SPI0 driver 
    With use of the data from Mecrisp. 
    Please note that 27 MHz is the maximum SPI clock frequency!

        40010800 =  PORTA
        40010C00 =  PORTB
        40011000 =  PORTC
        40011400 =  PORTD
        40011800 =  PORTE

        40021000 =  RCU_CTL
        40021018 =  RCU_APB2EN

        40013000 =  SPI0_CTL0
        40013008 =  SPI0_STAT
        4001300C =  SPI0_DATA

RCU_APB2EN = Clock enable register

  |5432|1098|7654|3210
  |x0x0|000x|x000|00x0  reset=0, x=reserved
  | +  |    |    |      USART0EN
  |   +|    |    |      SPI0EN
  |    |+   |    |      TIMER0EN
  |    | +  |    |      ADC1EN
  |    |  + |    |      ADC0EN
  |    |    | +  |      PEEN
  |    |    |  + |      PDEN
  |    |    |   +|      PCEN
  |    |    |    |+     PBEN
  |    |    |    | +    PAEN
  |    |    |    |   +  AFEN

SPI_CTL0 = SPI Control Register 0
  |5432|1098|7654|3210
  |0000|0000|x000|0000  reset=0, x=reserved
  |+   |    |    |      BDEN    Bidirectional enable
  | +  |    |    |      BDOEN   Bidirectional transmit output enable
  |  + |    |    |      CRCEN   CRC enable
  |   +|    |    |      CRCNT   Next transfer is CRC
  |    |+   |    |      FF16    Data format 8/16
  |    | +  |    |      RO      Receive only
  |    |  + |    |      SWNSSEN NSS enable
  |    |   +|    |      SWNSS   NSS pin plarity
  |    |    |+   |      LF      LSB/MSB first selection
  |    |    | +  |      SPIEN   SPI enable
  |    |    |  + |      PSC2    Clock prescaler
  |    |    |   +|      PSC1    "
  |    |    |    |+     PSC0    "
  |    |    |    | +    MSTMOD  Master mode enable
  |    |    |    |  +   CKPL    Clock polarity
  |    |    |    |   +  CKPH    Clock phase

\ SPI0, connected to flash memory on SEEED dev. board
PA5     = SCK     - B       40010800
PA6     = MISO    - B
PA7     = MOSI    - B
PC0     = CE      - 3       40011000

1. Enable the SPI (set the SPIEN bit).
2. Program data format (FF16 bit in the SPI_CTL0 register).
3. Program the clock timing register (CKPL and CKPH bits in the SPI_CTL0 register).
4. Program the frame format (LF bit in the SPI_CTL0 register).
5. Program the NSS mode (SWNSSEN and NSSDRV bits in the SPI_CTL0 register)
   according to the application’s demand as described above in NSS function section.
7. Configure MSTMOD, RO, BDEN and BDOEN depending on the operating modes
   described in SPI operating modes section.

Transmission sequence:

After the initialization sequence, the SPI is enabled and stays at idle state. 
In master mode, the transmission starts when the application writes a data into 
the transmit buffer. 

When SPI begins to send a data frame, it first loads this data frame from the 
data buffer to the shift register and then begins to transmit the loaded data 
frame, TBE (transmit buffer empty) flag is set after the first bit of this 
frame is transmitted. After TBE flag is set, which means the transmit buffer 
is empty, the application should write SPI_DATA register again if it
has more data to transmit.

In master mode, software should write the next data into SPI_DATA register before the
transmission of current data frame is completed if it desires to generate continuous
transmission.

Reception sequence:
After the last valid sample clock, the incoming data will be moved from shift 
register to the receive buffer and RBNE (receive buffer not empty) will be set. 
The application should read SPI_DATA register to get the received data and this 
will clear the RBNE flag automatically.

!While in full-duplex master mode (MFD), hardware only receives 
the next data frame when the transmit buffer is not empty!

MFD SFD:
Wait for the last RBNE flag and then receive the last data. Confirm that TBE=1 
and TRANS=0. At last, disable the SPI by clearing SPIEN bit.

*)

hex
v: fresh
code {SPI       ( -- )  \ Open an SPI data stream 
    sun 40011000 li     \ PORTC_ODR  Port-C output address
    w C sun X) .mov     \ Read Port-C
    w -2 .andi          \ Clear bit-0
    C sun X) w .mov     \ Write Port-C
    next
end-code

code SPI}       ( -- )  \ Close an SPI data stream
    moon 40013000 li    \ SPI_STAT   SPI status register
    begin,              \ Wait for transmit buffer empty!
        w 8 moon x) .mov \ Read SPI0 status
        w 2 .andi       \ Transmit buffer bit only
    w .0<>? until,      \ Buffer empty?
    sun 80 li           \ Yes. det TRANS bit ready
    begin,              \ W& wait for ongoing transfers to end!
        w 8 moon x) .mov \ Read SPI0 status
        w sun .and      \ TRANS buffer bit only
    w .0=? until,       \ Transmission finished?
    sun 40011000 li     \ PORTC_ODR  Yes, Port-C output address
    day 1 .li           \ Bit-0 mask
    w C sun x) .mov     \ Read Port-C
    w day .or           \ Set bit-0
    C sun x) w .mov     \ Write Port-C
    next
end-code

\ Initialise SPI0 with SPI-clock, when +n is 5 = 104/64 1.625 MHz
\ Note that the maximum clock frequency is 10 MHz with these port settings!
\ 0 = pclk/2,    1 = pclk/4    2 = pclk/8    3 = pclk/16
\ 4 = pclk/32,   5 = pclk/64,  6 = pclk/128, 7 = pclk/256
: SPI-SETUP     ( +n -- )
\ Output mode push-pull 10MHz
    000000FF 40011000 **bic \ Port_C CRL  Clear pin PC0
    00000011 40011000 **bis \ Port_C CRL  Set pin PC0
    1 4001100C **bis        \ Port_C out  CS high 
    40 40013000 **bic       \ Deactivate SPI0 hardware
    1001 40021018 **bis     \ RCU_APB2EN  Enable alt function & SPI-0
\ AF output mode push-pull 10MHz 
    FFF00000 40010800 **bic \ Port_A CRL  Clear pins PA5,6,7
    99900000 40010800 **bis \ Port_A CRL  Set pins PA5,6,7
    7 and  3 lshift         \ Build SPI clock divider
    304 or 40013000 !       \ SPI_CTL0    Master, CLK/+n, SPI on MSB first, CLK low, NSS=1
    40 40013000 **bis  spi} ;

code SPI-I/O    ( b0 -- b1 )
    moon 40013000 li    \ SPI_STAT   Status address
    begin,
        w 8 moon x) .mov \ Read SPI0 status
        w 2 .andi       \ Transmit buffer bit only
    w .0<>? until,      \ Buffer empty?
    C moon x) tos .mov  \ SPI_DATA   Yes, store b0 in data register
    begin,
        w 8 moon x) .mov \ Read SPI0 status
        w 1 .andi       \ Receive buffer bit only
    w .0<>? until,      \ Buffer full?
    tos C moon x) .mov  \ SPI_DATA   Yes, Read b1 from data register
    next
end-code

code SPI-IN      ( -- b ) \ Read from FSPI-bus
    sp -) tos .mov      \ TOS MOON DAY W
    moon 40013000 li    \ SPI_STAT   Status address
    day -1 .li
    begin,
        w 8 moon x) .mov \ Read SPI0 status
        w 2 .andi       \ Transmit buffer bit only
    w .0<>? until,      \ Buffer empty?
    C moon x) day .mov  \ Dummy write
    begin,
        w 8 moon x) .mov \ Read SPI0 status
        w 1 .andi       \ Receive buffer bit only
    w .0<>? until,      \ Buffer full?
    tos C moon x) .mov  \ SPI_DATA   Yes, Read b1 from data register
    next
end-code

code  SPI-OUT   ( b -- )
    moon 40013000 li    \ SPI_STAT   Status address
    begin,              \ MOON W TOS
        w 8 moon x) .mov \ Read SPI0 status
        w 2 .andi       \ Transmit buffer bit only
    w .0<>? until,      \ Buffer empty?
    C moon x) tos .mov  \ SPI_DATA   Yes, store b0 in data register
    begin,
        w 8 moon x) .mov \ Read SPI0 status
        w 1 .andi       \ Receive buffer bit only
    w .0<>? until,      \ Buffer full?
    tos C moon x) .mov  \ SPI_DATA   Yes, Dummy read b1 from data register
    tos sp )+ .mov
    next
end-code

: SPI-ON        ( b -- )        4 spi-setup ;

4 spi-on    \ Activate SPI0 with 3.25MHz clock
shield SPI\  freeze

\ End ;;;
