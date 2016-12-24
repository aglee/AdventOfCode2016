import Foundation

func parseInput(fileName: String) -> [String] {
	let dirURL = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
	let fileURL = dirURL.appendingPathComponent(fileName)
	let fileContents = try! String(contentsOf: fileURL)

	return fileContents.components(separatedBy: "\n")
}

typealias Point = (x: Int, y: Int)

class MapState: Hashable, CustomStringConvertible {
	let position: Point
	let digitsMask: Int  // Bitmask indicating which digits have been visited.
	var parentState: MapState?
	
	init(_ position: Point, _ digitsMask: Int) {
		self.position = position
		self.digitsMask = digitsMask
	}

	static func ==(lhs: MapState, rhs: MapState) -> Bool {
		return lhs.position == rhs.position && lhs.digitsMask == rhs.digitsMask
	}

	var hashValue: Int { return ((position.y ^ position.x) << 10) & digitsMask }
	
	var description: String { return "\(position) \(String(digitsMask, radix: 2))" }
}

class Map {
	private let kValueOfZero = UnicodeScalar("0").value

	let width: Int
	let height: Int
	private var rows: [[String]]
	private var digitLocations: [Int: Point]  // Maps digits to their locations on the Map.
	private var digitMap: [[Int]]  // -1 means no digit, 0-9 is the digit.
	private let desiredDigitsMask: Int!

	init(_ lines: [String]) {
		self.width = lines[0].characters.count
		self.height = lines.count
		self.rows = lines.map({ $0.characters.map({ String($0) }) })
		self.digitLocations = [:]
		self.digitMap = Array(repeating: Array(repeating: -1, count: self.width), count: self.height)

		for (y, row) in self.rows.enumerated() {
			for (x, ch) in row.enumerated() {
				if ch >= "0" && ch <= "9" {
					let digit = Int(UnicodeScalar(ch)!.value - kValueOfZero)
					if let _ = digitLocations[digit] {
						fatalError("Wasn't expecting the same digit twice (\(digit))")
					}
					digitLocations[digit] = (x, y)
					digitMap[y][x] = digit
				}
			}
		}
		
		self.desiredDigitsMask = (1 << digitLocations.count) - 1
		
		// Sanity check: make sure the digits we found on the map are sequential,
		// since we have logic elsewhere that assumes this.
		let maxDigit = digitLocations.keys.sorted().last!
		if maxDigit != digitLocations.count - 1 {
			fatalError("Digits aren't sequential: \(digitLocations.keys.sorted())")
		}
	}

	func initialMapState() -> MapState {
		return MapState(digitLocations[0]!, 0)
	}

	func isWall(_ x: Int, _ y: Int) -> Bool {
		return rows[y][x] == "#"
	}

	func isWall(_ point: Point) -> Bool {
		return isWall(point.x, point.y)
	}

	func dump() {
		print("width=\(width), height=\(height)")
		for row in rows {
			print(row.joined())
		}
		for d in digitLocations.keys.sorted() {
			print("\(d) is at \(digitLocations[d]!)")
		}
	}

	func solve() {
		var visited = Set<MapState>()
		var frontier = Set<MapState>([initialMapState()])
		while frontier.count > 0 {
			// Find all reachable neighbors of the current frontier,
			// and construct the next frontier.
			var newFrontier = Set<MapState>()
			for state in frontier {
				if state.digitsMask == desiredDigitsMask {
					print("GOOOOAL: state = \(state)")
					var st: MapState? = state
					while st != nil {
						print("\(st!)")
						st = st!.parentState
					}
					return
				}

				visited.insert(state)

				// Expand the frontier to include unvisited neighbors.
				for (dx, dy) in [(0, 1), (1, 0), (0, -1), (-1, 0)] {
					let neighborPoint = (x: state.position.x + dx, y: state.position.y + dy)
					if !isWall(neighborPoint) {
						var neighborDigitsMask = state.digitsMask
						let digitAtNeighborPoint = digitMap[neighborPoint.y][neighborPoint.x]
						if digitAtNeighborPoint >= 0 {
							neighborDigitsMask |= (1 << digitAtNeighborPoint)
						}
						let neighbor = MapState(neighborPoint, neighborDigitsMask)
						if !visited.contains(neighbor) {
							neighbor.parentState = state
							newFrontier.insert(neighbor)
						}
					}
				}
			}

			frontier = newFrontier
		}
		fatalError("Hey, we should have found a solution.")
	}
}

let inputLines = parseInput(fileName: "test.txt")
let m = Map(inputLines)
m.dump()
m.solve()








//
//
//// This is my final solution for Day 14, pulling things from previous
//// solutions (see the "Previous" directory) into this self-contained file.
//
//struct MazePoint: Hashable, CustomStringConvertible {
//	let x: Int
//	let y: Int
//
//	init(_ x: Int, _ y: Int) { (self.x, self.y) = (x, y) }
//
//	static func ==(lhs: MazePoint, rhs: MazePoint) -> Bool {
//		return lhs.x == rhs.x && lhs.y == rhs.y
//	}
//
//	var hashValue: Int { return x ^ y }
//
//	var description: String { return "\((x, y))" }
//}
//
//typealias PointSet = Set<MazePoint>
//
//enum SolutionCriterion {
//	case part1(goalSquare: MazePoint)
//	case part2(maxStepsWalked: Int)
//}
//
//struct Day14 {
//	let favoriteNumber: Int
//
//	func squareIsOpen(_ point: MazePoint) -> Bool {
//		let (x, y) = (point.x, point.y)
//		if x < 0 || y < 0 {
//			return false
//		}
//		let numBits = bitCount(x*x + 3*x + 2*x*y + y + y*y + favoriteNumber)
//		return numBits & 1 == 0
//	}
//
//	func bitCount(_ num: Int) -> Int {
//		var n = num
//		var bitCount = 0
//		while n != 0 {
//			if n & 1 != 0 {
//				bitCount += 1
//			}
//			n = n>>1
//		}
//		return bitCount
//	}
//
//	func solve(_ reasonToEnd: SolutionCriterion) {
//		var visited = PointSet()
//		var frontier = PointSet([MazePoint(1, 1)])
//		var stepsWalked = 0  // Number of steps we have taken from the start square.
//		while true {
//			// Find all reachable neighbors of the current frontier,
//			// and construct the next frontier.
//			var newFrontier = PointSet()
//			for point in frontier {
//				if case .part1(let goal) = reasonToEnd {
//					if point == goal {
//						print("PART 1: depth = \(stepsWalked)")
//						return
//					}
//				}
//
//				visited.insert(point)
//
//				// Expand the frontier to include unvisited neighbors.
//				for (dx, dy) in [(0, 1), (1, 0), (0, -1), (-1, 0)] {
//					let neighbor = MazePoint(point.x + dx, point.y + dy)
//					if !visited.contains(neighbor) && squareIsOpen(neighbor) {
//						newFrontier.insert(neighbor)
//					}
//				}
//			}
//
//			if case .part2(let maxStepsWalked) = reasonToEnd {
//				// If maxStepsWalked is 50, we want to go through this loop 51 times.
//				if stepsWalked == maxStepsWalked {
//					print("PART 2: visited \(visited.count) squares")
//					return
//				}
//			}
//
//			frontier = newFrontier
//			stepsWalked += 1
//		}
//	}
//}
//
////Day14(favoriteNumber: 10).solve(.part1(goalSquare: MazePoint(7, 4)))  // Should be 11.
//Day14(favoriteNumber: 1352).solve(.part1(goalSquare: MazePoint(31, 39)))
//Day14(favoriteNumber: 1352).solve(.part2(maxStepsWalked: 50))
//
