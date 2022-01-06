\ 20x4 character LCDs are often sold with a piggy-backed I2C interface.
\ In practise most of these LCD are the same: based on a clone of a Hitachi-chip
\ and almost all have the same features. Even when the spec says that there are
\ no configurable characters, usually these are available anyhow.

\ 33 definitions, 3836 bytes

\ There are a couple of things you need to be aware of:
\ 1. characters, data and commands are send as 2 4bit blocks. (see LCDemit as example)
\ 2. The screen addresses are a bit unlogical (see LCDxy as example). Line 0 starts at 0,
\    line 1 starts at 64, line 2 at 20 and line 3 at 84.
\ 3. the backlite is controlled by a specific i/o-line which needs to be set/cleared at every command
\ 4. the LCD display has a cursor which can be set/cleared
\ 5. there usually are 64 bytes of RAM available and these are usually used for 8 configurable
\ 	 characters. Defining a character is done with word LCDdefCHAR
\ 6. The Raspberry has 3.3v on its GPIOs. If your LCD display needs 5v, than a level converter is
\	 needed. Do not put 5v on the GPIOs!!

\ wabiForth specific words:
\ WAITMCS ( n -- )  waits n microseconds
\ SLITERAL: non-ANSI implementation - puts addr en len of a string in a double constant
\ CPUTEMP, CPUFREQ and WORD# are system specific words - you can use your own words and
\ literals for testing

\ : CLIP ( n l u ) rot min max ; \ limits n to within l and u, both inclusive

\ NOTE: first load the I2C driver, than this part


39 constant lcdi2caddr

8 constant bckltpin
4 constant lcdenpin
2 constant lcdrwpin
1 constant lcdregpin

variable backlite  bckltpin backlite !

: bckltor backlite @ or ;
: lcdbkloff 0        backlite ! ;
: lcdbklon  bckltpin backlite ! ;

: lcdlowait 4000 waitmcs ;
: lcdshwait 60 waitmcs ;

: lcd! ( n -- ) lcdi2caddr i2c_address
	15 and
	4 lshift bckltor dup
	lcdenpin or swap w2byte
	0 bckltor wbyte ;

: lcd!data ( n -- ) lcdi2caddr i2c_address
	15 and
	4 lshift lcdregpin or bckltor
	dup lcdenpin or swap w2byte ;

: LcdEmit ( char -- )
	255 and dup
	4 rshift 15 and lcd!data
	         15 and lcd!data ;

: lcdclear 0 lcd! 1 lcd! lcdlowait ;
: lcdsleep lcdbkloff 0 lcd! 8 lcd! lcdshwait ; \ switch LCD off
: LcdOnNoCur lcdbklon 0 lcd! 12 lcd! lcdshwait ;
: LcdOnCur lcdbklon 0 lcd! 15 lcd! lcdshwait ;

: LcdEntryOn 0 lcd! 6 lcd! lcdshwait ;
: LcdSetMode 2 lcd! 8 lcd! lcdshwait ;  \ only at initiation


: LcdType ( addr len -- ) 1 20 clip 0 do dup i + c@ lcdemit loop drop ;

: LcdRamAddr ( pos -- ) 0 63 clip dup 4 rshift 7 and
	4 or lcd! 15 and lcd! ;
: LcdDefChar ( n, n, n, n, n, n, n, n, char# -- )
	0 7 clip 8 * lcdramaddr 8 0 do 0 31 clip lcdemit loop ;

: LcdScrAddr ( pos -- ) 0 127 clip dup 4 rshift 15 and
	8 or lcd! 15 and lcd! ;
: LcdXy ( x y -- )
	0 3 clip
	dup 1 = if drop 64 then
	dup 2 = if drop 20 then
	dup 3 = if drop 84 then
	swap
	0 19 clip + lcdscraddr ;

: LcdHome 0 lcd! 2 lcd! lcdlowait ;

: n>string ( n -- addr len ) s>d <# #s #> ;

: defdegree 0 0 0 0 0 7 5 7  7 lcddefchar ; \ LCD has no degree character -> define
: .Lcddegree 7 lcdemit ;

: .Lcdr dup 4 < if 32 lcdemit then dup 3 < if 32 lcdemit then lcdtype ; \ ugly!!
: .LcdMhz ( freq -- ) 1000000 / n>string .lcdr ;
: .LcdWords ( word# -- ) n>string .lcdr 32 lcdemit 32 lcdemit 32 lcdemit ;


\ ************  EXAMPLE  ****************
\ *********  very wabiForth  ************
\ ************  specific  ***************

  s" Project Forth Works " sliteral r1
  s" cpu:      Mhz      C" sliteral r2
  s" def:                " sliteral r3
  s" ram:           free " sliteral r4

: LcdScreen
	lcdclear
	 0 lcdscraddr r1 lcdtype
	64 lcdscraddr r2 lcdtype
	20 lcdscraddr r3 lcdtype
	84 lcdscraddr r4 lcdtype
	82 lcdscraddr .lcddegree ;

: LcdUpdateFreq 69 lcdscraddr cpufreq .lcdmhz ;
: LcdUpdateTemp	79 lcdscraddr cputemp n>string lcdtype ;
: LcdUpdateDict 25 lcdscraddr word#   .lcdwords ;
: LcdUpdateMem  89 lcdscraddr unused  n>string lcdtype ;

: LcdUpdate lcdupdatefreq lcdupdatedict lcdupdatemem lcdupdatetemp ;

: LcdInit ( -- )
	i2c_init
	3 lcd! lcdlowait
	3 lcd! lcdshwait lcdshwait
	3 lcd! lcdshwait lcdshwait
	2 lcd! lcdshwait lcdshwait
	lcdsetmode
	lcdsleep
	lcdonnocur
	lcdentryon
	lcdclear ;

lcdi2caddr i2c_address
lcdinit
defdegree
lcdscreen
lcdupdate


