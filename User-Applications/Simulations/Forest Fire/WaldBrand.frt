\ Waldbrand v2.3
\ 11feb2021: simulation of a forest-fire - wabiForth 3.2.8 and later

\ This program simulates a forest-fire. The idea comes from B. Drossel
\ and F. Schwabl, Self-organized critical forest-fire model,
\ Physical Review Letters, Vol. 69, No. 11, September 1992, pp. 16291632.

\ The principle is this: The simulation uses a 512 by 384 field. Every loop a
\ random cell is selected and checked if it is empty (=0) or not. If empty, there is a
\ small change that a tree starts growing. If the cell is not empty, the action depends
\ on whether it is a tree or a fire. A tree has a very small change of getting hit
\ by lightning and otherwise the age of the tree is upped by one (upto 255)
\ if the cell is on fire, the age of the fire is lower by 1 till zero.
\ after the action the screen is updated for the cell.

\ a counter of the number of loops is available in the lower left corner.

: toroid ( n l )							\ high level version
    2dup >= if - else
        over 0 < if + else
            drop then
    then ;

: defwin \ defines a floating translucent window for displaying the counter
	    200 100 2 makewin
	translucent 2 >wincanvas				\ window 2 is tranlucent
				2 wincls
		 50 700 2 >winorig
	      white 2 >winink
	       true 2 winvisible

	       true 0 uart>task#				\ no printing on the UART
	          2 0 win#>task# ;				\ print @ window 2

create mycolortable 32 cells allot
mycolortable constant colortable ( to speed things up a very little bit... )

2variable dtotal
32 value #colors

	 black   black vdyellow  orange yellow    red  green  green
	 green   green   dgreen  dgreen dgreen dgreen dgreen dgreen
	dgreen  dgreen   dgreen  dgreen dgreen dgreen dgreen dgreen
	dgreen  dgreen   dgreen  dgreen dgreen dgreen dgreen dgreen

colortable #colors loadarray

    512 value maxxscr
    384 value maxyscr
      0 value x
      0 value y
     47 value lghttrh
     lghttrh 1+ value newtree
     47 value ignite

maxxscr maxyscr * value scrnsize

1000000 value lightning					\ chance of lightning 1:1000000
    500 value newtree#					\ chance of a new tree 1:500 for an empty cell

create (field) scrnsize allot
(field) constant myfld					\ to save a few cycles each loop

: rndflag ( n -- t/f ) rndm 3 = if true else false then ;
: clearfld scrnsize 0 do 0 myfld i + c! loop ;
: scraddr ( x y -- addr ) swap maxyscr * + myfld + ; ( 35.6c )

: (onfire?) ( -- f/t ) scraddr c@ ignite = ;
\ : (onfire?) ( -- f/t ) scraddr c@ 12 ignite within ;

: check8n ( -- t/f )
	x 1- maxxscr toroid  y 						(onfire?) if true exit then
	x 1- maxxscr toroid  y 1- maxyscr toroid	(onfire?) if true exit then
	x 1- maxxscr toroid  y 1+ maxyscr toroid	(onfire?) if true exit then
	x    				 y 1- maxyscr toroid	(onfire?) if true exit then
	x    				 y 1+ maxyscr toroid	(onfire?) if true exit then
	x 1+ maxxscr toroid	 y						(onfire?) if true exit then
	x 1+ maxxscr toroid	 y 1- maxyscr toroid	(onfire?) if true exit then
	x 1+ maxxscr toroid	 y 1+ maxyscr toroid 	(onfire?) if true exit then
	false ;

: newcell
	maxxscr rndm to x					\ select a rndm cell
	maxyscr rndm to y ;

: updatescr ( -- )
	x y scraddr c@
	3 rshift							\ div by 8
	4* colortable + @					\ 4* plus colortable
	0 >winink							\ implementation specific
	x y draw2x2 ;						\ implementation specific

: tree! ( cell -- )
	check8n if							\ kijk of een vd buren brand
		drop
		lghttrh x y scraddr c!			\ if yes: start burning
	else
		1+ 255 min x y scraddr c!		\ if no: age 1+
	then ;

: emptycell ( cell -- )
	newtree# rndflag if					\ check if new tree to be started
		newtree x y scraddr c!
	then ;

: docell
	x y scraddr c@
	dup
	newtree >= if tree! exit then		\ tree
	dup
	0 = if drop emptycell exit then		\ empty cell

	1- 0 max x y scraddr c!	;			\ else brand -> age -1 (till 0)

: dolightning
	x y scraddr c@						\ get value from cell
	lghttrh > if						\ is it a tree? yes -> set it on fire
		lghttrh x y scraddr c! then ;

: 1loop
	newcell
	lightning rndflag if				\ lightning-strike?
		dolightning						\ yes: make fire
	else								\ no: update cell
		docell
	then

	updatescr ;

: 10000loop 10000 0 do 1loop loop ;

: go
	defwin								\ define floating window
	d% 0 dtotal 2!						\ reset total
	clearfld
	black 0 >wincanvas cls

	-1 0 do								\ semi-endless loop
		key? if
			key drop
			leave
		else
			10000loop
			d% 10000 dtotal 2@ d+ dtotal 2! \ print counter
			home dtotal 2@ d.
		then
	loop

	0 0 win#>task#						\ restore printing on win0
 	false 0 uart>task#					\ restore printing @ UART

	vdcyan 0 >wincanvas
	 white 0 >winink ;


