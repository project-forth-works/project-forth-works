#### Marsaglia's XORshift routine on the ARM processor

#### Raspberry Pi 3b+ with wabiForth

The Forth version of the randomisation routines is the same on any processor as only standard Forth words are used. But the ARM-processor can do do a neat
trick: it can do q cycle (dup, shift and xor) in 1 opcode!! And as
most Forths include an assembler it is an interesting exercise to see how
much faster the routine is when coded in assembly.
This example is coded using wabiForth on a Raspberry 3b+, but the principle is the same for any ARMv8 Aarch32 processor.

The routine uses two registers named top and w. Top contains the top of the stack, w is a scratch register.


## XORshift in ARM Aarch32 assembly -
```
variable seed
2345 seed !

code: ASMRANDOM ( address_seed -- rndm_val )
  [ w, top, ldr,       \ get value in seed in w
  
  w, w, w, 13 lsl#, eor,
  w, w, w, 17 lsr#, eor,
  w, w, w,  5 lsl#, eor,
  
  w, top, str,         \ save new value in seed
  top, w, mov,
  
  ] ; 6 inlinable
```

### Comparison of Forth vs assembly

Tested with wabiForth on Raspberry 3b+ @ 1.5 GHz  
Here some simple benchmarks which compare the 1 and 2 seed
versions coded in Forth and the 1 seed version in assembly. Just
to get an idea about execution-speeds. 

    ---------------------------
    1 seed 32bit Forth:     40c
    2 seed 32bit Forth:     60c
    1 seed 32bit assembly:  10c
    ---------------------------


Time measured is the number of CPU-cycles required to put a
random number on the stack with a given method. The routine in assembly
is 4 times as fast as the corresponding routine in Forth. Which is a
nice speed-up of the routine.  
