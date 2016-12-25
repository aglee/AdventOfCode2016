# AStar

A* is a graph search algorithm used to find the shortest path from a start state to a goal state.  It is a variation of breadth-first search that uses a heuristic cost function to prioritize the nodes that are explored.


Terminology:

A node's **H score**, h(n), is a heuristic cost estimate

A node's **gScore**, g(n), is the cost of getting from the start node to that node.  The gScore is not a guess; it is the exact cost of the best path we have found at any given time.  At the beginning of our search we have not examined any nodes yet, so the gScore is Infinity for all nodes except the start node.  The start node's gScore is by definition zero.

A node's **fScore**, f(n), is the total estimated cost of getting from the start node to the goal node by passing through that node.  We use fScores to prioritize which nodes to search.  The node with the lowest fScore is in general the most likely to be on the optimal path from the start node to the goal node.

The fScore is partly known, partly heuristic.  

//
// For each node, we use the "cameFrom" dictionary to keep track of which node it can most efficiently be reached from.  This starts as a guess and is refined over time.
//
// The closed set is the set of nodes already evaluated.
//
// The frontier is the set of nodes we've found paths to but have not
// yet evaluated.



See also: Day 13.

"frontier" aka "open set" aka "fringe list"

closed set is the "interior" of the visited areas

References:

- <https://www.raywenderlich.com/4946/introduction-to-a-pathfinding>
- <https://en.wikipedia.org/wiki/A*_search_algorithm>
- <http://mnemstudio.org/path-finding-a-star.htm>


