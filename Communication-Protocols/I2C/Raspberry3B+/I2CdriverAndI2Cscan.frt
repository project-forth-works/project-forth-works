1 : setbits 0 do dup constant 1 lshift loop ;
8 setbits  bit0  bit1  bit2  bit3  bit4  bit5  bit6  bit7
8 setbits  bit8  bit9 bit10 bit11 bit12 bit13 bit14 bit15
8 setbits bit16 bit17 bit18 bit19 bit20 bit21 bit22 bit23
8 setbits bit24 bit25 bit26 bit27 bit28 bit29 bit30 bit31
drop

hex
3F804000 constant bsc1_c                \ control register BCM serial controller 1
3F804004 constant bsc1_s                \ status register
3F804008 constant bsc1_dlen             \ data length
3F80400C constant bsc1_a                \ address of slave
3F804010 constant bsc1_fifo             \ 16 byte deep - read and write data per byte from this address
3F804014 constant bsc1_div              \ divider: 4000 voor 100kHz with a core freq of 400Mhz
3F804018 constant bsc1_del              \ data-delay
3F80401C constant bsc1_clkt             \ clock-stretch timeout - 0 disables timeout -> hang when no ACK!
decimal

: .hex base @ >r hex . r> base ! ;
: formalflags if true else false then ;

: i2c_clear_all
    bit5 bsc1_c !
    bit1 bit8 or bit9 or bsc1_s ! ;

: i2c_init
    4 2 setfuncgpio                     \ wabiForth internal word - sets function of GPIO=pin
    4 3 setfuncgpio                     \ ditto
    i2c_clear_all
    1160 bsc1_div ! ;                   \ ( div factor is 1160 to get to 400 kHz... )

: i2c_stop
    bsc1_c @ bit15 invert and bsc1_c ! ;

: i2c_address ( slave address -- )
    dup 8 120 within if bsc1_a ! else drop then ;

: i2c_fifowrite ( byte -- )
    255 and bsc1_fifo ! ;

: i2c_fiforead ( -- data )
    bsc1_fifo @ ;

: i2c_start ( -- ) ( start transfer )
    bit7 bsc1_c ! ;

: i2c_setdlen ( length data for transfer -- )
    [hex] FFFF [decimal] and bsc1_dlen ! ;

: i2c_getdlen ( -- number bytes left to handle )
    bsc1_dlen @ ;

: i2c_done ( -- true if done )
    bsc1_s @ bit1 and formalflags ;

: i2c_fifospace? ( -- true=>space for >= 1 byte )
    bsc1_s @ bit4 and formalflags ;

: i2c_fifodata? ( -- true -> fifo contains >= 1 byte )
    bsc1_s @ bit5 and formalflags ;

: i2c_err ( -- flag -> NACK received )
    bsc1_s @ bit8 and formalflags ;

: i2c_active ( -- true if active )
    bsc1_s @ bit0 and formalflags ;

: i2c_gets ( -- content of status reg )
    bsc1_s @ 1023 and ;

: i2c_waitdone ( -- )                   \ no time_out!
    begin i2c_done until bit1 bsc1_s ! ;

: i2c_startread
    bit15 bit7 or bit0 or bsc1_c ! ;

: i2c_startwrite
    bit15 bit7 or bsc1_c ! ;

: wbyte ( byte -- )
	i2c_clear_all
	1 i2c_setdlen
	i2c_fifowrite
	i2c_startwrite i2c_waitdone
	( bit1 bsc1_s ! ) ( reset done bit ) ;

: w2byte ( byte1 byte2 -- )
	i2c_clear_all
	2 i2c_setdlen swap
	i2c_fifowrite i2c_fifowrite
	i2c_startwrite i2c_waitdone
	( bit1 bsc1_s ! ) ;

: readbyte ( -- byte )
	i2c_clear_all
	1 i2c_setdlen
	i2c_startread
	i2c_waitdone
	i2c_fiforead
	( bit1 bsc1_s ! ) ( reset done bit ) ;

: read16bit ( -- 16b ) i2c_clear_all 2 i2c_setdlen
	i2c_startread i2c_waitdone i2c_fiforead
	256 * i2c_fiforead +
	( bit1 bsc1_s ! ) ;

\ implementation of I2C-scan

: i2c_exist? ( address -- flag )
    i2c_init i2c_clear_all
    bsc1_a !
    0 i2c_setdlen
    i2c_startwrite
    i2c_waitdone
    i2c_err if false else true then
    bit1 bsc1_s ! ( reset 'done' bit ) ;

: i2cheader
    cr 10 spaces 16 0 do i ." 0x" .hex loop ;
: kl2 ( i -- )
    cr 6 spaces ." 0x" .hex ;
: docheck ( addr -- )
    dup i2c_exist? if ." x" .hex else drop ." --- " then ;
: 1stline
    0 kl2 ." g/s cba res res hsm hsm hsm hsm "
    16 8 do i docheck loop ;
: lstline
    7 kl2 8 0 do i 128 + docheck loop
    ." 10b 10b 10b 10b fut fut fut fut" ;
: i2cscan
    i2cheader
    1stline
    7 1 do i kl2
        16 0 do
            j 16 * i + docheck
        loop
    loop
    lstline ;

\ call i2cscan to print this on screen:
\
\          0x0 0x1 0x2 0x3 0x4 0x5 0x6 0x7 0x8 0x9 0xA 0xB 0xC 0xD 0xE 0xF
\      0x0 g/s cba res res hsm hsm hsm hsm --- --- --- --- --- --- --- ---
\      0x1 --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
\      0x2 --- --- --- --- --- --- --- x27 --- --- --- --- --- --- --- ---
\      0x3 --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
\      0x4 --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
\      0x5 x50 x51 x52 x53 x54 x55 --- --- --- --- --- --- --- --- --- ---
\      0x6 x60 --- --- --- --- --- --- --- --- --- --- --- --- --- --- x6F
\      0x7 --- --- --- --- --- --- --- --- 10b 10b 10b 10b fut fut fut fut
