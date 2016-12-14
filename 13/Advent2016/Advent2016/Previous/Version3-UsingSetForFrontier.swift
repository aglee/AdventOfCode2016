import Foundation

// This was my third pass, using a simple set to hold the frontier
// and expanding the frontier one level at a time.  I did Part 2
// first, then wondered if I could simply have used the same approach
// for Part 1 in the first place (the answer is yes).

func solvePart1UsingSet() {
	let maze = Maze(favoriteNumber: 1352)
	var visited = Set<Point>()
	var frontier = Set<Point>()
	frontier.insert(Point(1, 1))
	for depth in 0..<10000 {
		// Find all reachable neighbors of the current frontier,
		// and construct the next frontier.
		var newFrontier = Set<Point>()
		for point in frontier {
			if point.x == 31 && point.y == 39 {
				print("PART 1: depth = \(depth)")
				return
			}
			visited.insert(point)
			for neighbor in maze.neighbors(point) {
				if !visited.contains(neighbor) {
					newFrontier.insert(neighbor)
				}
			}
		}
		frontier = newFrontier
	}
	print("visited \(visited.count)")
}

func solvePart2UsingSet() {
	let maze = Maze(favoriteNumber: 1352)
	var visited = Set<Point>()
	var frontier = Set<Point>()
	frontier.insert(Point(1, 1))
	for _ in 0...50 {  // Note the closed range -- we want to loop 51 times.
		// Find all reachable neighbors of the current frontier,
		// and construct the next frontier.
		var newFrontier = Set<Point>()
		for point in frontier {
			visited.insert(point)
			for neighbor in maze.neighbors(point) {
				if !visited.contains(neighbor) {
					newFrontier.insert(neighbor)
				}
			}
		}
		frontier = newFrontier
	}
	print("PART 2: squares in path: \(visited.count)")
}

