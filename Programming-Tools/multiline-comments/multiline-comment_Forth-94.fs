[ : ``` BEGIN SOURCE -TRAILING S" ```forth" COMPARE WHILE REFILL 0= UNTIL THEN  POSTPONE \ ; ``` \ ]: # ( Forth-Markdown Polyglot )

Multiline comment using `(*`  `*)`   
----------------------------------
uho 2022-01-20

    Usage:
       (* Start a comment.
          Spans multiple lines. 
          ends at *)

Idea
----

Standard Forth provides words to add comments to programs:

  - `(` to skip text until the next closing parenthesis `)`  
    In principle these comments can span multiple lines (the `(` from the File wordset) but
    many Forth systems support `(` comments only within a single line.

  - `\` skip all remaining text on the current line

As Forth is extensible it is possible to define additional comment words. Many flavours are possible.
Here we focus on Pascal like comments using `(*` to start and `*)` to end a comment.

So we seek to define an new word ´(*` that skips the source text until it finds the end of comment.

Because the Forth input stream might only consist of the current line, this word `(*` in search of `*)` 
probably has to read addtional source code lines until it finds `*)` and the comment ends.

## Nested comments

Sometimes you might want to comment parts of the source text that contains comments themselves.
If comments nest, i.e. you can have comments inside comments, then this is possible without 
further issues. If however only a naive search for the next `*)` is done to indentify the end of
comment, then the end of the inner comment would also be considered the end the outer comment:

    (* outer comment
       (* inner comment *)
       still comment if comments can nest, but not a comment if they don't nest.
     *) probably error when not nesting as *) is typically not a defined word.


Pseudo code
-----------

#### Naive implementation (non-nested)

    Function: (* ( -- )
       - Parse the rest of the input stream searching for *)
       - If *) is found then end searching
       - If *) is not found within the available source text,  
         load more source text and continue search.

Using this algorithm, skipping text stops at the first occurance of `*)`.

#### Implementation with nested comments

    Function: (* ( -- )
       - Parse the rest of the input stream searching for *)
       - If the current *) is found then end this searching and resume any delayed searches.      
       - If another (* is encountered then delay the search of the current *)  
         and start the search for another *).
       - If *) is not found within the available source text, 
         load more source text and continue search.

Using this algorithm the number of nested comments is counted by the number of delayed searches.

## Implementation 

A naive non nesting Forth-94 implementation may look like this:

```
: (* ( -- )
    BEGIN
      BEGIN 
        cr  bl word count dup            \ next token available?
      WHILE ( c-addr u )
         s" *)" compare 0= IF EXIT THEN  \ stop if end of comment found
      REPEAT 2drop
      refill 0=                          \ read more source code
    UNTIL ; immediate                    \ end of source code
```

A version that allows for nesting comments:

```forth
   : (* ( -- )
       BEGIN
         BEGIN 
           cr  bl word count dup                       \ next token available?
         WHILE ( c-addr u )
            2dup s" *)" compare 0= IF 2drop EXIT THEN  \ stop if end of comment found
                 s" (*" compare 0= IF recurse THEN     \ start of nested comment
         REPEAT 2drop
         refill 0=                                     \ read more source code
       UNTIL ; immediate                               \ end of source code
```

Both implementations will extract tokens from the input stream. Thus both `(*` and `*)` must be separated
by whitespace and must not be attached to printable characters for them to be considered start or end 
of comment. Thus:

    (* this does not end the comment*) but this does *)

In practice that does not impose serious limitations.

## Standard conformant labeling

This is an ANS Forth Program with environmental dependencies,

- Requiring WORD WHILE UNTIL THEN REPEAT IF EXIT DUP COUNT BL BEGIN ; : 2DROP 0= S" ( from the Core word set.
- Requiring \ from the Core Extensions word set. 
- Requiring REFILL from the File Access Extensions word set.
- Requiring COMPARE from the String word set.
 
### Required program documentation

This program has the environmental dependencies to use lower case for standard definition.
After loading this program, a Standard System still exists.

## Test

The test for handling nested comments:

```forth
(* .( Start of outer comment )
   
   (* 
       .( inner comment )
    *)

   .( This should not print if comments nest! )

*)
```

should not print anything.

# Alternative Implementations

If you face a ressource constraint system you might want to further simplify the definition of `(*` in order
to impose fewer requirements on the supporting system. In the above definition there are two required words that
might not be supported in a ressource constraint system: `REFILL` and `COMPARE`. 

`REFILL` (or its terminal/command line counterparts `EXPECT`, `QUERY` or `ACCEPT`) is propably always necessary 
to keep reading input lines in case `*)` has not yet been found. 

The use of `COMPARE` on the other hand can be eliminated as we only want to test for `*)` (and for `(*` in the nesting case). 

Here is Albert Nijhof's approach:

```
\ -----
\ Tool - Multi-line comment - an 17jan2022

\ (* starts a multi-line comment. Not nestable.
\ The delimiter *) must be the first word on a line.

: (*    ( -- )
   0   \ dummy
   begin begin begin   drop
       cr  refill 0= if exit then
       bl word
       count        2 = until
       count [char] * = until
       count [char] ) = until
   drop ; immediate
\ -----
```

> `(*`  
> a) This simple code was intended for small systems.
> That's why I avoided the word `COMPARE`. Unfortunately,
> "REFILL" was unavoidable.
>
>
> b) The delimiter `*)` must be the first word on a line.
> This is not to keep the code simple or make it
> faster. I purposely chose this because it is better,
> it provides a clearly readable layout.  
> `*)`
>
> Compare this with:
>
> `(*`  
> a) This simple code was intended for small systems.
> That's why I avoided the word `COMPARE`. Unfortunately,
> "REFILL" was unavoidable.
> 
> b) This is not to keep the code simple or make it
> faster. I purposely chose this because it is better,
> it provides a clearly readable layout. `*)`

This code has some interesting properties:

- It uses a character based comparison to detect `*)` instead 
  of a string based `COMPARE`.

- It uses 3 nested BEGIN UNTIL loops to iterate the input stream.  
  Each UNTIL has a condition
    1. the length of the parse word is 2
    2. the first character is the character '*'
    3. the second character is the character ')'  
  
  Only if all of the UNTIL conditions are met (first AND second AND third) 
  the nested loops end, otherwise they branch back to one of the 
  BEGINs and keep parsing the next line of the input stream. 
  Essentially the code inspects the first token on each line (possible with
  leading white space).

- When testing the UNTIL conditions the address of the next character
  is left over on the stack and needs to be dropped somewhere.   
  The code does this at the *beginning* of the loops and to make that
  work even on the first iteration the code puts a dummy 0 on the stack 
  before the beginning of the loops.  
  The address also must be dropped when all UNTIL conditions are satisfied, 
  i.e. when `*)` is found. This is done right after the loop.

