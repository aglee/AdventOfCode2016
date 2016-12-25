import Foundation

// Implementation of search(start:) is provided in an extension.
protocol AStarProtocol {
	associatedtype NodeType: Hashable

	// The termination condition for the search.  The default implementation
	// simply checks whether the node == self.goal, which is the common case.
	// You can override this to specify a different criterion for success, as
	// long as it meets the requirements of the algorithm.
	func meetsGoal(_ node: NodeType) -> Bool

	// Heuristic cost function.  A measure of distance from goal.
	func hScore(_ node: NodeType) -> Int

	// These methods are for remembering G scores and F scores.  The scores
	// themselves are calculated by the algorithm using hScore.
	func gScore(_ node: NodeType) -> Int
	func setGScore(_ node: NodeType, _ score: Int)
	func fScore(_ node: NodeType) -> Int
	func setFScore(_ node: NodeType, _ score: Int)

	// Returns an array of (neighbor, distanceToNeighbor) pairs.
	func neighbors(of node: NodeType) -> [(NodeType, Int)]

	func addToFrontier(_ node: NodeType)
	func popFromFrontier() -> NodeType?
	func frontierContains(_ node: NodeType) -> Bool

	func addToClosedSet(_ node: NodeType)
	func closedSetContains(_ node: NodeType) -> Bool

	func parent(of child: NodeType) -> NodeType?
	func setParent(of child: NodeType, to parent: NodeType)
}

extension AStarProtocol {
	// The raison d'etre of this protocol.  Performs an A* search for the goal
	// node, starting from the given start node.  Returns the shortest path
	// found, from start to goal.
	//
	// An implementation of this method is provided in an extension.  Types that
	// adopt this protocol
	func search(start: NodeType) -> [NodeType] {
		// g(start) = 0.  The cost of going from any node to itself is zero.
		setGScore(start, 0)

		// f(start) = g(start) + h(start).  That's the definition of the fScore.
		setFScore(start, hScore(start))

		// The frontier is initially just the start node.
		addToFrontier(start)

		// Pop the frontier node with the best fScore and using it to
		// update the frontier.
		while let frontierNode = popFromFrontier() {
			// If frontierNode meets our goal, we're done.
			if meetsGoal(frontierNode) {
				return nodePath(backwardFrom: frontierNode).reversed()
			}

			// Remember not to re-add frontierNode to the frontier.
			addToClosedSet(frontierNode)

			// Use neighbors of frontierNode to update the frontier.
			for (neighborNode, distanceToNeighbor) in neighbors(of: frontierNode) {
				// Case 1: The neighbor was already examined as a frontier node;
				// skip it.
				if closedSetContains(neighborNode) {
					continue
				}

				// Case 2: The neighbor was never a frontier node; add it.
				if !frontierContains(neighborNode) {
					let neighborGScore = gScore(frontierNode) + distanceToNeighbor
					setGScore(neighborNode, neighborGScore)
					setFScore(neighborNode, neighborGScore + hScore(neighborNode))
					setParent(of: neighborNode, to: frontierNode)

					addToFrontier(neighborNode)
					continue
				}

				// Case 3: The neighbor is currently a frontier node waiting to
				// be examined; see if going to the neighbor via frontierNode
				// improves its gScore.
				let tentativeGScore = gScore(frontierNode) + distanceToNeighbor
				if tentativeGScore < gScore(neighborNode) {
					setGScore(neighborNode, tentativeGScore)
					setFScore(neighborNode, tentativeGScore + hScore(neighborNode))
					setParent(of: neighborNode, to: frontierNode)
				}
			}
		}

		// We ran out of nodes to explore without meeting our goal.
		return []
	}

	// Note: the path returned goes backwards from node to start.
	private func nodePath(backwardFrom node: NodeType) -> [NodeType] {
		var path: [NodeType] = []
		var n: NodeType? = node
		while n != nil {
			path.append(n!)
			n = parent(of: n!)
		}
		return path
	}
}

