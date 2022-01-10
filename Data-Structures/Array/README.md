# Array                         

uh 2022-01-10

## Idea

Like a [Buffer](../Buffer/README.md) an array stores a sequence of entries (aka elements or items).

A buffer is characterized by its buffer-base-address and its size only and you can manage the buffer content as you like.
One popular way to manage a buffer is to number the items from 0 to the capacity-1 (where capacity is the number of items that
can be stored in the buffer) and use the addresse caculation

```
    entry-address = buffer-base-address + index * entry-size
```

to determine the address of each entry.

In an array you do essentially the same thing, only that the address calculation is hidden in the array notation instead of
explicitly done in the application. You pass the index to the array, it will do its address calculation and give the
item-address of the item requested.

As with buffers you need to allocate memory for arrays.

A typical way to accomplish this in Forth is to use *defining words* to encapsulate that behavior:

- the defining part allocates the appropriate memory of `capacity * entry-size` bytes. As you propably want to read and 
  write entries, the allocation takes place in RAM.
- the action part (does> part) does the address calculation.


### Implementation of Arrays

Let's assume without loss of generality that we want to store entries of cell size in the array. 

#### Pseudo code of an array and the read/write access t

    Function: ARRAY
        Define: ( u -- )
            Reserve u cells RAM space 
        Action: ( +n -- a )
            Leave cell address of cell +n in this structure by performing
            the address arithmetic  base-address + cell-size * +n .

    Create an array A with given capacity:
        «capacity» ARRAY A


    read i-th entry of array A:
        Read memory at «i» A 

    write value x to i-th entry of array A:
        wrtie memors at «i» A 
    
Please note that no range checking of the index i takes place so the application program has to assure that the index 
is within the limit of 0 to capacity-1.

ARRAY is sometime also called VARIABLES (e.g. see [PiliPlop])(../Algorthms/PiliPlop))


---

### Forth implementations


- **[Generic Forth]** implementation of ARRAY.

```forth
    \ array with cell sized entries in Generic Forth
    \ -----------------------------------------------------------------

    : ARRAY ( u -- ) \ for RAM only systems
        CREATE CELLS ALLOT \ RAM
      DOES> ( +n -- ) SWAP CELLS + ;

    \ sample applications

    32 CONSTANT capacity

    capacity ARRAY A

    42 4 A !    \ write value to item 4
       4 A @ .  \ read and print item 4
```

if you want to use array in a RAM/ROM system you would allocate the memory for the entries in RAM and the address to
RAM in ROM:

```forth
    \ array with cell sized entries in Generic Forth (RAM/ROM systems)
    \ -----------------------------------------------------------------

   : ARRAY ( u -- ) \ for RAM/ROM systems
        HERE SWAP CELLS ALLOT \ RAM
        CREATE ,              \ ROM
     DOES> @ SWAP CELLS + ;
```

Array a can be used as before.

[Generic Forth]: https://github.com/project-forth-works/project-forth-works.github.io/blob/main/minimalforth.md

