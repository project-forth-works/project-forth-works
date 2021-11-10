# The PiliPlop algorithm

## The idea

When you have multiple processes that need to start at one point. Finishes at another point, 
in the same time frame, you need something like PiliPlop. It uses a Bresenham like algorithm. 
Original idea [Albert Nijhof](https://home.hccnet.nl/anij/ec/ec207a.html). Examples are:  

  - A plotter
  - [Walking robots](https://home.hccnet.nl/willem.ouwerkerk/egel-for-msp430/egel%20for%20launchpad.html#e11x)
  - [Robot arm](https://home.hccnet.nl/willem.ouwerkerk/)
  - Flowing RGB light patterns (see picture below)
  - Etc.

## Synchronised movement

Now the question is: What does PiliPlop do to make the processes evenly (synchronous) change position?

Answer: For all processes it is determined how far they have to go. The largest path (called the number of steps) is the 
starting point of the algorithm. Each motor will reach its end in that number of number of steps to reach its endpoint. 

For each process a counter is reserved, this counter is refilled with the greatest number of steps when it
this counter is refilled with the largest number of steps. Each counter is decreased by the number of steps 
that process needs to take. The result is a fairly even moving of each process.
Each process also reaches the desired end position as shown in the example.  
A dash means that nothing changes, an asterisk means that the process in question changes position.

```
Beginpos.   0       0       0       0       0
Endpos.    10       3       7       1       2

step-nr    p1      p2      p3      p4      p5
-----------------------------------------------
  1      -5 *1    2 -0   -2 *1    4 -0    3 -0  
  2      -5 *2   -1 *1    1 -1    3 -0    1 -0  
  3      -5 *3    6 -1   -6 *2    2 -0   -1 *1   
  4      -5 *4    3 -1   -3 *3    1 -0    7 -1   
  5      -5 *5    0 -1    0 -3    0 -0    5 -1   
  6      -5 *6   -3 *2   -7 *4   -1 *1    3 -1   
  7      -5 *7    4 -2   -4 *5    8 -1    1 -1   
  8      -5 *8    1 -2   -1 *6    7 -1   -1 *2   
  9      -5 *9   -2 *3    2 -6    6 -1    7 -2   
 10      -5 *10   5 -3   -5 *7    5 -1    5 -2   
-----------------------------------------------
endpos.    10       3       7       1       2
```

The example above has the initial position `0 0 0 0 0` and the desired final position 
desired end position `10 3 7 1 2`. The table shows that 10 
steps. If a counter is empty (becomes negative)
a step is taken and the counter is refilled with the maximum number of steps.
maximum number of steps. All counters are initialised at
half of the maximum number of steps,
which in this example is 10/2=5. 

The counter for process-1 (p1) must be replenished at every step
and therefore this process is switched 10 times. The counter for process-5 (p5) is only changed twice because the counter there only runs out twice.

https://user-images.githubusercontent.com/11397265/134024821-fb30683c-dc3a-4813-80b7-fdaebff9cbf9.mp4

**noForth running DEMO3 example**
```
```

## Pseudo code
```
Function: VARIABLES
	Define: ( u -- )
		Reserve u cells RAM space 
	Action: ( +n -- a )
		Leave cell address of cell +n in this structure

«p» constant #PROCESSES
#processes variables SHERE      \ Starting points for each process
#processes variables THERE      \ End points
#processes variables DIRECTION  \ Moving direction -1 or +1
#processes variables TANK       \ Amount of fuel
#processes variables USAGE      \ Fuel usage for each step ... 
0 value STEPS                   \ Largest number of process steps
0 value WAIT                    \ Wait time for each step

Function: PREPARE ( -- )
  LOOP: #processes times
      Calculate moving direction for each process & save
      Calculate moving distance for each process & save
      Determine largest moving distance & save
  Fill all tanks half full
  

Function: ONE-STEP ( -- )
  LOOP: #processes times
     Calculate new tank contents by subtracting USAGE from TANK
     IF: TANK empty
         Refuel by adding STEPS to TANK
	 Add DIRECTION to SHERE for a new position
         SHERE is the new process data
  Perform wanted action with current process data and wait.
	 
	 
Function: GO ( x0 .. xp -- )
   LOOP: #processes times
      Save all process data in THERE
   Perform PREPARE 
   LOOP: STEPS times
      Perform ONE-STEP
```

## Generic Forth

```Forth
hex
\ Not is JustForth: ABS  MS  +!
3 constant #PROCESSES
: VARIABLES    create here ,  cells allot  does> @ swap cells + ; \ Array of cells

#processes variables SHERE
#processes variables THERE
#processes variables DIRECTION
#processes variables TANK
#processes variables USAGE
0 value STEPS         	\ Largest change in steps
0 value WAIT          	\ Wait time after each STEP

: .SHERE        ( -- )	\ Put process information on screen
    cr  #processes 0 do  i shere @ 4 .r  loop  space ;

: PREPARE       ( -- )
    0 to steps ( Distance ) #processes 0 do
        i there @  i shere @              \ Data change for each process
        2dup u< 2* 1 +  i direction !     \ Remember moving direction
        - abs  dup i usage ! 	          \ Hold distance
        steps umax  to steps              \ Keep largest distance?
    loop
    #processes 0 do  steps 2/  i tank !  loop ; \ Tanks half full!

\ Some processes do not need <perform process>, for example
\ when the <store process data> is used by an interrupt
\ routine or an other task! The added WS2812 noForth example
\ however do output the data to the WS2812 leds there!
: ONE-STEP      ( -- )
    #processes 0 do
        i tank @  i usage @ -             \ Calc. tank contents
	dup i tank !                      \ Replace tank with result
	0< if                             \ Fuel shortage?
            steps  i tank +!              \ Refuel with steps
            i direction @  i shere +!     \ New motor position
\           i shere @  i <store process data> \ PLOP
        then
    loop 
    ( <perform process> )  .shere  wait ms ; \ Activate processes


: ALL-ONCE      ( -- )          steps 0 do  one-step  loop ;
: >PROCESSES    ( x0 .. xp -- ) #processes 0 do  i there !  loop ;
: GO            ( x0 .. xp -- ) >processes prepare  all-once ;

: TEST		( -- )   \ Start all processes at zero and run PiliPlop once
    10 to wait  #processes 0 do  0 i shere !  loop   10 4 8 go ;
```
