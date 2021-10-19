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

PB6 = SCL
PB7 = SDA

*)

hex
: ABORT" ( flag ccc -- )         
    postpone if  postpone ."  postpone abort  postpone then ; immediate

40010C00 constant PB-CRL    \ Port-B control Register for pins 0 to 7
40010C08 constant PB-IDR    \ Port-B Input Data Register
40010C0C constant PB-ODR    \ Port-B Output Data Register

40 constant SCL             \ I2C clock line 
80 constant SDA             \ I2C data line
SCL SDA or constant BUS     \ I2C bus lines

: I2C-SETUP     ( -- )
    6644,4444 pb-crl !  \ Set PB5 & PB6 as I2C output (Reset $44444444)
    bus pb-odr *bis ;   \ I2C floating at startup

: WAIT          ( -- )      12 for next ; ( About 100 KHz with 104 MHz clock )

: I2START       ( -- )
    scl pb-odr *bis  wait
    sda pb-odr *bic  wait ;

: I2STOP}       ( -- )
    scl pb-odr *bic  sda pb-odr *bic  wait
    scl pb-odr *bis  wait
    sda pb-odr *bis ;
 
: I2ACK         ( -- )
    scl pb-odr *bic  sda pb-odr *bic  wait
    scl pb-odr *bis  wait
    scl pb-odr *bic ;

: I2NACK        ( -- )
    scl pb-odr *bic  sda pb-odr *bis  wait
    scl pb-odr *bis  wait
    scl pb-odr *bic ;

: I2ACK?        ( -- f )
    scl pb-odr *bic  sda pb-odr *bis  wait
    scl pb-odr *bis  wait
    sda pb-idr bit* 0=
    scl pb-odr *bic ;

: (I2OUT        ( b -- )
    8 for
        scl pb-odr *bic 
        dup 80 and if   sda pb-odr *bis
        else            sda pb-odr *bic
        then            wait  2*
        scl pb-odr *bis  wait
    next  drop ;

: (I2IN         ( -- b )
    0  8 for
        2*  scl pb-odr *bic  sda pb-odr *bis  wait
        sda pb-idr bit*  0<> 1 and  or
        scl pb-odr *bis wait
    next ;

: I2OUT         ( b -- )        (i2out i2ack? drop ;
: I2IN          ( -- b )        (i2in  i2ack ;
: I2OUT}        ( b -- )        i2out  i2stop} ;
: I2IN}         ( -- b )        (i2in  i2nack  i2stop} ;

variable DEV
: >DEV          ( ia -- )       FE and  dev ! ;

: {I2WRITE)     ( -- )      \ Start I2C write with device in DEV
    i2start  dev @ (i2out ; \ Used for repeated start
  
: {I2READ)      ( -- )      \ Start read to device in DEV
    i2start  dev @ 1+ (i2out \ Used for repeated start
    i2ack? 0= abort" Ack error " ; 

: {I2WRITE      ( b ia -- )
    >dev  {i2write)  i2ack? 0= abort" Ack error "
    (i2out i2ack? 0= abort" Ack error " ;

: {I2READ       ( ia -- )       >dev  {i2read) ;

: {I2ACK?}      ( -- f )           \ Flag 'fl' is true when an ACK is received
    {i2write)  i2ack?  i2stop} ;

\ This routine may be used when writing to EEPROM memory devices.
\ The waiting for the write to succeed is named acknowledge polling.
: {POLL}        ( -- )          begin  {i2ack?} until ; \ Wait until ACK received

\ Prints -1 if device with address 'a' is present on I2C-bus otherwise 0.
: I2C?          ( ia -- )
    i2c-setup  >dev  {i2ack?} . ;
 
shield BB-I2C\  freeze

\ End ;;;
