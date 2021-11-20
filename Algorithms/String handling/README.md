# String handling

## The idea

When you need to add text strings to each other to construct new character strings.  
We need a word set to do just that. Original idea [Albert van der Horst](https://home.hccnet.nl/a.w.m.van.der.horst/index.html). 
Examples are:  

- Manipulate files
- Start programs
- Add, delete and use folders/directories
- Etc.

## Construction of strings

Strings in Forth are of the type address & length. The length is stored in
front of the string. The so called counted strings, as is shown in the picture:  

![string usage example](https://user-images.githubusercontent.com/11397265/142727480-4cb13037-c118-4d05-9eec-529aeaf23cad.jpg)  



- String word sets
  - [Primitive string word set](Primitive-string-word-set.f) \(Simple string word set e.g. for file and OS interfacing)
  - Etc.

## Pseudo code
```
Function: $@
  Fetch counted string from address
Function: $+!
  Extend counted string at address
Function: $!
  Store counted string at address
Function: $.
  Print counted string
Function: $C+!
  Add character to counted string at address
```

## Generic Forth

The idea of strings is that a character string (s)
is in fact a counted string (c) that has been stored.
s (c-addr) is the string, c (c-addr u) is constant string

```Forth
: C+!   ( n a -- )      >r  r@ c@ +  r> c! ;    \ Incr. byte with n at a
: $@    ( s -- c )      count ;                 \ Fetch string
: $+!   ( c s -- )      >r  tuck  r@ $@ +  swap cmove  r> c+! ; \ Extend string 
: $!    ( c s -- )      0 over c!  $+! ;        \ Store string
: $.    ( c -- )        type ;                  \ Print string
: $C+!  ( char s -- )   dup >r  $@ + c!  1 r> c+! ; \ Add char to string
```

## Implementations

Have a look at the sub directories for implementations for different systems.