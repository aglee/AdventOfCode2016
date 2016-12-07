import Foundation

let dirURL = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let fileURL = dirURL.appendingPathComponent("input.txt")  // "input.txt" or "test.txt"
let fileContents = try! String(contentsOf: fileURL)
let lines = fileContents.components(separatedBy: "\n")

func isTriangle(_ triple: [Int]) -> Bool {
	if triple[0] >= triple[1] + triple[2] {
		return false
	}
	if triple[1] >= triple[0] + triple[2] {
		return false
	}
	if triple[2] >= triple[0] + triple[1] {
		return false
	}
	
	return true
}

var numTriangles = 0
let triples = lines.map({
	$0.components(separatedBy: CharacterSet.whitespaces)
		.filter({ !$0.isEmpty })
		.map({ Int($0)! })
}).filter({ !$0.isEmpty })

for row in stride(from: 0, to: triples.count, by: 3) {
	for col in 0...2 {
		if isTriangle([triples[row][col], triples[row+1][col], triples[row+2][col]]) {
			numTriangles += 1
		}
	}
}

print(numTriangles)

