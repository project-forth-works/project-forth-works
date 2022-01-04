# I2C driver for 20x4 char LCD screen for Raspberry 3b+.

20x4 character LCDs are often sold with a piggy-backed I2C interface. In practise most of these LCD are the same: based on a cheap clone of a Hitachi-chip and almost all have the same features. Even when the spec-sheet says that there are no configurable characters, they usually are available anyhow.

There are a couple of things you need to be aware of:
1. characters, data and commands are send in two 4bit blocks. (see LCDemit as example)
2. The screen addresses are a bit unlogical (see LCDxy as example). Line 0 starts at 0, line 1 starts at 64, line 2 at 20 and line 3 at 84.
3. the backlite is controlled by a specific i/o-line which needs to be set/cleared at every command
4. the LCD display has a cursor which can be set/cleared
5. there usually are 64 bytes of RAM available and these are mostly used for 8 configurable characters. Defining a character is done with word LCDdefCHAR
6. The Raspberry has 3.3v on its GPIOs. If your LCD display needs 5v, than a level converter is needed.

	**`Do not put 5v on the GPIOs of the Raspberry!!`**
			
In the example a few wabiForth specific words are used for CPUtemp etc. Please use your own data or words when copying the example.


The non-standard word `CLIP` is used a lot. This is the definition:
```
: CLIP ( n l u ) rot min max ; \ limits n to within l and u, both inclusive
```


