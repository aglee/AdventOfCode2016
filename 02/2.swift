import Foundation

let dirURL = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let fileURL = dirURL.appendingPathComponent("input.txt")  // "input.txt" or "test.txt"
let fileContents = try! String(contentsOf: fileURL)
let lines = fileContents.components(separatedBy: "\n")

struct Point {
	var x: Int
	var y: Int
	
	var digitString: String {
		return Point.digitString(x, y)
	}
	
	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}
	
	mutating func move(dir: String) {
		switch dir {
			case "U": if Point.digitString(x, y - 1) != "0" { y -= 1 }
			case "D": if Point.digitString(x, y + 1) != "0" { y += 1 }
			case "L": if Point.digitString(x - 1, y) != "0" { x -= 1 }
			case "R": if Point.digitString(x + 1, y) != "0" { x += 1 }
			default: fatalError("Unexpected direction string \(dir)")
		}
	}
	
	static let board = [
		"0000000",
		"0001000",
		"0023400",
		"0567890",
		"00ABC00",
		"000D000",
		"0000000"
	]

	static func digitString(_ x: Int, _ y: Int) -> String {
		if x < 0 || x > 6 || y < 0 || y > 6 {
			return "0"
		}
		return (board[y] as NSString).substring(with: NSRange(location: x, length: 1))
	}
}

func digit(line: String) -> String {
	var point = Point(1, 3)
	for ch in line.characters {
		point.move(dir: String(ch))
	}
	return point.digitString
}

for line in lines {
	print(digit(line: line))
}

