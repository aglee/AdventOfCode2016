import Foundation

/*
This was my second attempt.
I looked up maze algorithms and found A*.
Fleshed out the pseudocode at <https://www.raywenderlich.com/4946/introduction-to-a-pathfinding>.
This worked, and ran in an instant, but was way more complicated than necessary.
A useful outcome was having better Point and Maze classes.

solveUsingAStar(favoriteNumber: 1352, goal: Point(31, 39))
*/

class Point: Hashable {
	let x: Int
	let y: Int

	// For each node, the total cost of getting from the start node to the goal
	// by passing by that node. That value is partly known, partly heuristic.
	var fScore = Int.max

	// For each node, the cost of getting from the start node to that node.
	var gScore = Int.max

	// For each node, which node it can most efficiently be reached from.
	// If a node can be reached from many nodes, cameFrom will eventually contain the
	// most efficient previous step.
	var cameFrom: Point?

	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}

	// MARK: Equatable

	static func ==(lhs: Point, rhs: Point) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y
	}

	// MARK: - Hashable

	var hashValue: Int {
		return x ^ y
	}
}

func heuristicCostEstimate(start: Point, goal: Point) -> Int {
	let dx = start.x > goal.x ? start.x - goal.x : goal.x - start.x
	let dy = start.y > goal.y ? start.y - goal.y : goal.y - start.y
	return dx + dy
}

struct Maze {
	let favoriteNumber: Int

	func hasWall(_ x: Int, _ y: Int) -> Bool {
		if x < 0 || y < 0 {
			return true
		}
		let numBits = (x*x + 3*x + 2*x*y + y + y*y + favoriteNumber).numBits
		return numBits & 1 == 1
	}

	func neighbors(_ point: Point) -> [Point] {
		var points: [Point] = []
		for (dx, dy) in [(0, 1), (1, 0), (0, -1), (-1, 0)] {
			if !hasWall(point.x + dx, point.y + dy) {
				points.append(Point(point.x + dx, point.y + dy))
			}
		}
		return points
	}
}

struct Frontier {
	var frontierHeap = Heap<Point>(priorityBlock: { $0.fScore < $1.fScore })
	var frontierSet = Set<Point>()

	var count: Int {
		return frontierHeap.count
	}

	var top: Point? {
		return frontierHeap.top
	}

	mutating func add(_ point: Point) {
		frontierHeap.insert(point)
		frontierSet.insert(point)
	}

	mutating func pop() -> Point? {
		if let point = frontierHeap.pop() {
			frontierSet.remove(point)
			return point
		} else {
			return nil
		}
	}

	func contains(_ point: Point) -> Bool {
		return frontierSet.contains(point)
	}
}

func reconstructPath(_ point: Point) -> [Point] {
	var points: [Point] = []
	var p: Point? = point
	while p != nil {
		points.append(p!)
		p = p!.cameFrom
	}
	return points
}

func solveUsingAStar(favoriteNumber: Int, goal: Point) {
	// See <https://en.wikipedia.org/wiki/A*_search_algorithm>.

	let start = Point(1, 1)
	//let maze = Maze(favoriteNumber: 10)
	//let goal = Point(7, 4)
	let maze = Maze(favoriteNumber: favoriteNumber)

	// The set of nodes already evaluated.
	var closedSet = Set<Point>()

	// The set of currently discovered nodes still to be evaluated.
	var frontier = Frontier()
	// Initially, only the start node is known.
	frontier.add(start)

	// The cost of going from start to start is zero.
	start.gScore = 0

	// For the first node, the fScore is completely heuristic.
	start.fScore = heuristicCostEstimate(start: start, goal: goal)

	while frontier.count > 0 {
		let current = frontier.pop()!  // the node in openSet having the lowest fScore[] value
		if current == goal {
			let solution = reconstructPath(current)
			var maxX = 0
			var maxY = 0
			for point in solution {
				if point.x > maxX {
					maxX = point.x
				}
				if point.y > maxY {
					maxY = point.y
				}
			}
			var oldMaze = SimpleMaze(width: maxX + 1, height: maxY + 1, fav: maze.favoriteNumber)
			for point in solution {
				oldMaze[point.x, point.y] = .mark
			}
			oldMaze.dump()
			print("HOORAY, answer is \(solution.count - 1)")
			return
		}

		//openSet.Remove(current)
		closedSet.insert(current)
		for neighbor in maze.neighbors(current) {
			if closedSet.contains(neighbor) {
				// Ignore the neighbor which is already evaluated.
				continue
			}

			// The distance from start to a neighbor.
			let tentativeGScore = current.gScore + 1  // 1 is the distance between(current, neighbor)
			if !frontier.contains(neighbor) {
				// Expand the frontier.
				frontier.add(neighbor)
			} else if tentativeGScore >= neighbor.gScore {
				// This is not a better path.
				continue
			}

			// This path is the best until now. Record it!
			neighbor.cameFrom = current
			neighbor.gScore = tentativeGScore
			neighbor.fScore = neighbor.gScore + heuristicCostEstimate(start: neighbor, goal: goal)
		}
	}
	print("Bummer, failed to find solution")
}



