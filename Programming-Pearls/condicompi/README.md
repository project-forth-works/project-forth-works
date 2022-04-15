# Conditional Compilation

Conditional compilation lets you selectively process program text depending on certain conditions. We look at different flavours.

### The ICE concept

One of Forth strengths is its ICE (interpret, compile, execute) concept: You can

- **interpret** expressions while the program text is processed,
- **compile** function definitions (words) to capture actions for reuse, and
- **execute** these words with different parameters

within the same program text.

In Forth you can switch between I, C, E arbitrarily.  
While interpreting you can make 
a definition via `:` or any other defining word and you can execute words by just putting their parameters on the stack and then call words by mentioning their names.  
While compiling you can enclose program text to be interpreted (and executed) in `[` and `]`.  
Forth even executes *immediate compiling words* always intended whether of not it just interprets or compiles other words.

### `[IF]` `[ELSE]` `[THEN]`

Standard Forth proposes to have the immediate words `[IF]`, `[ELSE]` and `[THEN]`. They are used in the form


```forth
«words to be processed»
«some sequence of words that puts a value on the stack»
[IF]
   «words to be processed if that value is not zero»
[ELSE]
   «words to be processed if that value is zero»
[THEN]
«more words to be processed»
```

`«some sequence of words that puts a value on the stack»`
is supposed to describe a condition. If it holds then the sequence between `[IF]` and `[ELSE]` is processed, if it does not hold, the sequence between `[ELSE]` and `[THEN]`is processed.  
`[ELSE]` can be omitted and `[IF]`, `[ELSE]`, `[THEN]` can 
be nested inside any of the above sequences. 
`[IF]`, `[ELSE]`, `[THEN]` are immediate words, i.e. they execute even if other words are currently being compiled.

One drawback of `[IF]` shows up, if you try to use it inside definitions (in compilation mode): Although `[IF]` itself is immediate and thus will execute if used 
inside a definition, the *sequence of words that puts a value on the stack* needs to be executed as well (and not compiled into the definition). Because of this
the sequence typically is enclosed in brackets itself to enforce its execution:

Inside a definition:
```forth
: «someword» ( ... -- ... )
    [ «some sequence of words that puts a value on the stack» ]
    [IF]
    ...
    [THEN]
    ...
;
```

### Variant based conditional compilation

In this programming pearl Albert Nijhof shows how to do conditional compilation, i.e. processing parts of the program text depending on some conditions.

The idea here is to have a convenient conditional compilation syntax that can distinguish given variants.
A *variant* is a specific (named) configuration that the program should be adapted to, such as a specific kind of arithmetic it should use or the presence of certain features.  
Each variant is denoted by a single symbol most often a single letter. The conditions have the form of disjunctions (`OR`-connection) of the variants (e.g. *"variant A or variant C or variant F"*).

Instead of
```forth
«some sequence of words that puts a non zero value on the stack  
 if variant A or variant C or variant F is selected»
[IF]
  «words to be processed if that value is not zero»
[THEN]
```

we would like to write

```forth
[IF ACF]
  «words to be processed if variant is A or C or F»
[THEN]
```

So what we need is to define a new immediate word **`[IF`** that parses the input stream for variant symbols up to a closing `]`, determines the disjunction, puts an appropriate value (flag) on the stack and the invokes `[IF]`.

Here is Albert's code that does just that.

```forth
     1 \ Conditional compilation -- an 03mar2022
     2  \ Needs [IF] [THEN] [ELSE]
     3  
     4  \ ----- forth code -----
     5  0 value VARIANT
     6  : [IF ( ccc] -- )       \ ccc is case-sensitive
     7      bl word dup c@ 1 max
     8      begin 1 /string dup
     9            while over c@ variant =
    10      until then  nip
    11      postpone [IF] ; immediate
    12  \ ----- end -----
    13
```

The currently selected variant to be processed is supposed to be stored in the Forth value `VARIANT`.

Line 7 parses the input stream up to the next space, i.e. just including the trailing `]`. 
The resulting string (address before the first character and its length) is on the stack at the end of line 7. (`1 max` deals with an empty string.) 

Lines 8-10 then look in loop wether or not the string contains the (symbol denoting the) current variant by inspecting the  string one character after the other: `1 /string` adjusts the length and the address so that the length is the number of characters that still need to be inspected. If there are no more than the loop ends.
The address is corrected so that it refers to the next character to be inspected.

Line 9 then checks that character against the variant symbol. If it is found then the loop also stops.

Note, that the loop is quite uncommon. It is a `BEGIN` `WHILE` `UNTIL` `THEN` loop that has two exits: 

1. exit when there are no more characters to be processed (the length became 0) and the variant symbol has not been encountered.
2. exit when the current variant symbol is encountered (the length then is not equal to zero) before the end of the string.

The `nip` in line 10 just gets rid of the address that is no longer useful at that place.

So the length is appropriate as the condition value that can be passed to `[IF]` (being 0 in the one case not zero in the other). Line 11 invokes `[IF]`. As it is an immediate word and we don't want to execute it while defining `[IF` but later, when `[IF` is executed itself, we need to `POSTPONE` its execution.

As `[IF` parses the input stream for the variant symbols it can be used outside and inside definitions alike. It thus avoids the above mentioned drawback of `[IF]`.

That's it the ICE principle in action: A nice custom syntax that allows for a concise notation.

---

Albert's explanation and test examples:

```forth
    (*
        [IF A]    -code- [THEN]   \ -code- is only for variant A
        [IF AB]   -code- [THEN]   \ for A and B
        [IF ACDE] -code- [THEN]   \ for A, C, D and E
    
    You want to write a generic code
    that differs only slightly in some variants.
    Conditional compilation can be a solution.
        Name each variant with a letter.
        [IF reads the next "word" from the input stream.
    *)
    
    \ ----- Test
    char A to variant
    [IF AC]    1 [ELSE] 0 [THEN] .
    [IF CA]    1 [ELSE] 0 [THEN] .
    [IF B]     1 [ELSE] 0 [THEN] .
    [IF BCEFD] 1 [ELSE] 0 [THEN] .
    [IF 13%A]  1 [ELSE] 0 [THEN] .
    [IF ]      1 [ELSE] 0 [THEN] .
    : test1 [IF BCEFD] 1 [ELSE] 0 [THEN] . ;
    char C to variant
    : test2 [IF BCEFD] 1 [ELSE] 0 [THEN] . ;
    test1
    test2
    
    (*
    ----- Test results
    char A to variant  OK
    [IF AC]    1 [ELSE] 0 [THEN] . 1  OK
    [IF CA]    1 [ELSE] 0 [THEN] . 1  OK
    [IF B]     1 [ELSE] 0 [THEN] . 0  OK
    [IF BCEFD] 1 [ELSE] 0 [THEN] . 0  OK
    [IF 13%A]  1 [ELSE] 0 [THEN] . 1  OK
    [IF ]      1 [ELSE] 0 [THEN] . 0  OK
    : test1 [IF BCEFD] 1 [ELSE] 0 [THEN] . ;  OK
    char C to variant  OK
    : test2 [IF BCEFD] 1 [ELSE] 0 [THEN] . ;  OK
    test1 0  OK
    test2 1  OK
    ( Have a look at SEE TEST1 and SEE TEST2 )
    
    ----- noForth code (VALUE and BL-WORD)
    value VARIANT
    : [IF ( ccc] -- )       \ ccc is case-sensitive
        bl-word dup c@ 1 max
        begin 1 /string dup
              while over c@ variant =
        until then  nip
        postpone [IF] ; immediate
    *)
    \ <><>
```
---

uh 2022-03-28
