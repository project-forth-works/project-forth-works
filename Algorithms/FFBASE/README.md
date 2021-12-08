# Temporary numeric BASE -- FFBASE

## The idea

Quite often a programmer needs to switch the numerical base for just a word or a number. In the worst case this involves saving the old BASE, setting BASE to the wanted value and than restoring the old BASE. A lot of code for just one word/definition. 

The routine FFBASE enables the creation of precursor words which, just for the next definition or number, temporarily set the base to another.

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
  		IF interpeting or ccc=immediate
  			{call (BASE) with XT and temp_base on stack}
  		IF not found in dictionary
  			{convert to number using temp_base and put on stack}
```

## Generic Forth

Definitions assumed to be available in your Forth:
	WORD, EVALUATE, COUNT


```generic Forth

See seperate file: FFBASE_comp.frt

```

## Implementations

The generic Forth version should run on the majority of Forth implementations. It is sucesfully tested on iForth and wabiForth. However it does not run on MeCrisp in the present form.
