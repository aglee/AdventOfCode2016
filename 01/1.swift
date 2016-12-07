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

struct Vector {
	private(set) var x: Int
	private(set) var y: Int
	var distance: Int {
		return abs(self.x) + abs(self.y)
	}
	
	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}
	
	mutating func move(bearing: Bearing, steps: Int) {
		self.x += bearing.x * steps
		self.y += bearing.y * steps
	}
}

var totalVector = Vector(0, 0)
var bearing = Bearing()
for move in moves {
	let move = move as NSString
	bearing.rotate(dir: move.substring(to: 1))
	let numSteps = Int(move.substring(from: 1))!
	totalVector.move(bearing: bearing, steps: numSteps)
	print("move = \(move), totalVector = (\(totalVector.x), \(totalVector.y)), distance = \(totalVector.distance)")
}

