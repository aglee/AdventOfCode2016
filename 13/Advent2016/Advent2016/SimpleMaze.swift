import Foundation

enum Cell: String {
	case space = "."
	case wall = "#"
	case mark = "O"
}

struct SimpleMaze {
	let width: Int
	let height: Int
	let favoriteNumber: Int
	var grid: [[Cell]]

	init(width: Int, height: Int, fav: Int) {
		self.width = width
		self.height = height
		self.favoriteNumber = fav
		self.grid = Array(repeating: Array(repeating: .space, count: width), count: height)

		setUpWalls()
	}

	func dump() {
		for y in 0..<height {
			print(grid[y].map({ $0.rawValue }).joined(separator: " "))
		}
		print("")
	}

	subscript(_ x: Int, _ y: Int) -> Cell {
		get {
			if coordsAreValid(x: x, y: y) {
				return grid[y][x]
			} else {
				return .wall
			}
		}
		set {
			assert(coordsAreValid(x: x, y: y), "Coords \((x, y)) are out of bounds")
			assert(grid[y][x] != .wall, "Attempt to replace a wall at \((x, y))")
			grid[y][x] = newValue
		}
	}

	private func coordsAreValid(x: Int, y: Int) -> Bool {
		return x >= 0 && x < width && y >= 0 && y < height
	}

	private mutating func setUpWalls() {
		for x in 0..<width {
			for y in 0..<height {
				let numBits = (x*x + 3*x + 2*x*y + y + y*y + favoriteNumber).numBits
				if numBits & 1 == 1 {
					self[x, y] = .wall
				}
			}
		}
	}
}

class SearchPoint {
	let x: Int
	let y: Int
	var prev: SearchPoint?

	var depth: Int {
		var d = 0
		var p: SearchPoint? = self.prev
		while p != nil {
			d += 1
			p = p!.prev
		}
		return d
	}

	init(_ x: Int, _ y: Int, _ prev: SearchPoint? = nil) {
		self.x = x
		self.y = y
		self.prev = prev
	}
}

func solveSimpleMaze(width: Int, height: Int, fav: Int, targetX: Int, targetY: Int) {
	var maze = SimpleMaze(width: width, height: height, fav: fav)
	maze.dump()

	var queue = Queue<SearchPoint>()
	queue.push(SearchPoint(1, 1))
	while queue.count > 0 {
		let point = queue.pop()!
		if point.x == targetX && point.y == targetY {
			print("Mission accomplished, steps = \(point.depth)")
			print("")
			var p: SearchPoint? = point
			while p != nil {
				maze[p!.x, p!.y] = .mark
				p = p!.prev
			}
			break
		}
		for (dx, dy) in [(0, -1), (1, 0), (0, 1), (-1, 0)] {
			if maze[point.x + dx, point.y + dy] != .wall {
				queue.push(SearchPoint(point.x + dx, point.y + dy, point))
				if queue.count % 100000 == 0 {
					print("queue \(queue.count)")
				}
			}
		}
	}
	maze.dump()
}



//var m = Maze(width: 40, height: 50, fav: 1352)
//m[31, 39] = .mark
//m.dump()

//solveSimpleMaze(width: 10, height: 7, fav: 10, targetX: 7, targetY: 4)
//solveSimpleMaze(width: 40, height: 50, fav: 1352, targetX: 31, targetY: 39)



