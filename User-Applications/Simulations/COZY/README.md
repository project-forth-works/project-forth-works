

## COZY

This program is a simulation of agents which, if given the chance, move to a place where they feel more at home In other words, to a place with a more cozy atmosphere. It is a very simple simulation but it has a suprising end-result: the end result looks like 4 bubbles. And if 2 or 3 of these bubbles touch, they still look like bubbles would.


The program functions as follows:

The central part of the program is a toroidal grid of 256x192 cells. Execution starts with completely and randomly filling the grid with 5 different agents, with 5 different colors.

Next an endless loop is started. In each loop the following is done:

-	Select a random agent in the grid
		count the neighbours with the same color as the first agent
-	Select a second random agent in the grid
		count the neighbours with the same color as the first agent 	
-	Swap two agents on the grid if the number of same-coloured neigbours is 			higher at the location of the second agent than at the location of 			the first agent.

In other words: an agent moves to the alternative locations if there are more agents with the same color adjoining that location than the original location.

This version of the simulation always starts with a random agent. It is also possible to select the agents in a sequential order. But for this simulation that has en unnatural feeling to me.
	
On a Raspberry Pi 3b+ the program performs around 0.5 milion loops per second. At the start of the simuation the agents move rapidly. But than the speed of change slows down. Reaching the end result, more or less bubble like shapes, is stable after 50-75 bilion loops. That takes 1-1.5 days on a Raspberry 3b+. Fortunately the Raspberry does not consume a lot of power.



[**see COZY running on YouTube**]<a href="http://www.youtube.com/watch?feature=player_embedded&v=7b2-aXWt0z0
" target="_blank"><img src="http://img.youtube.com/vi/7b2-aXWt0z0/0.jpg" 
alt="IMAGE ALT TEXT HERE" width="600" height="450" border="10" /></a>






