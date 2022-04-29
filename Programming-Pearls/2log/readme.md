### 2LOG

The 2LOG routine was the result of the need for converting a linear input into something with a more logarithmic character. There was no need for high accuracy, but rather a short reliable routine.
The routine uses a very simple principle, but the result is surprisingly useable. A prime example where focussing on the essentials results in an excellent solution.

The 2LOG routine produces as output fixed floating point number with 8 bits after the decimal point. ( x...x**.**xxxxxxxx ) The number of bits before the decimal point depends on the width of the native width of the stack.

#### The principle used is this:

looking at the number to be converted in binary representation:
- take the position of the first set bit as number before the decimal point
- as 8 bit fraction take the highest 8 bits following the most most significant set bit. If there are less than 8 bits, pad the end with clear bits up to 8 bits.

It is good to notice that the fractional part forms a linear interpolation between two consecutive log number. For most purposes that is accurate enough.

#### the generic Forth program

As example we look at the routine for a 16b Forth. The other example is suitable for all Forth implementations.

```
\ : B+B ( byte1 byte2 -- x )			\ uncomment when not available
\	8 lshift or ; 						\ ( ie: 12 34 -- 3412 )

: 2LOG16b ( u -- y )
    16 0 do
    	s>d if
    		2* 8 rshift 				\ lineaire interpolatie
        		15 i -   					\ logaritmische klasse
            b+b leave
        then 2*
    loop ;
```

- The programs does maximal 16 loops.
- For each loop S>D is used to check if the most significant bit is set. If not, then the program shifts the number 1 bit to the right with 2*.
- Otherwise it calculates the output.
	- The logarithmic part is calculated by subtracting the index from 15.
	- The fractional part is calculated by shifting to left with 1bit, followed by shifting 8 bits to the right.

- Finally, both numbers are then combined into 1 using B+B as final output.

#### The general version

The general version is suitable for all Forth-implementations which have a multiple of 8 bits as cell-width. It functions in exact the same way as the 16b example above. But during compilation it calculates the, for that Forth-implementation relevant, values for the do**...**loop, shift and subtraction.

```
: 2LOG ( u -- y )
    [ 8 cells ] literal 0 do  				\ #bits/cell
    	s>d if  2*
            [ 8 cells 8 - ] literal rshift  \ lineaire interpolatie
            [ 8 cells 1- ]  literal  i -    \ logaritmische klasse
            b+b leave
        then 2*
    loop ;
```








