import Foundation

let dirURL = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let fileURL = dirURL.appendingPathComponent("input.txt")  // "input.txt" or "test.txt"
let fileContents = try! String(contentsOf: fileURL)
let lines = fileContents.components(separatedBy: "\n")

struct Machine {
	let width: Int
	let height: Int
	var grid: [Bool]
	var litPixels: Int {
		return grid.filter({ $0 }).count
	}
	
	init(width: Int, height: Int) {
		self.width = width
		self.height = height
		grid = [Bool](repeating: false, count: width * height)
	}
	
	// MARK: - Pixel operations
	
	/** "rect AxB" */
	mutating func lightPixels(rectWidth: Int, rectHeight: Int) {
		for row in 0..<rectHeight {
			for col in 0..<rectWidth {
				self[row, col] = true
			}
		}
	}
	
	/** "rotate row y=A by B" */
	mutating func rotate(row: Int, by rotationCount: Int) {
		var tempCells = [Bool](repeating: false, count: width)
		for col in 0..<width {
			tempCells[(col+rotationCount) % width] = self[row, col]
		}
		for col in 0..<width {
			self[row, col] = tempCells[col]
		}
	}
	
	/** "rotate column x=A by B" */
	mutating func rotate(column col: Int, by rotationCount: Int) {
		var tempCells = [Bool](repeating: false, count: height)
		for row in 0..<height {
			tempCells[(row+rotationCount) % height] = self[row, col]
		}
		for row in 0..<height {
			self[row, col] = tempCells[row]
		}
	}
	
	/** Parse an input command and perform the specified operation. */
	mutating func doOperation(_ cmd: String) {
		let parts = cmd.components(separatedBy: " ")
		switch parts[0] {
			case "rect":
				// rect AxB
				let sides = parts[1].components(separatedBy: "x")
				lightPixels(rectWidth: Int(sides[0])!, rectHeight: Int(sides[1])!)
			case "rotate":
				// rotate row y=A by B
				// rotate column x=A by B
				let coord = Int(parts[2].components(separatedBy: "=").last!)!
				let rotationCount = Int(parts[4])!
				switch parts[1] {
					case "row": rotate(row: coord, by: rotationCount)
					case "column": rotate(column: coord, by: rotationCount)
					default: fatalError("Unexpected rotate command in '\(cmd)'")
				}
			default: fatalError("Unexpected command in '\(cmd)'")
		}
	}
	
	// MARK: - Debugging
	
	func dump() {
		for row in 0..<height {
			var rowString = ""
			for col in 0..<width {
				rowString += self[row, col] ? "#" : "."
			}
			print(rowString)
		}
	}
	
	// MARK: - Subscripting
	
	subscript(row: Int, column: Int) -> Bool {
		get {
			assert(indexIsValid(row: row, column: column), "Index out of range")
			return grid[(row * width) + column]
		}
		set {
			assert(indexIsValid(row: row, column: column), "Index out of range")
			grid[(row * width) + column] = newValue
		}
	}

	// MARK: - Private methods
		
	private func indexIsValid(row: Int, column: Int) -> Bool {
		return row >= 0 && row < height && column >= 0 && column < width
	}
}

var m = Machine(width: 50, height: 6)
for line in lines where !line.isEmpty {
//	print("after \(line):")

	m.doOperation(line)
	
//	m.dump()
//	print(m.litPixels)
}
m.dump()
print(m.litPixels)







