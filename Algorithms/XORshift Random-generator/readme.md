# XORshift random generator

## Introduction

Prof. G. Marsaglia in 1995 published the well-known DIEHARD set of
statistical tests for measuring the quality of random generators.
In 2003 he published a novel way of generating random numbers,
called the XORshift generator. It is fast and has good quality.
It is also easy to implement and can be adapted to the needs of the user.
The method works with any number of seeds and can be adapted
to 16, 32 or 64 bits (or larger...)

## Principle of the Marsaglia algorithm

A random number is generated from a seed as follows:
- Take a copy of the seed
- Shift that copy left with a certain number of bits
xor the original seed and the shifted seed to form the result
of the first step
- These steps are repeated twice, each time with the output of
the previous step as input, but with a right shift and finally
with a left shift.

The actual number of bits used for the 3 shifts is critical.
For a 32bit generator there are exactly 648 valid combinations. The
favorite combination of Marsaglia was (13, 17, 5) which is
used here.

For 16bit generators only a few valid combinations
exist: (7, 9, 13) and (7, 9, 8).

For 64 bit generators 2200 valid combinations exist. Examples are: (24, 31, 35)
or (19, 41, 21) and many others. See the link below for exact details


The Forth-code is probably easier to understand than this
explanation...


### The algorithm in pseudo-code
```
variable seed - any value but 0x0 is acceptable as seed.

Function: XORshift
   get value from seed

   make a copy of the value
   lshift copy with n bits
   xor with the original

   repeat with the output of the previous cycle and a rshift with m bits

   repeat with the output of the previous cycle and a lshift with o bits

   return the result on stack

   store the final result in the variable seed for a next cycle
```

### Generic Forth

```forth
\ 32bit version with 1 seed in a variable

variable seed
2345 seed !             \ start the seed with any number but 0

: FORTHRANDOM1 ( address_seed -- rndm_val )
  dup >r @
  dup 13 lshift xor
  dup 17 rshift xor
  dup 5 lshift xor
  dup r> ! ;
```

### Adding a second (or more) seed.
For the 32 bit version 1 seed is not enough to pass the DIEHARD quality tests,
at least 2 seeds are needed. Adding an extra seed takes a few extra steps.

   first seed is input to the three cyles
   do the 3 cycles and return the final result
   update the seeds: second seed is copied into the first seed
   OR result of the 3 cycles with the value of the second seed

This way of adding more seeds can be done at infinitum. The more seeds you add, the
longer the wrap-to-zero period. With two 32 bit seeds, the wrap-to-zero period is 2^64-1 values.


### The algorithm with 2 seeds in pseudo-code
```
\ 2 seeds version

variable seed1
variable seed2

Function: XORshift
   get value from seed1

   make a copy of the value
   lshift copy with n bits
   xor with the original value

   repeat with the output of the previous cycle and a rshift with m bits

   repeat with the output of the previous cycle and a lshift with o bits

   return final the result on stack

   move value of seed2 to variable seed1
   OR the final result with the value in seed2 for a next cycle
```

### Generic Forth version
```forth
\ 32 bit version with 2 seeds in values:

2345 value SEED0
6789 value SEED1

: FORTHRANDOM2 ( -- u )
  seed0                  \ put seed0 on stack
  seed1 to seed0         \ move value in seed1 to seed0
  dup 13 lshift xor      \ do three XORs of seed0
  dup 17 rshift xor      \ with shifted copies of itself
  dup 5 lshift xor
  dup seed1 xor to seed1 \ XOR the new random value with
  ;                      \ the old seed1 and update seed1
```

#### For 16 bit Forths:
The only change to the code are the 3 shift-factors. Here (7, 9, 13) are
used. You can also use (7, 9, 8).

```forth
2345 value SEED0
6789 value SEED1

: FORTHRANDOM16 ( -- u )  \ for 16b Forth
  seed0
  seed1 to seed0
  dup 7 lshift xor
  dup 9 rshift xor
  dup 13 lshift xor
  dup seed1 xor to seed1 ;
```

#### A few points to note:

There is no limit to the number of seeds. If you want to use a thousand
seeds, you can. The method functions fine with that. In that case it
would be more efficient to put the seeds in a table and read and write to
the table with two pointers. But it is hard to imagine a use-case where
there is a need for more than 256 bits of seeds, so for instance eight
32 bit seeds. This gives a wrap-to-zero period of 2^256-1. Even if
you generate  1 bilion values per second, the universe would cease to
exist before the generator wraps to the start.

It is good practise to pre-load the generator after re-seeding by
generating  dummy random numbers. For each seed you use, generate at
least 4 dummy numbers. So with 2 seeds 8 dummy numbers would be the
minimum. This pre-loading ensures that in all cases a good quality stream
of numbers is generated.

At least one seed must have one of the bits set for the generator to work.

#### Finally a handy word:

```forth
\ CHOOSE - limits the output of a random-generator to a range
         between 0 and u1 in a correct way.

: CHOOSE ( u1 - u2 ) random um* nip ;
```

### Links:

- Description of [DIEHARD](https://en.wikipedia.org/wiki/Diehard_tests) test
- George Marsaglia, “[XORShift Random Number Generators](https://www.jstatsoft.org/index.php/jss/article/view/v008i14/xorshift.pdf)”, Journal of Statistical Software 2003.
- [Chapter 70 of the Egel-project](https://home.hccnet.nl/willem.ouwerkerk/egel-for-msp430/egel%20for%20launchpad.html#e070)
shows some other random-generators and a grafical test based on DIEHARD to show the effect of low-quality generators.


