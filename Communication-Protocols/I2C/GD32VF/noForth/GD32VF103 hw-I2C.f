(* GD32VF103 bitbang I2C driver

Values for CRL/CRH-Registers:
 0:  Analog Input
 1:  Output Push/Pull, 10 MHz
 2:  Output Push/Pull,  2 MHz
 3:  Output Push/Pull, 50 MHz
 4:  Floating Input (Reset state)
 5:  Open-Drain Output, 10 MHz
 6:  Open-Drain Output,  2 MHz
 7:  Open-Drain Output, 50 MHz
 8:  Input with pull-up / pull-down
 9:  Alternate Function, Push/Pull, 10 MHz
 A:  Alternate Function, Push/Pull,  2 MHz
 B:  Alternate Function, Push/Pull, 50 MHz
 C:  Reserved
 D:  Alternate Function, Open-Drain, 10 MHz
 E:  Alternate Function, Open-Drain,  2 MHz
 F:  Alternate Function, Open-Drain, 50 MHz

Look at page20ff of the GD32VF103 Datasheet for the optional pin functions

PB6 = SCL
PB7 = SDA

dm 260 is (52Mhz/(100Khz*2)). (And SCL rise-time no longer then 1000 ns)

100 = Start, 200 = Stop, 400 = Ack

  User words:  I2C-ON  {I2C-WRITE  {I2C-READ   I2C}
               BUS@  BUS!  DEVICE!  {DEVICE-OK?}
  Additional:  {I2C-OUT  {I2C-IN  {POLL}  BUS!}  BUS@}  BUS-MOVE  ||
 
  An example, first execute I2C-ON  After that the I2C is setup as
  a master. Sent byte 'b' to an I2C device with address 'a'.
    : >SLAVE    ( b a -- )  device!  1 {i2c-write  bus!  i2c} ;
    : >PCF8574  ( b -- )    20 >slave ;

*)

hex
\ : ABORT" ( flag ccc -- )         
\    postpone if  postpone ."  postpone abort  postpone then ; immediate

v: inside also definitions
40010C00 constant PB-CRL    \ Port-B control Register for pins 0 to 7
40010C08 constant PB-IDR    \ Port-B Input Data Register
40010C0C constant PB-ODR    \ Port-B Output Data Register

40021010 constant RCU-APB1RST   \ bit-21 = I2C-0 - 200000 = Reset device
40021018 constant RCU-APB2EN    \ bit-3  = I2C-0 - 000008 = Clock to device
4002101C constant RCU-APB1EN    \ bit-21 = I2C-0 - 200000 = Clock to device

40005400 constant I2C-CTL0      \ Control register 1
40005404 constant I2C-CTL1      \ Control register 2
40005410 constant I2C-DATA      \ Buffer register
40005414 constant I2C-STAT0     \ Status register 0
40005418 constant I2C-STAT1     \ Status register 1
4000541C constant I2C-CKCFG     \ Configure
40005420 constant I2C-RT        \ Rise time
40005490 constant I2C-FMPCFG    \ Fast mode config.

value DEV  value SUM
: i2c-stat0?    ( mask -- 0|mask )      i2c-stat0 bit* ;
v: extra definitions
: ||            ( -- )                  ; immediate  \ Dummy modifier...

: I2C-ON        ( -- )
    1 i2c-ctl0 *bic             \ Disable I2C
    EE44,4444 pb-crl !          \ Special Function tp PB6 & PB7, 10 MHz, open collector
    20,0000 rcu-apb1rst **bis   \ Restart I2C
    20,0000 rcu-apb1rst **bic   \ Restart I2C
    00,0008 rcu-apb2en **bis    \ Enable PB
    20,0000 rcu-apb1en **bis    \ Enable I2C APB1 clock
    dm 52 i2c-ctl1 h!           \ 52 MHz I2C clock
\   dm 260 i2c-ckcfg h!         \ I2C 100 kHz clock
    dm 130 i2c-ckcfg h!         \ I2C 200 kHz clock
\   dm  65 i2c-ckcfg h!         \ I2C 400 kHz clock
\   dm  32 i2c-ckcfg h!         \ I2C ~800 kHz clock, max ~900 kHz = 28
\     801A i2c-ckcfg h!         \ I2C 1 MHz clock fast mode (DOES NOT WORK!)
\        1 i2c-fmpcfg h!        \ Fast mode plus enable
    dm  25 i2c-rt h!            \ I2C rise time ~520ns
\   dm  15 i2c-rt h!            \ I2C rise time ~300ns (Fast Mode)
    401 i2c-ctl0 *bis ;         \ Enable I2C & ack

v: inside definitions
: >I2C-ADDR     ( +n dev -- )   \ Make start condition & send dev. address
    begin  2 i2c-stat1 bit* 0= until \ Bus free?
    100 i2c-ctl0 *bis           \ Start I2C
    begin  1 i2c-stat0? until   \ Done?
    i2c-data h!  to sum ;       \ Set dev. address & count

v: extra definitions
: {I2C-WRITE    ( +n --)
    dev >i2c-addr               \ Start cond. & dev. address
    begin  2 i2c-stat0? until   \ Done?
    2 i2c-stat1 *bic ;          \ Clear busy

\ The 1+ in the next line is not documented anywhere
: {I2C-READ     ( +n --)
    dev 1+ >i2c-addr            \ Start cond. & dev. address
    begin  2 i2c-stat0? until   \ Send?
    2 i2c-stat1 *bic            \ Clear busy
    400 i2c-ctl0 *bis ;         \ Activate ACK

: I2C}          ( -- )
    begin  200 i2c-ctl0 bit* 0= until ; \ Stop condition finished?

: BUS!          ( b -- )
    begin  80 i2c-stat0? until  \ Buffer free?
    -1 +to sum  i2c-data h!     \ Count bytes & store data
    sum 0= if 200 i2c-ctl0 *bis then ; \ Last byte add stop condition

: BUS@          ( -- b )
    -1 +to sum  sum 0= if       \ Last byte?
        400 i2c-ctl0 *bic       \ Yes, Nack
        200 i2c-ctl0 *bis       \ & stop condition
    then
    begin  40 i2c-stat0? until  \ Buffer filled?
    i2c-data h@ ;

: DEVICE!       ( dev -- )      2* FE and  to dev ;
: {DEVICE-OK?}  ( -- 0|2 )      \ Result is '2' when the address matched
    0 dev >i2c-addr             \ Send start & address
    200 i2c-ctl0 *bis           \ Activate stop condition 
    0  50 0 do                  \ Wait a while for address not matched bit!
        drop  2 i2c-stat0?      \ Read ADDSEND bit 
        dup if  leave  then     \ Ready when address match!
    loop
    2 i2c-stat1 *bic  i2c} ;    \ Clear busy


\ Additional routines like; acknowledge polling & optimised open & close
: {POLL}    ( -- )          begin  {device-ok?} until ; \ Wait until ACK received
: {I2C-OUT  ( dev +n -- )   swap  device!  {i2c-write ;
: {I2C-IN   ( dev +n -- )   swap  device!  {i2c-read ;
: BUS!}     ( b -- )        bus!  i2c} ;
: BUS@}     ( -- b )        bus@  i2c} ;
: BUS-MOVE  ( a u -- )      bounds ?do i c@ bus! loop ; \ Send string of bytes from 'a' with length 'u

v: fresh
shield HW-I2C\  freeze

\ End ;;;
