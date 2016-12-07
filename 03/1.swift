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
for line in lines {
	let triple = line.components(separatedBy: CharacterSet.whitespaces).filter({ !$0.isEmpty }).map({ Int($0)! })
	guard triple.count == 3 else { continue }
	//print(triple)
	if isTriangle(triple) {
		numTriangles += 1
	}
}
print(numTriangles)

