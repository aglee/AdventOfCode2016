import Foundation

let dirURL = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let fileURL = dirURL.appendingPathComponent("input.txt")  // "input.txt" or "test.txt"
let fileContents = try! String(contentsOf: fileURL)
let moves = fileContents.components(separatedBy: ", ")

struct Bearing {
	private(set) var x: Int
	private(set) var y: Int
	
	init() {
		// Bearing is initially North by default.
		self.x = 0
		self.y = 1
	}
	
	mutating func rotate(dir: String) {
		switch dir {
			case "R": (self.x, self.y) = (self.y, -self.x)
			case "L": (self.x, self.y) = (-self.y, self.x)
			default: fatalError("expected R or L, got \(dir)")
		}
	}
}

struct Vector: Hashable, Equatable {
	let x: Int
	let y: Int
	var distance: Int {
		return abs(self.x) + abs(self.y)
	}
	
	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}
	
	func locationsAlongMove(bearing: Bearing, steps: Int) -> [Vector] {
		var locations: [Vector] = []
		for count in 1...steps {
			locations.append(Vector(self.x + bearing.x * count, self.y + bearing.y * count))
		}
		return locations
	}
	
	var hashValue: Int {
		return self.x.hashValue ^ self.y.hashValue
	}

	static func ==(lhs: Vector, rhs: Vector) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y
	}
}

var totalVector = Vector(0, 0)
var bearing = Bearing()
var visited = Set<Vector>()

visited.insert(totalVector)

foo:
for move in moves {
	let move = move as NSString
	bearing.rotate(dir: move.substring(to: 1))
	let numSteps = Int(move.substring(from: 1))!
	let locations = totalVector.locationsAlongMove(bearing: bearing, steps: numSteps)
	
	for location in locations {
		if visited.contains(location) {
			print("AHA: We've been here before -- \(location.x), \(location.y), \(location.distance)")
			break foo
		}
		visited.insert(location)
	}
	
	totalVector = locations.last!
}

