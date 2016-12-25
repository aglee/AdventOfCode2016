import Foundation

func parseInput(fileName: String) -> [String] {
	let dirURL = URL(fileURLWithPath: "/Users/alee/_Developer/RC/AdventOfCode2016/24/Day24/Day24")
//	let dirURL = URL(fileURLWithPath: "/Users/alee/Day24/Day24")
	let fileURL = dirURL.appendingPathComponent(fileName)
	let fileContents = try! String(contentsOf: fileURL)

	return fileContents.components(separatedBy: "\n")
}

//func findDistance((lines: inputLines, startDigit: 0, goalDigit: 2) {
//	let m = Map(lines: inputLines, startDigit: 0, goalDigit: 2)
//}

let inputLines = parseInput(fileName: "input.txt")
let numDigits = Map(lines: inputLines, startDigit: 0, goalDigit: 0).numberOfDigits

for i in 0 ..< (numDigits - 1) {
	for j in (i + 1) ..< numDigits {
		let m = Map(lines: inputLines, startDigit: i, goalDigit: j)
		NSLog("START %d %d", i, j)
		let path = m.search(start: m.initialMapState())
		m.sanityCheckSearchResult(path)
		NSLog("END %d %d %d", i, j, path.count - 1)
		print("")
	}
}

//for state in path.reversed() {
//	print(state)
//}


