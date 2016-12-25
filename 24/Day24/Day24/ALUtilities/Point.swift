import Foundation

class Point: Hashable, CustomStringConvertible {
	let x: Int
	let y: Int

	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}

	// MARK: - Adoption of various protocols

	var description: String { return "\((x, y))" }

	static func ==(lhs: Point, rhs: Point) -> Bool { return lhs.x == rhs.x && lhs.y == rhs.y }

	var hashValue: Int { return x ^ y }
}

