# DUMP memory algorithm: display content of main memory

## DUMP idea

A DUMP utility is a software tool that allows to inspect main memory and display it in a user readable form.
Typically output is composed of several lines that have the structure:

Display bytes starting in memory at a given address in hex (or other radix). Behind them is the ASCII representation of these bytes.

The DUMP utility is normally called `DUMP` and is invoked with parameters which specify what memory to inspect, often start address and length.


## DUMP Implementation

One way to implement DUMP is to iterate in a loop line by line through memory. Say you want to display 16 bytes in each line, then this loop will start
at the start address and increment the address by 16 in each loop iteration. (If you want a different number of bytes in each line, adjust accordingly).

When you display memory in a single line you first output the current address and then have two loops that run one after the other iterating both from 0 to 15.
The first loop outputs bytes with two hexadecimal digits (or in decimal, or whatever you intend) and the second loop ouputs the indivual bytes as ASCII characters.

As some characters might control the output in a special way (so called control character such as 07 bell, 0A linefeed, 0C formfeed) it is wise to just ouput a period 
instead of the actual character, in order to get a well formatted display.


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
     
Function: dump ( address length -- )
   WHILE length is positive:
        dump-line at address
        increase address by 16
        decrease length by 16
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

We extended Minimal Forth to [**JustForth**](https://github.com/embeddingforth/embeddingForth.github.io/blob/main/minimalforth.md) to get a
more useful small Forth.

A DUMP utility in *JustForth* can be found in [hex-dump-MinForth+ext.f](hex-dump-MinForth+ext.f)
This example is factored using the pseudo code description. The character output has been factored into the useful word PEMIT ( char -- ) too.


## Various DUMP Implementations

Other DUMP implementations can be found in the sub directories of [Algorithms/DUMP](https://github.com/embeddingforth/embeddingForth/tree/main/System-Software/dump).

Your system might lack right justified number output or even BASE for printing numbers in other radix systems. The sample implementation in
[twomoredumps.f](https://github.com/embeddingforth/embeddingForth/tree/main/System-Software/dump/twomoredumps.f) show how to circumvent this.


## Background information

More about the DUMP utility can found at the [Wikipedia page for hexdump](https://en.wikipedia.org/wiki/Hex_dump).

Some Forth DUMP implementations display a fixed amount of bytes and leave the updated address on the stack so that
you can invoke DUMP repeatedly to display successive regions of memory.

### Possible pitfalls with DUMP

Some systems have hardware memory protection that is triggered if you access memory outside the reserved area.
The dump utility can do so by trying to show this forbidden memory. Triggered memory protect might stop the current process and
terminate your session. If necessary a suitable test for the validity of used addresses might be reasonable on such systems so that
dump can issue a normal error message (or display dummy data) in theses cases and leave the system / session otherwise intact.
