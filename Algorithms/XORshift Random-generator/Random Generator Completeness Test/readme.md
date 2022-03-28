### Random Generator Completeness Test

There are many different tests to test the quality of a random-number generator. The Diehard suite of tests from Prof. G. Marsaglia was the first in wide-spread use, and a lot more tests have been developped since.
One test is a test for completeness.
Linear Pseudorandom Number Generators have an exact amount of numbers they generate before the return to their starting point (wrap around). A good generator generates all possible numbers exactly once before wrapping around. During the development of specific variants of such generators it is usefull to be able to do such a check.

Presented here is a brute-force checking tool. It needs a decent CPU and at least 512 MB of continuous memory to run. But a Raspberry Pi is fast enough and has enough memory to run a check in reasonable time.

##### It functions thus:

```	clear the 512 MB bit-array
	reset the random generator under test
	4294967296 0 DO
		get a random number from generator under test
		set bit with generated number as index in the bit-array
	LOOP
	
	reset popcount array
	134217728 0 DO
		get next 32b value from array
		do a popcount of this number
		add 1 to the corresponding counter in the popcount array
	LOOP
	
	show the popcount array in a clear way
```	


This is the report generated. It shows how often each of the 33 possible populations counts where seen. Shown is a 32 bit LPNG which is complete.
There are 134217727 population bit counts with a value 32, and there is 1 popcount with a value of 31. Which is exactly what is expected as these generators have a period of 2^32-1, a 0 is never generated -> 1 popcount with the value 31 and the rest with value 32.

```
  0=>           0  1=>           0  2=>           0                                       
  3=>           0  4=>           0  5=>           0                                       
  6=>           0  7=>           0  8=>           0                                       
  9=>           0 10=>           0 11=>           0                                       
 12=>           0 13=>           0 14=>           0                                       
 15=>           0 16=>           0 17=>           0                                       
 18=>           0 19=>           0 20=>           0                                       
 21=>           0 22=>           0 23=>           0                                       
 24=>           0 25=>           0 26=>           0                                       
 27=>           0 28=>           0 29=>           0                                       
 30=>           0 31=>           1 32=>   134217727
 ```


To raise complexity of a random-generator, it is possible to multiply the output with a constant factor. For an example see the random generator ofr MeCrisp-quintus. The multiplication factor is critical. The following table shows the effect of using a wrong multiplication factor. The generator only generates 25% of the possible numbers (but these 4 times in a complete cycle). It is clear that the factor used in the MeCrisp is obviously correct!
  
```
  0=>           0  1=>           0  2=>           0
  3=>           0  4=>           0  5=>           0
  6=>           0  7=>           0  8=>   134217728
  9=>           0 10=>           0 11=>           0
 12=>           0 13=>           0 14=>           0
 15=>           0 16=>           0 17=>           0
 18=>           0 19=>           0 20=>           0
 21=>           0 22=>           0 23=>           0
 24=>           0 25=>           0 26=>           0
 27=>           0 28=>           0 29=>           0
 30=>           0 31=>           0 32=>           0
 ```  

##### Runtime and performance observations

The runtime on a Raspberry 3b+ with wabiForth for this check is ~24 minutes (and 5 sec to generate the report).
The limiting factor is in fact not the speed of the CPU but the speed of the memory-bus and cache. This routine is the most cache-**in**efficient possible. In >99,99% of cases setting a bit in the array requires the reading and writing of a complete 64 byte cache line. And a bit is set 4294967296 times. That takes a while...
The resulting memory bandwith is ~380 MB/s. Well under the 1100 MB/s available to wabiForth on a Raspberry pi 3+. But taking into account that the cache-system is stressed to the max for all aspects, this is respectable and leaves only little room for improvement.


