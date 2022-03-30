### Random Generator Completeness Test

There are many different tests to assess the quality of a random-number generator. The Diehard suite of tests from Prof. G. Marsaglia was the first in wide-spread use, and a lot more tests have been developped since.
Presented here is a test for completeness.
Linear Pseudorandom Number Generators have an exact amount of numbers they generate before the return to their starting point (wrap around). A good generator generates all possible numbers exactly once before wrapping around. During the development of specific variants of such generators it is usefull to be able to do such a check.

The method used here is brute-force. It needs a decent CPU and at least 512 MB of continuous memory to run in a rasenable time. But a Raspberry Pi has enough memeory and is fast enough to run a check in reasonable time.

##### It functions thus:

```
	clear the 512 MB bit-array
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

##### Reporting the results:

The report is the only 'smart' part of this program. It does a popcount of each of the 134217728 32 bits numbers in the array. As a second step it shows an overview of the totals of each of the 33 possible populations counts.

The first report shows a 32 bit LPNG which is complete: there are 134217727 population bit counts with a value of 32, and 1 popcount with a value of 31. This is exactly as expected. These generators have a period of 2^32-1, the 0 is never generated; so there is 1 popcount with the value 31 and the rest with value 32.

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


To raise complexity of a random-generator, it is possible to multiply the output with a constant factor. For an example see the random generator of MeCrisp-quintus. You cannot just use any multiplication factor. The following table shows the effect of using a wrong multiplication factor. In this case the generator only generates 25% of the possible numbers (but these 4 times in a complete cycle). The factor used in the MeCrisp generator is obviously correct!
  
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
 
And this is how the popcounts look with a high quality 32 bit generator with a 256 bit domain ( **xoxhiro256** from D. Blackman and S. Vigna). The normal distribution can almost be felt...
 
 ```
   0=>           0  1=>           0  2=>           0
  3=>           0  4=>           0  5=>           6
  6=>          52  7=>         237  8=>        1406
  9=>        6292 10=>       24445 11=>       84668
 12=>      254086 13=>      672015 14=>     1567053
 15=>     3230909 16=>     5898377 17=>     9542529
 18=>    13661188 19=>    17303565 20=>    19326867
 21=>    18960579 22=>    16292092 23=>    12174977
 24=>     7844886 25=>     4313613 26=>     1994819
 27=>      763860 28=>      233027 29=>       55479
 30=>        9614 31=>        1031 32=>          56
 ```

##### Runtime and performance observations

The runtime on a Raspberry 3b+ with wabiForth for this check is around 24 minutes (and 5 sec to generate the report).
The limiting factor is not the speed of the CPU, but the speed of the memory-bus and cache. This routine is the most cache-**in**efficient routine possible. In >99,99% of cases setting a bit in the array requires the reading and writing of a complete 64 byte cache line. Setting a bit 4294967296 times takes a while...
The resulting memory bandwith is ~380 MB/s. Well under the 1100 MB/s available to wabiForth on a Raspberry pi 3+. But taking into account that the cache-system is stressed to the max for all aspects, this is respectable and leaves only little room for improvement.


