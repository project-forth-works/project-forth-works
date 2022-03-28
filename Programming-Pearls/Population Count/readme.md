### Population Count

Population count, or **popcount**, is counting the number of set bits in a byte or word (or whatever your computer uses). It is also known as Hamming Weigth (see below for a link).
There is a surprisingly large range of algorithms where a popcount is usefull. For instance it is handy when handling interrupts, or when indexing used file blocks on a storage medium, or in cryptology. And chess-programs seem to use it in the valuation of a board. Anyhow, the common factor in most of these uses is that speed is essential and so most modern processors have an opcode for doing a popcount.

For processors which lack such an opcode, and for Forths implementations which lack a popcount primitive, here an algorithms to quickly get the count of set bits.

The following program is around 10* times faster than a simple counting routine using a loop. Working out how this short program works is a very interesting excercise and is left to the user. Lets not spoil all the fun!


##### Population Count - Forth routine
```hex
: popcount ( number -- no_of_bits_in_number )
	dup  1 rshift 55555555 and -
	dup  33333333 and
	swap 2 rshift 33333333 and +
	dup  4 rshift +
	f0f0f0f and
	1010101 *
	18 rshift
;
decimal
```

**Population count on Wikipedia:**
[Wikipedia - Hamming Weight](https://en.wikipedia.org/wiki/Hamming_weight) 

