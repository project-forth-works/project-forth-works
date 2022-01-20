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
        bl word count dup                \ next token available?
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
           bl word count dup                           \ next token available?
         WHILE ( c-addr u )
            2dup s" *)" compare 0= IF 2drop EXIT THEN  \ stop if end of comment found
                 s" (*" compare 0= IF recurse THEN     \ start of nested comment
         REPEAT 2drop
         refill 0=                                     \ read more source code
       UNTIL ; immediate                               \ end of source code
```

Both implementations will extract tokens from the input stream. Thus both `(*` and `*)` must be separacted
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

The test for handlking nested comments:

```forth
(* .( Start of outer comment )
   
   (* 
       .( inner comment )
    *)

   .( This should not print if comments nest! )

*)
```

should not print anything.
