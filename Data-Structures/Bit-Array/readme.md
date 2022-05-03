# Bit array data structure

## Bit array idea

To store many on/off events or a present/not present note, we could use an array of bit flags to save space.  

## Implementation

The implementation assumes a byte addressed machine. The number of bits is rounded up to the number of cells needed to store the flags. The cell size in bytes is used and multiplied by 8 to calculate the number of bits in a cell.  

![bit-array](https://user-images.githubusercontent.com/11397265/128422074-6fd777dd-346e-4a0f-b77d-3f2cbc93549d.jpg)


This i a one cell array on a machine with 16-bit cell size. Three of the 16-bits are high. Note that only 4 cells (8 bytes) are required to keep track of 64 flags.  

A note on `?ABORT` noForth uses the name of the word in which ?ABORT is included as the error message. 
In the example code below, the message "Error from LOC" is printed. 
This is useful for adding clear error messages to small embedded systems.
It is also an extra motivation to use meaningful names :)  

## Pseudo code for a bit array

```
Function: BITARRAY
	Define: ( u -- )
		Reserve RAM space rounded to the next higher cell
		to allocate space for a bit-array with at least u-bits.
	Action: ( -- a )
		Leave start address of this bit-array

Function: *SET  ( bit-nr addr -- )
	Calculate from bit number and bit-array address the 
	correct bit-mask and cell-address. OR the bit-mask with
	the contents of the cell-address and store it back

Function: *CLR  ( bit-nr addr -- )
	Calculate from bit number and bit-array address the 
	correct bit-mask and cell-address. AND the inverted bit-mask
 	with the contents of the cell-address and store it back

Function: GET*  ( bit-nr addr – mask|0 )
	Calculate from bit number and array address the 
	correct bit mask and cell-address. AND the bitmask with
	the contents of the cell-address, leave the result

Function: ZERO   ( addr -- )
	Clear the bit array starting at address completely
```
## Generic Forth bit array example:
```Forth
Extra words: @+  
: ?ABORT ( fl -- )          0= 0= throw ;

Words with hardware dependencies:
: **BIS  ( mask addr -- )   tuck @ or  swap ! ;
: **BIC  ( mask addr -- )   >r  invert  r@ @ and  r> ! ;
: BIT**  ( mask addr -- 0|b ) @ and ;

8 cells  constant #BITS    \ Bits in a cell

: >LEN   ( a1 -- #n )       @ #bits * ; \ Length in bits of bit array a1
: >ADR   ( a1 -- a2 )       cell+ @ ;   \ Start address of bit array a1

: LOC           ( nr a1 -- bit a2 )     \ Bit location in cell address
  2dup >len < 0= ?abort    \ Valid bit flag check
  @+ 1- >r  @              \ nr adr 
  >r  dup #bits 1- and     \ nr bit-nr
  1 swap lshift            \ nr bit-mask 
  swap #bits /             \ nr / bits in a cell
  r> swap  r> and cells +  \ Mask excess bits, leave bit-array offset
  ;                        \ Leave bit & word-adr

: BITARRAY
  create      ( +n "name"-- )  ( exec: -- a )
    #bits /mod swap if 1+ then  dup , \ Round to the next cell
    here , cells allot ;        \ Save RAM pointer, reserve RAM in ROM Forth
\   here cell+ , cells allot ;  \ Save pointer, reserve RAM in RAM Forth

: *SET   ( nr a -- )        loc **bis ; \ Set bit nr in array a
: *CLR   ( nr a -- )        loc **bic ; \ Erase bit nr from array a
: GET*   ( nr a -- 0|msk )  loc bit** ; \ Bit nr set in array a?
: ZERO   ( a -- )           dup >adr  swap >len 8 /  0 fill ; \ Erase bit-map 
```
## Implementations
Have a look at the sub directories for implementations for different systems.  

- [noForth](noForth), specific bit-array implementation.  




