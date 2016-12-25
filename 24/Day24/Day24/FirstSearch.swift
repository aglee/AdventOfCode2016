import Foundation

typealias XYTuple = (x: Int, y: Int)

class MapState: Hashable, CustomStringConvertible {
	let position: XYTuple
	var depth = 0

	var gScore = Int.max
	var fScore = Int.max
	var parentState: MapState?

	init(_ position: XYTuple) {
		self.position = position
	}

	static func ==(lhs: MapState, rhs: MapState) -> Bool {
		return lhs.position.x == rhs.position.x && lhs.position.y == rhs.position.y
	}

	var hashValue: Int { return position.y ^ position.x }

	var description: String { return "\(position)" }
}

class Map: SimpleAStar<MapState> {
	typealias NodeType = MapState

	private let kValueOfZero = UnicodeScalar("0").value

	let width: Int
	let height: Int
	private var rows: [[String]]
	private var digitLocations: [Int: XYTuple]  // Maps digits to their locations on the Map.
	var numberOfDigits: Int { return digitLocations.count }
	private var digitMap: [[Int]]  // -1 means no digit, 0-9 is the digit.
	private let startDigit: Int
	private let goalDigit: Int

	init(lines: [String], startDigit: Int, goalDigit: Int) {
		self.width = lines[0].characters.count
		self.height = lines.count
		self.rows = lines.map({ $0.characters.map({ String($0) }) })
		self.digitLocations = [:]
		self.digitMap = Array(repeating: Array(repeating: -1, count: self.width), count: self.height)
		self.startDigit = startDigit
		self.goalDigit = goalDigit

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
		let sortedDigits = digitLocations.keys.sorted()
		let maxDigit = sortedDigits.last!
		if maxDigit != digitLocations.count - 1 {
			fatalError("Digits aren't sequential: \(sortedDigits)")
		}
	}

	func initialMapState() -> MapState {
		return MapState(digitLocations[startDigit]!)
	}

	func isWall(_ x: Int, _ y: Int) -> Bool {
		return rows[y][x] == "#"
	}

	func isWall(_ point: XYTuple) -> Bool {
		return isWall(point.x, point.y)
	}

	// MARK: - Debugging

	func dump() {
		print("width=\(width), height=\(height)")
		for row in rows {
			print(row.joined())
		}
		for d in digitLocations.keys.sorted() {
			print("\(d) is at \(digitLocations[d]!)")
		}
	}

	func sanityCheckSearchResult(_ path: [MapState]) {
		// Make sure the path starts at startDigit.
		if path.first!.position != digitLocations[startDigit]! {
			print("ERROR: path starts at \(path.first!), should start at \(digitLocations[startDigit]!)")
			return
		}

		// Make sure the path ends at goalDigit.
		if path.last!.position != digitLocations[goalDigit]! {
			print("ERROR: path starts at \(path.last!), should start at \(digitLocations[goalDigit]!)")
			return
		}

		// Make sure the path only moves on open spaces.
		for state in path {
			if isWall(state.position) {
				print("ERROR: there's a wall at \(state.position)")
				return
			}
		}

		// Make sure the path only moves by 1 square horizonally or vertically.
		for i in 0 ..< path.count - 1 {
			let fromPoint = path[i].position
			let toPoint = path[i + 1].position
			let dx = fromPoint.x - toPoint.x
			let dy = fromPoint.y - toPoint.y
			if dx*dx + dy*dy != 1 {
				print("ERROR: invalid move from \(fromPoint) to \(toPoint)")
				return
			}
		}

		print("passed sanity check")
	}

	// MARK: - AStarProtocol methods

	override func meetsGoal(_ state: MapState) -> Bool {
		return state.position == digitLocations[goalDigit]!
	}

	override func hScore(_ state: MapState) -> Int {
		let digPos = digitLocations[goalDigit]!
		return abs(digPos.x - state.position.x) + abs(digPos.y - state.position.y)
	}

	override func gScore(_ state: MapState) -> Int {
		return state.gScore
	}

	override func setGScore(_ state: MapState, _ score: Int) {
		state.gScore = score
	}

	override func fScore(_ state: MapState) -> Int {
		return state.fScore
	}

	override func setFScore(_ state: MapState, _ score: Int) {
		state.fScore = score
	}



	// To ensure object identity of MapState objects.
	private var stateCache: [MapState?]!
	private func getOrMakeMapState(_ x: Int, _ y: Int) -> MapState {
		if stateCache == nil {
			stateCache = Array(repeating: nil, count: width*height)
		}
		let arrayIndex = y*width + x
		if let state = stateCache[arrayIndex] {
			return state
		}
		let state = MapState((x, y))
		stateCache[arrayIndex] = state
		return state
	}

	override func neighbors(of state: MapState) -> [(MapState, Int)] {
		var neighbors: [(MapState, Int)] = []
		for (dx, dy) in [(0, 1), (1, 0), (0, -1), (-1, 0)] {
			let (neighborX, neighborY) = (state.position.x + dx, state.position.y + dy)
			if !isWall((neighborX, neighborY)) {
				let neighbor = getOrMakeMapState(neighborX, neighborY)
				neighbors.append((neighbor, 1))
			}
		}
		return neighbors
	}

	override func parent(of child: MapState) -> MapState? {
		return child.parentState
	}


	var MAX_DEPTH = 0
	override func setParent(of child: MapState, to parent: MapState) {
		child.parentState = parent
		child.depth = parent.depth + 1
		if child.depth > MAX_DEPTH {
			MAX_DEPTH = child.depth
//			if MAX_DEPTH % 20 == 0 {
//				NSLog("depth %d", MAX_DEPTH)
//			}
		}
	}
}




