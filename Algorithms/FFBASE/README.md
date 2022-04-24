# Temporary numeric BASE -- FFBASE

## The idea

Quite often a programmer needs to switch the numerical base for just a word or a number. In the worst case this involves saving the old BASE, setting BASE to the wanted value and then restoring the old BASE. A lot of code for just one word/definition. 

The routine FFBASE enables the creation of precursor words which, just for the next definition or number, temporarily set the base to another.

So, for instance:
```forth
	16 FFBASE HX
```
Creates a word, called `HX. `HX` will set the numeric base to 16, but ONLY for the word following it. It deals correctly with definitions being compiled, definitions being executed and values.

The name `FFBASE`, by the way, come from the Dutch word 'even'. It means 'for a short while'. This in colloquial language is pronounced 'effen', which is also the plural of 'F'. So `FFBASE` in Dutch is pronounced 'EffenBase' and it gives a different numeric base for a very short while.  

It should be mentioned that in this phrase `: .hex  hx . ;`  `BASE` is set to hex while `.` (dot) is compiled! So this `HX` has no effect.  


## Pseudo code
```
Function: (BASE) ( XT temporary_base -- )
  execute an XT using a temporary base - used by FFBASE
  
Function: FFBASE
  CREATE: ( base ccc -- ) create a precursor word 'ccc' with 'base'
  DOES>: ( ccc -- )
  		{get base from definition} 
  		{find ccc in dictionary}
  		{get state}
  		IF compiling and ccc=not_immediate
  			{compile XT and temp_base as literals and postpone (BASE)
  		IF interpreting or ccc=immediate
  			{call (BASE) with XT and temp_base on stack}
  		IF not found in dictionary
  			{convert to number using temp_base and put on stack}
```

## Generic Forth

Definitions assumed to be available in your Forth: `WORD`, `EVALUATE`, `COUNT`

****generic Forth****

See separate file: [FFBASE_comp.frt](FFBASE_comp.frt)


## Implementations

The generic Forth version should run on the majority of Forth implementations. It is successfully tested on iForth and wabiForth. However in the present form it does not run on MeCrisp for reasons unknown to me.
