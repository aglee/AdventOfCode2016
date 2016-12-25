import Foundation

struct AStarFrontier<NodeType: Hashable> {
	var nodeHeap: Heap<NodeType>
	var nodeSet = Set<NodeType>()
	var count: Int { return nodeHeap.count }
	var top: NodeType? { return nodeHeap.top }

	init(priorityBlock: @escaping PriorityBlock<NodeType>) {
		self.nodeHeap = Heap<NodeType>(priorityBlock: priorityBlock)
	}

	mutating func add(_ node: NodeType) {
		nodeHeap.insert(node)
		nodeSet.insert(node)
	}

	mutating func pop() -> NodeType? {
		if let node = nodeHeap.pop() {
			nodeSet.remove(node)
			return node
		} else {
			return nil
		}
	}

	func contains(_ node: NodeType) -> Bool {
		return nodeSet.contains(node)
	}
}

