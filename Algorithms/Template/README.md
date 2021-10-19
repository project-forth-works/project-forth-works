# Template for a new ideas called «name»

## «name» idea

*Explain in a few words what the idea of this description is.*
*The reader should understand what this is about so that s/he can decide whether or not it is worthwhile to continue reading.*

*What is the problem. How is the problem solved?*

*Continue also to explain background information and the idea proper. Is there a trick?* 

## Implementation

*Discuss a typical (possibly naïve) implementation that best allows to understand the implementation.* 
*More sophisticated/optimized implementations can be presented later. Most system specific implementations will be optimized.*

## Implementation in pseudo code

*Use pseudo code following this style:
```
Function: «name» ( input parameters -- results )
  «prose text descripting operations in this function»
 
  Set «variable» to «description of value»
  «imperative subject object ...»
  
  IF «condition»:
     ...
  ELSE:
     ...
  
  WHILE «condition»:
     ...
```
*For defining words use:*
```
Function  
	Define: ( u -- )
		Reserve RAM space 
		allocate ROM space 
	Action: ( -- a )
		Leave start address of this 
```

## Minimal Forth implementation:

*Try to implement the pseudo code using the words in [Minimal Forth](http://www.euroforth.org/ef15/papers/knaggs.pdf) mentioning and explaining all additional words that
your implementation requires*

*Also show how your implementation is used by giving some examples.*


## Various other Implementations

*Present additional (possibly more sophisticated) implementations, e.g for a specific microcontroller boards, a specific Forth system or in Standard Forth.*
*Try to state precisely what implementations you present and what requirements they have. No need to be portable here: Embrace the difference*


## Background information

*Please give references to data sheets, background articles or articles for follow up reading.*

--- 
# Example following this structure

# DUMP memory algorithm

## DUMP idea

A DUMP utility is a software tool that allows to inspect main memory and display it in a user readable form.
Typically output is composed of several lines that have the structure:

«address» «representation of bytes starting in memory at address in hex or in another radix» «ASCII representation of these bytes»

The DUMP utility is normally called `DUMP` and is invoked with parameters which specify what memory to inspect, often start address and length.


## DUMP Implementation

One way to implement DUMP is to iterate in a loop line by line through memory. Say you want to display 16 bytes in each line, then this loop will start
at the start address and increment the address by 16 in each loop iteration.

When you display memory in a single line you first output the current address and then have two loops that run one after the other iterating both from 0 to 15.
The first loop outputs bytes with two hexadecimal digits (or in decimal, or whatever you intend) and the second loop ouputs the indivual bytes as ASCII characters.

As some characters might control the ouput in a special way (so called control character such as 07 bell, 0A linefeed, 0C formfeed) ist is wise to just ouput a period 
instead of the actualt character, in order to get a well formatted display.


## Pseudo code for the DUMP implementation

```
Function: dump-line ( address -- )
  ouput address (possibly right aligned)
  output ":" and some space
  
  LOOP i from 0 to 15:
     output byte in memory at (address+i) as two hexdecimal digits (or in another radix if desired)
     output some space
  
  LOOP i from 0 to 15:
     output byte in memory at (address+i) as an ASCII character, "." if that character is a control character (byte<32)
```

## Minimal Forth implementation of DUMP:

You can find a Minimal Forth implementation of DUMP in [dump-Minimal_Forth.fs](dump-Minimal_Forth.fs).

You can use it as follows:

```forth
  ok
Create x 100 allot  ok
x 100 dump
03D694: 05 61 6C 6C 6F 74 08 00 DF 14 00 00 C1 00 08 00   .allot..?...?...
03D6A4: 1F 18 00 00 C1 00 08 00 6F 10 00 00 C1 00 08 00   ....?...o...?...
03D6B4: 4F 10 00 00 C2 00 08 00 1F 13 00 00 C2 00 08 00   O...?.......?...
03D6C4: 8F 30 00 00 C2 00 08 00 DF 14 00 00 C2 00 08 00   ?0..?...?...?...
03D6D4: 1F 18 00 00 C2 00 08 00 6F 10 00 00 C2 00 08 00   ....?...o...?...
03D6E4: 4F 10 00 00 C3 00 08 00 8F 30 00 00 C3 00 08 00   O...?...?0..?...
03D6F4: 5F 13 00 00                                       _... ok
```

As the original Minimal Forth has no output facility other than `emit` and `.s` (specificly no number formatting and no `.` or `.r´)
this implementation seems to be over complicated.

We extended Minimal Forth to [Minimal Forth & extensions](https://github.com/embeddingforth/embeddingForth.github.io/minimalforth.md) to get a
more useful small Forth.

A DUMP utility in *Minimal Forth & extensions* can be found in [hex-dump-MinForth+ext.f](hex-dump-MinForth+ext.f)


## Various DUMP Implementations

Other DUMP implementations can be found in the sub directories of [Algorithms/DUMP](https://github.com/embeddingforth/Algorithms/DUMP).


## Background information

More about the DUMP utility can found at the [Wikipedia page for hexdump](https://en.wikipedia.org/wiki/Hex_dump).

Some Forth DUMP implementations display a fixed amount of bytes and leave the updated address on the stack so that
you can invoke DUMP repeatedly to display successive regions of memory.
