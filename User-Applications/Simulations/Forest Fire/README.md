

## Forest fire

This program simulates the way a forest fire develops after a lightning-strike. The idea is based on a publication by B. Drossel and F. Schwabl, Self-organized critical forest-fire model, Physical Review Letters, Vol. 69, No. 11, September 1992.

The program functions as follows:

The program starts with clearing a grid of 512x384 bytes, corresponding to an area without trees.

Than the program starts executing an endless loop. In each loop the following is done:

	Select a random cell in the grid
	Check te content if that cell
	if the content is empty
		there is a change of 1:500 that a new tree is generated -> next loop
	else
		if the content of the cell is a tree:
			check if any of the neighbors is a tree on fire
				if yes -> also go on fire -> next loop
				if no -> a 1:100000 change that 'lightning' causes fire
			raise the age of the tree with 1 (upto 255)
		else
			lower the age of a fire with 1 (until 0 is reached)
		then
	then
	update the screen for the tree or fire based on the age of the tree or 			fire
	next loop
	
The program is not very fast. Executing 10.000 loops takes around 7.4 ms. With a grid of 512x384 and the default settings it takes about 1 minute (~80 milion loops) before a major forest-fire develops.

[**Forest fire on YouTube**](https://youtu.be/JNGmbZAHrhY)

![Forest fire](https://user-images.githubusercontent.com/11397265/153283094-db5d024c-45ec-4c4a-891d-a9860b052ef2.jpg)

