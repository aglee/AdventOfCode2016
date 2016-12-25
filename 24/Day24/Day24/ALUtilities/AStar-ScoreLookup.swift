import Foundation

// Default score for any node is infinity until you specify otherwise.
struct AStarScoreLookup<NodeType: Hashable> {
	private var scores: [NodeType: Int] = [:]

	subscript(_ node: NodeType) -> Int {
		get {
			if let score = scores[node] {
				return score
			} else {
				return Int.max
			}
		}
		set {
			scores[node] = newValue
		}
	}
}


