import Foundation

let dirURL = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let fileURL = dirURL.appendingPathComponent("input.txt")  // "input.txt" or "test.txt"
let fileContents = try! String(contentsOf: fileURL)
let lines = fileContents.components(separatedBy: "\n")

struct Point {
	var x: Int
	var y: Int
	
	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}
	
	mutating func move(dir: String) {
		switch dir {
			case "U": if y > 0 { y -= 1 }
			case "D": if y < 2 { y += 1 }
			case "L": if x > 0 { x -= 1 }
			case "R": if x < 2 { x += 1 }
			default: fatalError("Unexpected direction string \(dir)")
		}
	}
	
	var digit: Int {
		return 3*y + x + 1
	}
}

func digit(line: String) -> Int {
	var point = Point(1, 1)
	for ch in line.characters {
		point.move(dir: String(ch))
	}
	return point.digit
}

for line in lines {
	print(digit(line: line))
}

