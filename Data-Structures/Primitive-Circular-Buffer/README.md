# Primitive Circular Buffer                         

uh 2021-12-11

## Idea

In a typical embedded application sensor readouts need to be stored in memory for processing. 
Because of memory limitations it might be reasonable to just store the latest data and remove old sensor readings. This can be done with a *Circular Buffer*. 

A **primitive circular buffer** is a general data structure that can hold a fixed number of entries. That fixed number is often called the *capacity* of the buffer and named *k*[^1].

[^1]: The use of the letter k is common in mathematics to name an integer parameter of fixed value.

Entries are stored one after the other in a primitive circular buffer typically based on their age: Oldest first, younger entries later. When the capacity k is reached the oldest value is overwritten by the youngest. So in the buffer you have access to the youngest k entries.

A more general (non-primitive) *circular buffer* allows to store a variable number of values (no value up to k values). Here, we discuss primitive circular buffers only.

### Implementation of Primitive Circular Buffers

The most simple implementation stores the capacity k along with a buffer of k entries. An index *idx* determines the location of the oldest entry which is also the place where the next entry will be stored.


```
       +------+------+------+------+------+-------+
       |      |      |      |      |      |       |
       |  k   | idx  | x_0  | x_1  |  …   | x_k-1 |
       |      |      |      |      |      |       |
       +------+------+------+------+------+-------+
Index                   0      1             k-1

```

This simple implementation has *only a single index* that identifies both, the location of the oldest value as well as the location where the newest value is to be stored. Because of this it always stores *exactly k* values. (More sophisticated implementations for general circular buffers manage a read and a write location and can store *from 0 up to k* values.)

When storing a new value it is written in the buffer at index position idx overwriting the old value that is stored there. After that idx is increased. If it exceeds the buffer capacity it restarts at 0. So the index runs around in circles given the circular buffer its name.

When reading values from the buffer, the oldest value can be accessed at index idx and the next k-1 entries (wrapping the index around at the buffer end i.e. index k-1) will be the oldest to latest entries.

Note, that the entries x_i have cell size. They can however be pointers to larger data structures such as arrays of sample data or floating point values.

#### Pseudo code of a single primitive circular buffer using global variables

    Create circular buffer:
      Define a variable idx and initialize it to 0.
      Allocate a variable circular-buffer with k cells of memory, called x_0 … x_k-1 
      here. Maybe erase x_0 … x_k-1 to zero if initialization is desired.

    Function: store-new-value ( x -- )
        Store x in circular buffer at index idx.
        Increment idx wrapping around at k-1. 

    Function: read-oldest-value ( -- x )
        Read x from buffer at index idx.
    
    Function: read-ith-oldest-value ( i -- x ) \ 0: oldest … k-1: youngest
        Read x from buffer at index (i+idx) wrapping around at k-1.

---

For comparison here is a pseudo code version, that used a more Forth like style:

#### Pseudo code of a single primitive circular buffer using global variables (Forth like)

    \ create circular buffer 
    «k» CONSTANT k
    VARIABLE idx  0 idx !
    CREATE circular-buffer  k CELLS ALLOT

    \ maybe erase x_0 … x_k-1 to zero if initialization is desired

    : store-new-value ( x -- )
        store x in circular buffer at index idx
        increment idx wrapping around at k-1 
    ;

    : read-oldest-value ( -- x )
        read x from buffer at index idx
    ;

    : read-ith-oldest-value ( i -- x ) \ 0: oldest … k-1: youngest
        read x from buffer at index (i+idx) wrapping around at k-1
    ;

---

#### Pseudo code of primitive circular buffer data structure identified by its address (Forth like)

    : create-new-primitive-circular-buffer ( k -- pcb-addr )
        allocate memory for k, idx and k entries x_0 to x_k-1
        initialize field k to k, idx to 0
        maybe erase x_0 … x_k-1 to zero if initialization is desired
        return address of allocated memory
    ;

    : store-new-value ( x pcb-addr -- )
        store x in the buffer at index idx
        increment idx wrapping around at k-1 
    ;

    : read-oldest-value ( pcb-addr -- x )
        read x from buffer at index idx
    ;

    : read-ith-oldest-value ( i pcb-addr -- x ) \ 0: oldest … k-1: youngest
        read x from buffer at index (i + idx) wrapping around at k-1
    ;


The Fields k and idx as well as the address of x_0 in the above structure can best be defined using the word `+FIELD` ([Forth-2012](https://forth-standard.org/standard/facility/PlusFIELD)).

---

### Forth implementations

The following implementations are provided:

- **[Generic Forth]** (a minimal Forth-94 and Forth-2012 subset) implementation of a single primitive circular buffer using global variables. This implementation assumes k to be a power of two so that the index wrap-around can be implemented by masking the bits of k-1.


```forth
    \ primitive circular buffer in Generic Forth

    \ -----------------------------------------------------------------
    \ Primitive Circular Buffer
    
    8 CONSTANT k  \ k must be a power of 2 so that wrapping can be done by masking
    VARIABLE idx  0 idx !
    HERE k CELLS ALLOT  CONSTANT circular-buffer

    circular-buffer  k CELLS  0 FILL

    : 'item ( -- addr ) 
        circular-buffer idx @ CELLS + ;

    : wrap-around ( u1 -- u2 )
        k 1 - AND 
    ;

    : store-new-value ( x -- )
        'item !
        idx @  1 + wrap-around  idx ! 
    ;

    : read-oldest-value ( -- x )
        'item @
    ;

    : read-ith-oldest-value ( i -- x ) \ 0: oldest … k-1: youngest
        idx @ + wrap-around  CELLS  circular-buffer +  @  
    ;
```

- **Forth-94** implementation of the primitive circular buffer data structure identified by its address  
   A portable Forth-94 implementation can be found in [primitive-circular-buffer-forth-94.fs](primitive-circular-buffer-forth-94.fs).

   This implementation uses a modulo k division to wrap around when the index reaches k-1. It also does address arithmetic every time the buffer is accessed.
   The implementation also includes tests using the test suite `ttester.fs`. If the system does not support ttester, the tests can be performed by hand.
   The allocation and access to the data structure is aware of systems that might provide read only (ROM) and read write (RAM) memory areas.

- **SwiftForth** implementation  
   Similar to the above Forth-94 implementation this makes use of the SwiftForth `package` mechanism to hide internal word.  
   [primitive-circular-buffer-SwiftForth.f](primitive-circular-buffer-SwiftForth.f).

- [**noForth**](noForth), specific implementation using the Generic Forth approach.  

More efficient definitions could do pointer arithmetic and compare address values to let the index wrap around. 
Also using addresses instead of an index would allow to avoid address calculation at every access.

More efficient implementations are welcome as contributions.

### (non-primitive) Circular Buffers (aka Cyclic Buffers, Ring Buffers)

More general implementations of circular buffers manage a read and a write index in order to store a variable amount (0 up to k) of values.

More information about circular buffers in general can be found at [Wikipedia's entry on Circular Buffers](https://en.wikipedia.org/wiki/Circular_buffer).

Some addtional implementation issues for two-pointer circular buffers are discussed in [Juho Snellman's Weblog](https://www.snellman.net/blog/archive/2016-12-13-ring-buffers/).

[Generic Forth]: https://github.com/project-forth-works/project-forth-works.github.io/blob/main/minimalforth.md

