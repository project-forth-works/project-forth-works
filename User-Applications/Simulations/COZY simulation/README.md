

## COZY

This program is a simulation of agents which, if given the chance, move to a place where they feel more at home. In other words, to a place where they feel cozy. It is a very simple simulation but it has a suprising end-result: the end result looks like 4 bubbles. Even if 2 of these bubbles touch, the end result still looks correct.


The program functions as follows:

The central part of the program is a toroidal grid of 256x192 cells. Execution starts with completely and randomly filling the grid with 5 different agents, with 5 different colors.

Next an endless loop is started. In each loop the following is done:

	Select a random agent in the grid
		count the neighbours with the same color as the first agent
	Select a second random agent in the grid
		count the neighbours with the same color as the first agent 	
	Swap two agents on the grid if the number of same-coloured neigbours is 			higher at the location of the second agent than at the location of 			the first agent.

In other words: an agent moves to the alternative locations if there are more equals ajoining that location.
	
On a Raspberry Pi 3b+ the program perfoms around 0.5 milion loops per second. And at the start of the simuation the agents move rapidly. But nice bubble like shapes start appearing after 50-75 bilion loops. That takes 1-1.5 days on a Raspberry 3b+. Fortunately the Raspberry does not consume a lot of power.



[**COZY on YouTube**](https://www.youtube.com/watch?v=tQSjMcs5nKY)


![Bubble shaped end-result]![bubbles_PFW](https://user-images.githubusercontent.com/4964288/155993982-91e6fed1-5e4b-4cb5-b012-232f1d79a39a.jpg)


