(*  This version Willem Ouwerkerk - April 2021 - bitbang SPI driver 
    With use of some of the data from Mecrisp, but much more
    the GD32VF103 user manual V1.2  
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
        
\ These bits are connected to flash memory on SEEED dev. board
PA5     = SCK     - 1       40010800
PA6     = MISO    - 8
PA7     = MOSI    - 1
PC0     = CE      - 1       40011000

*)

hex
v: fresh
: SPI-SETUP         ( +n -- )
    drop                    \ Remove compatability dummy
\ AF output mode push-pull 10MHz 
    FFF00000 40010800 **bic \ Port_A CRL  Clear pins PA5,6,7
    18100000 40010800 **bis \ Port_A CRL  Set pins PA5,6,7
    40 4001080C **bis       \ Port_A OCTL PA.6 Activate pull-up
\ Output mode push-pull 10MHz 
    000000FF 40011000 **bic \ Port_C CRL  Clear pin PC0 & PC1
    00000011 40011000 **bis \ Port_C CRL  Set pin PC0 & PC1
    1 4001100C **bis        \ Port_C out  CS high
    20 4001080C **bic ;     \ Port_A OCTL PA.5  CLK = 0

false [if]  \ Clock high level version = 300 kHz, low level version = 1 MHz

: CLOCK-HI     ( -- )      20 4001080C **bis ;      \ PA5_OCTL  SPI clock
: CLOCK-LOW    ( -- )      20 4001080C **bic ;      \ PA5_OCTL  SPI clock
: CLOCK        ( -- )      clock-hi  clock-low ;
: {SPI         ( -- )      1 4001100C **bic ;       \ PC0_OCTL  SPI on, CS=low
: SPI}         ( -- )      1 4001100C **bis ;       \ PCO_OCTL  SPI off, CS=high

\ Write a bit to the SPI-bus, read abit from the SPI-bus
: WRITE-BIT    ( b -- )
    80 and if 80 4001080C **bis else 80 4001080C **bic then ; \ PA7_OCTL

: READ-BIT     ( -- 0|1 )  40 40010808 bit** 0<> 1 and ; \ PA0_STAT

[else]

code CLOCK-HI     ( -- )
    sun 4001080C li     \ PORTA_ODR  Port-A output address
    day 20 li           \ Bit-5 mask
    w sun ) .mov        \ Read Port-A
    w day .or           \ Set bit-0
    sun ) w .mov        \ Write Port-A
    next
end-code

code CLOCK-LOW    ( -- )
    sun 4001080C li     \ PORTA_ODR  Port-A output address
    day -21 li          \ Bit-5 inverted mask
    w sun ) .mov        \ Read Port-A
    w day .and          \ Clear bit-5
    sun ) w .mov        \ Write Port-A
    next
end-code

code CLOCK      ( -- )
    sun 4001080C li     \ PORTA_ODR  Port-A output address
    day 20 li           \ Bit-5 mask
    w sun ) .mov        \ Read Port-A
    w day .or           \ Set bit-0
    sun ) w .mov        \ Write Port-A
    sun ) w .mov        \ Delay a few cycles
    day -21 li          \ Bit-5 inverted mask
    w sun ) .mov        \ Read Port-A
    w day .and          \ Clear bit-5
    sun ) w .mov        \ Write Port-A
    next
end-code

code  {SPI      ( -- )
    sun 4001100C li     \ PORTC_ODR  Port-C output address
    w sun ) .mov        \ Read Port-C
    w -2 .andi          \ Clear bit-0
    sun ) w .mov        \ Write Port-C
    next
end-code

code SPI}        ( -- )
    sun 4001100C li     \ PORTC_ODR  Port-C output address
    day 1 .li           \ Bit-0 mask
    w sun ) .mov        \ Read Port-C
    w day .or           \ Set bit-0
    sun ) w .mov        \ Write Port-C
    next
end-code

code WRITE-BIT  ( b -- )
    sun 40010800 li     \ Port_A base address
    moon C sun x) .mov  \ Read Port_A OCTL register
    day -81 li          \ Prepare inverted bit mask for bit-7
    moon day .and       \ Remove bit-7 from  MOON
    day 80 li           \ Prepare bit mask for bit-7
    tos day .and        \ Leave only bit-7 from TOS
    moon tos .or        \ Add bit-7 to MOON
    C sun x) moon .mov  \ Write MOON back
    tos sp )+ .mov      \ Pop stack
    next
end-code

code READ-BIT   ( -- 0|1 )
    sp -) tos .mov
    moon 40 li          \ Bit-6 mask to MOON
    sun 40010800 li     \ Port_A base address
    tos 8 sun x) .mov   \ Read Port_A STAT register
    tos moon .and       \ Leave bit-6 only
    tos 6 .srli         \ Bit-6 to bit-0
    next
end-code

[then]

: SPI-I/O       ( b0 -- b1 )
    8 for
        dup write-bit  2*  clock-hi
        read-bit or  clock-lo
    next  FF and ;

: SPI-OUT       ( b -- )
    8 for  dup write-bit  2*  clock  next  drop ;

: SPI-IN        ( -- b )
    0  8 for  2*  clock-hi  read-bit or  clock-lo  next ;

: SPI-ON        ( -- )      1 spi-setup ;

spi-on
v: fresh  
shield spi\  freeze

\ End ;;;
