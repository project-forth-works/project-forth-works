# Print Hex

In this programming pearl Albert Nijhof shows how to
print hexadecimal numbers with a given number of digits even
if your Forth system does not provide pictured numeric output by means of `<#` `#` `#>` etc.

     1	\ Tools -- Formatted unsigned single hex number output, not using BASE
     2	\ an-17jan2022
     3	
     4	decimal
     5	: .1HX ( x -- )     \ Print last digit of x in hex
     6	    15 and                  \ lowest nibble
     7	    9 over < 7 and +        \ for A..F
     8	    [char] 0 +   emit ;
     9	
    10	: .NHX ( x n -- )   \ Print last n digits of x in hex
    11	    1 max 16 min >r                 \ x r: n
    12	    r@ 1 ?do dup 4 rshift loop      \ collect on data stack
    13	    r> 0 do .1hx loop space ;
    14	\ ----- end of code -----
    15	
    16	(*
    17	Examples
    18	decimal
    19	19150 2 .nhx     \ CE
    20	19150 3 .nhx     \ ACE
    21	19150 4 .nhx     \ 4ACE
    22	19150 8 .nhx     \ 00004ACE
    23	
    24	\ .NHX version without DO-LOOP
    25	: .NHX ( x n -- )   \ Print last n digits of x in hex
    26	    swap >r   1 max 16 min dup          \ n n r: x
    27	    begin 1- dup while r@ 4 rshift >r   \ collect on return stack
    28	    repeat drop
    29	    begin r> .1hx   1- dup 0= until drop space ;
    30	*)
    31	\ <><>

Idea
----

In order to print numbers you have to extract the digits one by one and print each digit.
As typical written number representation starts with the most signficant digit but extracting is easier
starting with the least significant digit, the order of digits needs to be reversed. This could be
done by storing the digits either on the data stack or on the return stack and make use of their last in 
first out property.


Display a single digit: `.HX1`
------------------------------

The word `.HX1` (*print hex 1 nibble*, line 5-8) displays a single digit, 
the last digit of the unsigned number `x`. 

Line 6 extracts the least significant nibble of `x` and ignores its more significant part.

To display that nibble as a character the word uses arithmetic with comparison results:

The phrase `9 over <` in line 7 compares the nibble with `9`. If it is not less (i.e. greater or equal) `9`
then the phrase results in -1 (all bits set).  
If the nibble is less than `9` the phrase results in 0 (all bits 0).  

`7 and` extracts the least 3 bits. Now we have either `7` or `0`, that we add to the nibble itself.
This leads to the nibble+7, if nibble is greater or equal `9` or 
to the original nibble value, if it is less than `9`. This is to bridge the gap in the ASCII character sequence
between '9' and 'A' as we see now.

If we look at the ASCII character
sequence we see:

    48  49  50  51  52  53  54  55  56  57     58  59  60  61  62  63  64     65  66
    '0' '1' '2' '3' '4' '5' '6' '7' '8' '9'    ':' ';' '<' '=' '>' '?' '@'    'A' 'B' ...

There is a gap between the character '9' and the character 'A' which is 7 characters wide.

Line 8 adds the character value of `'0'` to the intermediate value. 
Nibbles 0 to 9 will be mapped to character '0' to '9'. 
Nibbles 10 to 15 will be mapped (bridging the gap) to character 'A' to 'F' as is required for hexadecimal display.

This character is eventually displayed by the `emit` at the end of `.HX1` (line 8).


Display `n` digits: `.NHX`
--------------------------

In order to display complete numbers the word `.NHX` (*print n digits in hex*) is defined (line 10-13). 
`x` is the number to display and `n` ist the number to digits to show.

Line 10 does some clipping so that `n` is always in the range 1 to 16. This avoids unpleasant suprises of 
seemingly endlesss output if the  passed `n` happens to be outside that range.

To display complete numbers `.NHX` first iterates n-1 times (`DO LOOP` on line 12) and puts shifted 
numbers on the stack so that  each numbers least significant nibble is on of te nibbles of `x`. 
The number with the least significant nibble of `x` first, the number with the most significant nibble 
of `x` on top of stack.

After that the nibbles on the stack are processed in reversed order. 
They are displayed via `.HX1` (`DO LOOP`, line 13) that runs `n` times.  
`.NHX` ends by printing a space so that consecutive calls to `.NHX` will print number space separated.


No `DO LOOP`
------------

If your system does not provide `DO LOOP` then you can rewrite the loops using `BEGIN WHILE REPEAT` 
or `BEGIN UNTIL` as you can see in line 27-29. 

Line 26 does parameter clipping of `n` as before.

To avoid stack juggling the first loop (line 28) collects nibbles on the return stack. (That wouldn't have been
possible with `DO LOOP` above as the loop parameters block the return stack.)

The second loop (line 29) retrieves the nibbles from the return stack and prints them with `.HX1` as above. 
When finished it drops the loop parameter.
The obligatory space ends the number output (line 29).


Example output
--------------

Lines 18-22 show hot to use `.NHX` and what output you can expect. If the number of digits `n` given is less then
the actual numbers of digits to completely display `x` then `.NHX` truncates the display showing only the least signiicant digits.
If `n` is larger, then `.NHX` adds leading '0's.

----

uho 2022-01-20
