import Foundation

let dirURL = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let fileURL = dirURL.appendingPathComponent("input.txt")  // "input.txt" or "test.txt"
let fileContents = try! String(contentsOf: fileURL)
let lines = fileContents.components(separatedBy: "\n")

var registers = ["a": 0, "b": 0, "c": 0, "d": 0]
let instructions = lines.map({ $0.components(separatedBy: " ") })

func value(_ term: String) -> Int {
	if let v = registers[term] {
		return v
	} else {
		return Int(term)!
	}
}

var pc = 0
func perform(_ parts: [String]) {
	var jump = 1
	switch parts[0] {
		case "cpy":
			registers[parts[2]]! = value(parts[1])
		case "inc":
			registers[parts[1]]! += 1
		case "dec":
			registers[parts[1]]! -= 1
		case "jnz":
			if value(parts[1]) != 0 {
				jump = value(parts[2])
			}
		default: fatalError("Can't parse instruction '\(instructions[pc])")
	}
	pc += jump
}

NSLog("START")
registers["c"] = 1  // Comment this out to solve Part 1, add it back to solve Part 2.
var numCycles = 0
while true {
	numCycles += 1
	if numCycles % 1000000 == 0 {
		NSLog("numCycles = %ld", numCycles)
	}
	perform(instructions[pc])
	if pc >= instructions.count {
		break
	}
}
NSLog("DONE")
print("registers: \(registers)")

