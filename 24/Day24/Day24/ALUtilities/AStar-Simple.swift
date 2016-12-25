import Foundation

// Abstract base class that provides a default implementation for most of the
// AStarProtocol methods.  Subclasses must override meetsGoal(_:), hScore(_:),
// and neighbors(of:).
class SimpleAStar<NodeType: Hashable>: AStarProtocol {
	var gScores = AStarScoreLookup<NodeType>()
	var fScores = AStarScoreLookup<NodeType>()
	var parents: [NodeType: NodeType] = [:]
	var closedSet = Set<NodeType>()
	var frontier: AStarFrontier<NodeType>!

	init() {
		self.frontier = AStarFrontier<NodeType>(priorityBlock: { self.fScore($0) < self.fScore($1) })
	}

	func meetsGoal(_ node: NodeType) -> Bool {
		fatalError("Must implement the meetsGoal(_:) method")
	}

	func hScore(_ node: NodeType) -> Int {
		fatalError("Must implement the hScore(_:) method")
	}

	func gScore(_ node: NodeType) -> Int { return gScores[node] }
	func setGScore(_ node: NodeType, _ score: Int) { gScores[node] = score }
	func fScore(_ node: NodeType) -> Int { return fScores[node] }
	func setFScore(_ node: NodeType, _ score: Int) { fScores[node] = score }

	func neighbors(of node: NodeType) -> [(NodeType, Int)] {
		fatalError("Must implement the neighbors(of:) method")
	}

	func addToFrontier(_ node: NodeType) { frontier.add(node) }
	func popFromFrontier() -> NodeType? { return frontier.pop() }
	func frontierContains(_ node: NodeType) -> Bool { return frontier.contains(node) }

	func parent(of child: NodeType) -> NodeType? {
		return parents[child]
	}
	func setParent(of child: NodeType, to parent: NodeType) {
		parents[child] = parent
	}

	func addToClosedSet(_ node: NodeType) { closedSet.insert(node) }
	func closedSetContains(_ node: NodeType) -> Bool { return closedSet.contains(node) }
}

