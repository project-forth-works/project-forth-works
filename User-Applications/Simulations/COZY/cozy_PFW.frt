\ simulation COZY - wabiForth 3.3.0 - (C) 2022 J.J. Hoekstra

\ In a toroidal grid of 256 by 192 cells, 5 different groups of agents
\ are spread at random.
\ The update loop is as follows::
\ a random agent will swap the location with a second random agent if the
\ location of the second agent is better for the first agent.
\ Better being defined as having more direct neighbours belonging to the same group
\ Thus the name COZY; feeling more at home in an environment of the same agents

\ The interesting aspect of this simulation is that after a (long) while the agents
\ group into clusters, which exterior follows the rules of soap-bubbles.
\ This takes a lot of cycles though, around 75 billion. With the present speed of
\ 0.5 milion loops per second, this takes well over a day. Fortunately a Raspberry Pi
\ does not consume a lot of energy.

\ If you convert this program to your own computer you need to provide the
\ machine-specific grafics routines yourself: DRAWBOX ( see below )
\ and a way to set a color

\ : drawbox ( x y lenx leny win# -- )
\	swap 1 max 0 do 4dup rot i + -rot horline loop 4drop ;

\ If your computer has a fast random generator with good quality, use that.
\ The program generates around a milion random numbers/sec on a Raspberry Pi 3B+

: CLIP ( n min max ) -rot max min ; 		\ n is limited to the given limits (inclusive)

2345 value SEED0
6789 value SEED1

: RNDM ( n -- u )                           \ u = random number between 0 and n-1
  >r
  seed0                                     \ put seed0 on stack
  seed1 to seed0                            \ move value in seed1 to seed0
  dup 13 lshift xor                         \ do three XORs of seed0
  dup 17 rshift xor                         \ with shifted copies of itself
  dup 5 lshift xor
  dup seed1 xor to seed1                    \ XOR the new random value with
                                            \ the old seed1 and update seed1
  r> um* nip ;                              \ limit the number to between 0 and n-1

192 constant ygrid
256 constant xgrid
xgrid ygrid * cells allocate drop constant grid

: fromgrid ( x y -- value )
	xgrid * 4* swap ( y*xgrid*4 x )
	4* + grid + @ ;

: togrid ( value x y -- )
	0 ygrid 1- clip xgrid * 4* swap ( value y*xgrid*4 x )
	0 xgrid 1- clip 4* + grid + ! ;

: getrndcolor 12 rndm
	dup 0 = if drop green else
		dup 1 = if drop black else
			dup 2 = if drop lblue else
				dup 3 = if drop white else
	    			3 > if dgray then then then then then ;

: drawagent ( x-scr y-scr color -- ) 		\ this draws a 4x4 pixel box in a given color
	0 wingetink								\ remember winink
	swap 0 >winink							\ set color to draw box with
	-rot
	0 ygrid 1- clip 4* swap
	0 xgrid 1- clip 4* swap
	4 4 0 drawbox
	0 >winink ;								\ restore previous winink

: showagent ( x-grid y-grid -- ) 2dup fromgrid drawagent ;

: fillgrid xgrid 0 do ygrid 0 do getrndcolor j i togrid loop loop ;
: showgrid xgrid 0 do ygrid 0 do j i 2dup fromgrid drawagent loop loop ;

: toroidy ( y -- corrected y ) ygrid + ygrid mod ; \ 18c - 5c as inlined codeword
: toroidx ( x -- corrected x ) xgrid + xgrid mod ; \ ditto

variable cozycol
: cozy ( color x y -- value ) ( # of cols eq. to color in 9 cell env of x y )
	rot cozycol ! ( x y ~ color in cozycol )
	0 -rot ( 0 x y )
	2 -1 do 2 -1 do ( 2 -1 ) (
		2dup ( 0 x y x y )
		i + toroidy swap
		j + toroidx swap
		fromgrid ( 0 x y color )
		cozycol @ = ( 0 x y flag )
		if rot 1+ -rot then ( 0+flag x y )
	loop loop 2drop ;

variable xgridoud
variable ygridoud
variable xgridnew
variable ygridnew

2variable dtotal

: cozyrule ( x y -- xnew ynew ) ( rule: x=x+-1, y=y+-1 )
	2drop xgrid rndm ygrid rndm ;

variable swapcolorn
: swapblocks ( xo yo xn yn -- )
	2dup fromgrid swapcolorn ! ( xo yo xn yn )
	2over fromgrid ( xo yo xn yn coloro )
	-rot togrid ( xo yo )
	swapcolorn @ -rot togrid ;

: fillcozycorvars ( x y -- )
	2dup ( x y x y )
	ygridoud ! xgridoud ! ( x y )
	cozyrule ( xn yn )
	ygridnew ! xgridnew ! ( -- ) ;

: getoldcozycors ( -- xo yo ) xgridoud @ ygridoud @ ;
: getnewcozycors ( -- xn yn ) xgridnew @ ygridnew @ ;

: docozyswap
	getoldcozycors getnewcozycors swapblocks
	getoldcozycors showagent
	getnewcozycors showagent ;

: docozyswapif
	getoldcozycors fromgrid getoldcozycors cozy 1- ( 1- to avoid counting oneself )
	getoldcozycors fromgrid getnewcozycors cozy
	< if docozyswap then ;

: docozy ( x y -- )
	fillcozycorvars ( -- )
	getoldcozycors fromgrid
	getnewcozycors fromgrid
	<> if docozyswapif then ;

: initcozy fillgrid showgrid ;	( pi3: 36ms pi4: 35ms )
: 100000loops 100000 0 do xgrid rndm ygrid rndm docozy loop ;

: go
	5000 ms
	initcozy
	anykey -1 0 do					\ semi-endless loop
		key? if
			key drop
			cr i . ." * 100000 loops" leave
		then
		100000loops
	loop ;

