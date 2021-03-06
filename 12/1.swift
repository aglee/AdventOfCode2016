import Foundation

let dirURL = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let fileURL = dirURL.appendingPathComponent("input.txt")  // "input.txt" or "test.txt"
let fileContents = try! String(contentsOf: fileURL)
let lines = fileContents.components(separatedBy: "\n")

func run() {
	var registers = ["a": 0, "b": 0, "c": 0, "d": 0]
	registers["c"] = 1  // Comment this out to solve Part 1, add it back to solve Part 2.

	func value(_ term: String) -> Int {
		if let v = registers[term] {
			return v
		} else {
			return Int(term)!
		}
	}
	
	let instructions = lines.map({ $0.components(separatedBy: " ") })

	NSLog("START")
	var pc = 0
	var numCycles = 0
	while true {
		numCycles += 1
		if numCycles % 1000000 == 0 {
			NSLog("numCycles = %ld", numCycles)
		}
		let parts = instructions[pc]
		var jump = 1
		if parts[0] == "jnz" {
			if value(parts[1]) != 0 {
				jump = Int(parts[2])!
			}
		} else if parts[0] == "cpy" {
			registers[parts[2]] = value(parts[1])
		} else if parts[0] == "inc" {
			registers[parts[1]]! += 1
		} else if parts[0] == "dec" {
			registers[parts[1]]! -= 1
		} else {
			fatalError("Can't parse instruction '\(parts)")
		}
		pc += jump
		if pc >= instructions.count {
			break
		}
	}
	NSLog("DONE")
	print("registers: \(registers)")
}

run()



