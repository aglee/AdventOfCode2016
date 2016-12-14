import Foundation

// This is my final solution for Day 14, pulling things from previous
// solutions (see the "Previous" directory) into this self-contained file.

struct MazePoint: Hashable {
	let x: Int
	let y: Int

	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}

	// MARK: Equatable

	static func ==(lhs: MazePoint, rhs: MazePoint) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y
	}

	// MARK: - Hashable

	var hashValue: Int {
		return x ^ y
	}
}

typealias PointSet = Set<MazePoint>

enum SolutionCriterion {
	case part1(goalSquare: MazePoint)
	case part2(maxStepsWalked: Int)
}

struct Day14 {
	let favoriteNumber: Int

	func squareIsOpen(_ point: MazePoint) -> Bool {
		let (x, y) = (point.x, point.y)
		if x < 0 || y < 0 {
			return false
		}
		let numBits = bitCount(x*x + 3*x + 2*x*y + y + y*y + favoriteNumber)
		return numBits & 1 == 0
	}

	func bitCount(_ num: Int) -> Int {
		var n = num
		var bitCount = 0
		while n != 0 {
			if n & 1 != 0 {
				bitCount += 1
			}
			n = n>>1
		}
		return bitCount
	}

	func solve(_ reasonToEnd: SolutionCriterion) {
		var visited = PointSet()
		var frontier = PointSet([MazePoint(1, 1)])
		var stepsWalked = 0  // Number of steps we have taken from the start square.
		while true {
			// Find all reachable neighbors of the current frontier,
			// and construct the next frontier.
			var newFrontier = PointSet()
			for point in frontier {
				if case .part1(let goal) = reasonToEnd {
					if point == goal {
						print("PART 1: depth = \(stepsWalked)")
						return
					}
				}

				visited.insert(point)

				// Expand the frontier to include unvisited neighbors.
				for (dx, dy) in [(0, 1), (1, 0), (0, -1), (-1, 0)] {
					let neighbor = MazePoint(point.x + dx, point.y + dy)
					if !visited.contains(neighbor) && squareIsOpen(neighbor) {
						newFrontier.insert(neighbor)
					}
				}
			}

			if case .part2(let maxStepsWalked) = reasonToEnd {
				// If maxStepsWalked is 50, we want to go through this loop 51 times.
				if stepsWalked == maxStepsWalked {
					print("PART 2: visited \(visited.count) squares")
					return
				}
			}

			frontier = newFrontier
			stepsWalked += 1
		}
	}
}

//Day14(favoriteNumber: 10).solve(.part1(goalSquare: MazePoint(7, 4)))  // Should be 11.
Day14(favoriteNumber: 1352).solve(.part1(goalSquare: MazePoint(31, 39)))
Day14(favoriteNumber: 1352).solve(.part2(maxStepsWalked: 50))


// MARK: - Earlier solutions.

// Version1-UsingQueue
//solveSimpleMaze(width: 10, height: 7, fav: 10, targetX: 7, targetY: 4)

// Version2-UsingAStar
//solveUsingAStar(favoriteNumber: 1352, goal: Point(31, 39))  // Prints a nice emoji picture.

// Version3-UsingSetForFrontier
//solvePart1UsingSet()
//solvePart2UsingSet()


