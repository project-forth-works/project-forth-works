

## Forest fire

This program simulates the way a forest fire develops after a lightning-strike, and it shows how the fires influence the structure of a forest. The idea is based on a publication by B. Drossel and F. Schwabl, Self-Organised critical forest-fire model, Physical Review Letters, Vol. 69, No. 11, September 1992.


The program functions as follows:

The central part of the program is a toroidal grid of 512x384 bytes. Execution starts with clearing the grid, corresponding to an area without trees.

Next an endless loop is started. In each loop the following is done:

	Select a random cell in the grid
	Check te content if that cell
	if the content is empty
		there is a change of 1:500 that a new tree is generated
	else
		if the content of the cell is a tree:
			check if any of the neighbours is a tree on fire
				if yes -> also go on fire
				if no -> a 1:1000000 change that 'lightning' causes fire
			raise the age of the tree with 1 (up to 255)
		else
			lower the age of a fire with 1 (until 0 is reached)
		then
	then
	update the screen for the tree or fire based on the age of the tree or 			fire
	next loop
	
The program is not very fast. Executing 10.000 loops takes between 8.5 and 10.5 ms. With a grid of 512x384 and the default settings it takes about 115 million loops) before a major forest-fire develops.

It is interesting to play around with the different settings of the program to see what happens. If you raise the chance of a lightning-strike you will see that there will be more fires, but never very big. If you raise the chance of a new tree growing there will be a high density of trees quickly, resulting in larger fires. It is also possible to raise the time it takes for a tree to catch fire from a neighbouring tree by changing the definition **(ONFIRE?)** or lowering the value **IGNITE**.


[**Forest fire on YouTube**](https://youtu.be/JNGmbZAHrhY)


![Waldbrand2](https://user-images.githubusercontent.com/4964288/153408550-665f2bef-2022-4393-87c9-7bdef45b0746.jpg)

