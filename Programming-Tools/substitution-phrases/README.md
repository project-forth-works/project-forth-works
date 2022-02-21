# Substitution phrases

uh 2022-02-21

## The idea of substitution phrases

Sometimes you face a Forth system, that does not support a specific 
feature that you might want to use. For example you might want to compare 
two numbers (first and second) to find out whether or not the first number is less or equal than
the second number. You would like to write

    first second <=  

If the the system you use does not define the word `<=` you have several choices to deal with this:

- Instead of `<=` you can write the *substitution phrase* `> 0=` as *less or equal* is the same as *not greater*.

- Or you can define the missing operator and make use of the substitution phrase in the definition:
  
      : <= ( n1 n2 -- f )  > 0= ;

It is not always reasonable to make a new definition. Sometimes it is better to just use the substitution phrase
as is in the program.

Anyway it is good to know about substitution phrases.


So here is the definition of a substition phrase

> **Substiution Phrase**
>
> A *substitution phrase* is a (typically short) sequence of words that replace an undefined word.
> Executing the phrase and executing the replaced word would have the same effect (if the word would be defined).

## Some substitution phrases

Here are some substitution phrases that you can use and that might be used in programs that you encounter:


| You can write       | instead of       | if                                           |
| ------------------- | ---------------- | -------------------------------------------- |
| `swap drop`         | `nip`            |                                              |
| `over + swap`       | `bounds`         |                                              |
| `over over`         | `2dup`           |                                              |
| `drop drop`         | `2drop`          |                                              |
| `swap over`         | `tuck`           |                                              |          
| `0`                 | `false`          |                                              |          
| `-1`                | `true`           |                                              |
| `1 +`               | `1+`             |                                              |
| `1 -`               | `1-`             |                                              |
| `- 0=`              | `=`              |                                              |          
| `xor`               | `<>`             | no proper flag is necessary, i.e. for `IF` … |
| `-`                 | `<>`             | dito                                         |
| `= 0=`              | `<>`             |                                              |          
| `swap <`            | `>`              |                                              |          
| `> 0=`              | `<=`             |                                              |
| `0=`                | `not`            | if `not` would work on proper flags          |          
| `0= 0=`             | `0<>`            |                                              |          
| `swap >r >r`        | `2>r`            |                                              |
| `r> r> swap`        | `2r>`            |                                              |          
| `[ char x ] Literal`| `[char] x`       |                                              |          
| `[ ' w ] Literal`   | `['] w`          |                                              |          
| …                   | …                |                                              |


### Substitution phrases for control structures

Some Forth systems do not support `DO LOOP` or don't have `?DO` or `+LOOP`. 
You can substitute their uses with appropriate `BEGIN UNTIL` ( or `BEGIN WHILE REPEAT`) loops.  

Please have a look at the files

- [loop-an.txt](loop-an.txt) and
- [plusloop-an.f](plusloop-an.f)

for a discussion how substitute these.



### Possible pitfalls with substitution phrases vs. definitions.

Sometimes you cannot just use a substitution phrase and pour them into a definition.
When invoking a word it uses the return stack to store the return address of the caller, so 
execution can continue in the caller when the current word is done.
So, if your execution phrase contains return stack operators (as the substitution phrase for `2r>` above),
you cannot use that phrase to define a substitution word.

    \ INCORRECT

    : 2r> ( -- x1 x2 )  r> r> swap ;

    \ INCORRECT

You would need to define a *compiling word* and compile the appropriate words as if the substition phrase 
would have been used directly:

    \ CORRECT

    : 2r> ( -- x1 x2 )  postpone r>  postpone r>  postpone swap ; immediate

If this in the end is simpler than using the substitution phrase directly, depends on the situation.

