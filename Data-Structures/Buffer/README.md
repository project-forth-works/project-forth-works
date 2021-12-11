# Buffer                         

uh 2021-12-11

## Idea

For storing data, applications use memory. Applications need to manage that memory:

- reserve (*allocate*) it for use, 
- identifying the appropriate parts of data and the locations in memory where to store that parts.

A **buffer** is a general data structure, that can hold a fixed number of *entries* (also called *elements*). 
That fixed number is often called the *capacity* of the buffer.

A buffer is located at some (named) *buffer-base-address* in memory and consists of 
contiguous memory space for the capacity entries. We assume here that all entries have a fixed size of *entry-size* bytes. The buffer thus occupies capacity * entry-size bytes.

Ultimately entries must be stored in memory at their particular *entry-address*.
The application however will deal with indices into the buffer that often run 
from 0 to capacity-1. So applications have to do the appropriate address calculation

```
    entry-address = buffer-base-address + index * entry-size
```

on their own.


### Implementation of Buffers

The most simple implementation just allocates the appropriate number of bytes in memory.



```
          (named)
       +- buffer-base-address      +------- entry-size (in bytes)
       |                           |
       V                     <------------>
       +------+------+------+--------------+
       |      |      |      |              |
   ... | x_0  | x_1  |  …   | x_capacity-1 | ...
       |      |      |      |              |
       +------+------+------+--------------+
Index     0      1             capacity-1

```

#### Pseudo code of a buffer and the read/write access to its entries

    Create a buffer with «capacity» entries of size «entry-size»:
      reserve «capacity» * «entry-size» bytes in memory, record its «buffer-base-address»

    Function: store-value ( value index buffer-base-address -- ) 
        Store «value» in the buffer at «index» by storing «value» in memory at 
           «buffer-base-address» + «index» * «entry-size»

    Function: read-value ( index buffer-base-address -- value )
        Fetch «value» from the buffer at «index» by reading memory at 
           «buffer-base-address» + «index» * «entry-size»

---

### Forth implementations


- **[Generic Forth]** implementation of a buffer.

```forth
    \ buffer in Generic Forth
    \ -----------------------------------------------------------------

    32 CONSTANT capacity
    1 CELL CONSTANT entry-size

    CREATE buf  capacity entry-size * ALLOT


    : store-value ( x i buffer-base-address )   SWAP entry-size * +  ! ;
 
    : read-value  ( x i buffer-base-address )   SWAP entry-size * +  @ ;


```
&nbsp;

- **Forth-200x** implementation of a buffer data structure 

  There is a Forth-200x standard word called `BUFFER: ( u <name> -- )` that allows to 
    to define buffers.  
    `BUFFER:` is a defining words that is used in the form
  ```
    «u» Buffer: «name» 
  ```
  where «u» is the size in bytes of the buffer to be allocated and «name» is the name of
  the new buffer.

  You can define `buffer:` in [Generic Forth] like this:

```
     \ For RAM-only systems
     : BUFFER: ( u <name> -- ) 
        CREATE ALLOT ;

     \ For RAM-only and for RAM/ROM systems
     : BUFFER: ( u <name> -- )
        HERE SWAP ALLOT  \ ram { b_0 | ... | b_u }
        CREATE ,         \ rom { 'ram }
        DOES> ( -- addr ) @ ;
```

[Generic Forth]: https://github.com/project-forth-works/project-forth-works.github.io/blob/main/minimalforth.md

