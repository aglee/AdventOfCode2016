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
	
	
	var DEPTH = 0
	
	
	init(_ position: Point, _ digitsMask: Int) {
		self.position = position
		self.digitsMask = digitsMask
	}

	static func ==(lhs: MapState, rhs: MapState) -> Bool {
		return lhs.position == rhs.position && lhs.digitsMask == rhs.digitsMask
	}

	var hashValue: Int { return ((position.y ^ position.x) << 10) & digitsMask }
	
	var description: String { return "\(position) \(String(digitsMask, radix: 2)) DEPTH=\(DEPTH)" }
}

class Map {
	private let kValueOfZero = UnicodeScalar("0").value

	let width: Int
	let height: Int
	private var rows: [[String]]
	private var digitLocations: [Int: Point]  // Maps digits to their locations on the Map.
	private var digitMap: [[Int]]  // -1 means no digit, 0-9 is the digit.
	var numberOfDigits: Int { return digitLocations.count }

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
		
		// Sanity check: make sure the digits we found on the map are sequential,
		// since we have logic elsewhere that assumes this.
		let maxDigit = digitLocations.keys.sorted().last!
		if maxDigit != digitLocations.count - 1 {
			fatalError("Digits aren't sequential: \(digitLocations.keys.sorted())")
		}
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

	func solve(startDigit: Int, goalDigit: Int) -> MapState {
		let desiredDigitsMask = 1<<goalDigit
	
		var visited = Set<MapState>()
		var frontier = Set<MapState>([MapState(digitLocations[startDigit]!, 0)])
		
		var MAX_DEPTH = 0
		
		while true {
			// Find all reachable neighbors of the current frontier,
			// and construct the next frontier.
			var newFrontier = Set<MapState>()
			for state in frontier {
				if state.digitsMask == desiredDigitsMask {
//					print("smallest number of steps from \(startDigit) to \(goalDigit) is \(state.DEPTH)")
//					var st: MapState? = state
//					while st != nil {
//						print("\(st!)")
//						st = st!.parentState
//					}
					return state
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
							neighbor.DEPTH = state.DEPTH + 1
							newFrontier.insert(neighbor)
						}
					}
				}
			}

			MAX_DEPTH += 1
//			if MAX_DEPTH % 5 == 0 {
//				NSLog("MAX_DEPTH %ld", MAX_DEPTH)
//			}
			frontier = newFrontier
			if frontier.count == 0 {
				fatalError("Hey, we should have found a solution.")
			}
		}
	}
}

let inputLines = parseInput(fileName: "input.txt")
var m = Map(inputLines)
for i in 0..<(m.numberOfDigits - 1) {
	for j in (i + 1)..<m.numberOfDigits {
		NSLog("START %d %d", i, j)
		let state = m.solve(startDigit: i, goalDigit: j)
		NSLog("END %d %d %d", i, j, state.DEPTH)
		print("")
	}
}



