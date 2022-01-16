# Day of The Week

In this programming pearl Albert Nijhof shows how to
extract strings form a sequence of strings.

The idea here is to represent the sequence of strings as a single string.

```forth {.line-numbers}
\ Day of the week -- an-10jan2022
\ From number to name, not using the case statement

\   0   1   2   3   4   5   6
\   sun mon tue wed thu fri sat

\ For constant string length
: .DAY ( n -- )    \ n in [0,6]
    7 umin
    s" SunMonTueWedThuFriSat???" drop
    swap 3 * + 3 type space ;

\ 3 .day  -> wed
\ 8 .day  -> ???

\ For irregular string length
: .DAY ( n -- )    \ n in [0,6]
    7 umin
    s" 3Sun 3Mon 4Tues 6Wednes 5Thurs 3Fri 5Satur 1?" drop
    swap 0
    ?do begin count bl = until
    loop count [char] 0 - type
    ." day " ;

\ 3 .day  -> Wednesday
\ 9 .day  -> ???day

\ Try this for months. ( :septiembre )
\ : M, ( adr len -- ) 0 ?do count c, loop drop ;
decimal create (MESES)
ch " parse 5enero 7febrero 5marzo 5abril 4mayo 5junio 5julio "    m,
ch " parse 6agosto :septiembre 7octubre 9noviembre 9diciembre 1?" m,
    align
: .MES ( n -- )   \ n in [1,12]
    1- 12 umin (meses) swap 0
    ?do begin count bl = until
    loop count [char] 0 - type space ;

\ 9 .mes  -> septiembre
\ 0 .mes  -> ?

\ <><>

```

## Extract constant-length strings

First let's assume all element strings of the sequence have the same length.

Then the start address of the string n in the sequence can be calculated by

    «address of string n» = «start-address of seqence» + n * «fixed length of element strings»

In Forth that looks like the definition of `.DAY` in line 8-11. The fixed length here is 3.
The sequence has 8 elements. `7 umin` (line 9) is a bounds check, that maps every value outside the 
range 0 to 7 to the value 7 (negative numbers considered as unsigned numbers are greater than 7 thus
will map to 7).

`S" DROP` (line 10) puts `c-addr` on the stack, the start address of the string.
Line 11 then calculates the address of the substring,  provides the length (3), and displays it.


## Extract strings of variable length

If the element strings in the sequence are not all of the same length, then their
individual lengths need to be stored as well. The lookup then has to traverse the sequence on a
string by string basis to find the nth string.

The definition of `.DAY` in line 17 to 23 shows how to encode the length of the element strings 
and traverse the sequence.  
The range check in line 18 is as described above.  
The represented sequence (line 19) now has a length byte in front of each element string. Charater '1' represents
the length 1, '2' the length 2 and so on. Lenghts greater 9 would be represented by characters ':', ';', '<'
according to the ASCII character encoding but that is not necessary in this example.

Line 21 iterates over the sequence to the nth element string. It assumes that not only is their individual length
embedded but also that they are separated by a single space character: 
The `BEGIN count bl = UNTIL` loop skips over the characters until a space is encountered. 
`COUNT ( c-addr1 -- c-addr2 u )` extracts the next character. That functionality is sometimes called `c@+` and can
be defined as `: c@+ ( c-addr1 -- c-addr2 u )  DUP 1 + SWAP c@ ;` assuming a byte addressed 
machine (i.e. 1 CHARS = 1).  
The surrounding `?DO LOOP` iterates n times so it leaves the address of the nth element string. Memory at 
that address holds the encoded length that is fetched (line 22, `COUNT`) and transformed to the actual length
by subtractig the character value of '0'. Having address and length of the element string `type` displays it.
The trailing "day " line 23 completes the weekday (every weekday in english ends in "day").

If n is out of range 0 to 6 then `.DAY` works as follows:  
n is mapped to 7 (line 18), the last element string is found ("1?", line 21), 
its length extracted (1) and "?" displayed (line 22).

So `.DAY` eventually prints "?day ".


## Long sequence

In the english version displaying days of the week the encoded sequence (line 19) has a length of 45 characters.
Short enough to be represented in a single line of source code.  
If however the string to be stored in memory is larger than a single line, it might
be better to construct it in a different way.

Line 30-33 show how to do it. They assume that a word `M, ( adr len --)` (see comment in line 29) is 
available that lays down a string character by character at `HERE` in the dictionary. It moves `HERE` forward so that it continues to point to available dictionary space.

Line 30 gives the name `(MESES)` to the sequence (start address of the string representing the sequence).   
Line 31 and 32 use `M,` to store two parts of the string. `CH` is a synonym of `CHAR`. Both lines parse a quote (")
terminated string and then lay it down in the dictionary. For systems that require aligned disctionary addresses
the `ALIGN` in line 33 pads the dictionary so `HERE` will be a cell aligned address.

The definition of `.MES` (line 34-37) is similar to `.DAY` (line 17-23) only that indices n for months go from
1 to 12 (not 0 to 7 as before). Also spanish month names do not have a common ending, so the element string is
all that is displayd (no "day ").

## Summary

It is possible to store sequences of strings as single strings in memory and it is easy to extract the individual element strings:  
If all element strings have fixed length you can do address calculation, otherwise you can traverse
these sequences and find the appropriate strings.  

Lengths can be encoded as characters.

Longer strings can be constructed step by step in memory.

