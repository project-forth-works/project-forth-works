# User-Applications

This is a bit of a curiosity. It is a high-level DO...+LOOP but with 2 limits, rather than 1. I have no clue what problem is solves, but it a nice solution!

A standard +LOOP uses the first number from the stack as the limit. For instance 0 10 DO ... -1 +LOOP uses the 0 as the limit to decide whether the loop is finished or not. In all cases where the step-factor in front of the +LOOP is a literal or a constant, this is always correct.
But the step-factor is allowed to change during a loop, it could even change sign. And in that specific case having 1 limit means that the loop continues a long time.

The DO...+LOOP presented here uses both of the two input numbers as limits, and continues the loop as long as the index is between the two limits. It does this by using WITHIN as test rather than testing for an overflow-bit.

For instance: 0 10 HDO ... n H+LOOP will loop as long as the index is between 0 (inclusive) and 10 (exclusive). In case the sign of the STEP stays the same troughout the loop, the loop functions exactly the same as +LOOP. IN case the sign of the STEP changes, the loop will end mucg sooner.

The implementation adds the words HDO, H+LOOP, HI, HJ and HLOOP. These can be used in the same way as standard DO...LOOP and DO...+LOOP. The loops can be nested and the index of the nested loop and the index of the outer loop are available as HI and HJ.

As stated in the beginning, I have no clue what problem is being solved by this curiosity, but it is a fine solution!
