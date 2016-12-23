import Foundation

func getInputLines(_ fileName: String) -> [String] {
	let dirURL = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
	let fileURL = dirURL.appendingPathComponent(fileName)  // "input.txt" or "test.txt"
	let fileContents = try! String(contentsOf: fileURL)
	return fileContents.components(separatedBy: "\n")
}

class Instruction: CustomStringConvertible {
	var op: String
	let arg1: String
	let arg2: String?
	
	init(_ lineOfCode: String) {
		let parts = lineOfCode.components(separatedBy: " ")
		self.op = parts[0]
		self.arg1 = parts[1]
		if parts.count == 3 {
			self.arg2 = parts[2]
		} else {
			self.arg2 = nil
		}
	}
	
	func hasCorrectArgTypes() -> Bool {
		switch op {
		case "cpy": return isReg(arg2!)
		case "inc": return isReg(arg1)
		case "dec": return isReg(arg1)
		case "jnz": return true
		case "tgl": return true
		default: fatalError("Invalid instruction: '\(op)'.")
		}
	}
	
	func toggle() {
		if arg2 == nil {
			op = (op == "inc" ? "dec" : "inc")  // One-argument instruction.
		} else {
			op = (op == "jnz" ? "cpy" : "jnz")  // Two-argument instruction.
		}
	}
	
	// MARK: - CustomStringConvertible
	
	var description: String {
		let argsOK = hasCorrectArgTypes() ? "OK" : "not OK"
		if let arg2 = arg2 {
			return "\(op) \(arg1) \(arg2) (args \(argsOK))"
		} else {
			return "\(op) \(arg1) (args \(argsOK))"
		}
	}
	
	// MARK: - Private
	
	private func isReg(_ term: String) -> Bool {
		return term == "a" || term == "b" || term == "c" || term == "d"
	}
	
	private func isNum(_ term: String) -> Bool {
		return Int(term) != nil
	}
}

struct Machine {
	private var registers = ["a": 0, "b": 0, "c": 0, "d": 0]
	private var instructions: [Instruction]
	private var pc = 0
	
	init(_ linesOfCode: [String]) {
		self.instructions = linesOfCode.map({ Instruction($0) })
	}
	
	mutating func setRegister(_ reg: String, _ value: Int) {
		registers[reg] = value
	}

	mutating func run() {
		pc = 0
		while true {
			var jump = 1
			let cmd = instructions[pc]
			if cmd.hasCorrectArgTypes() {
				jump = run(cmd)
			}
			pc += jump
			if pc >= instructions.count {
				break
			}
		}
		printRegisters()
	}
	
	func printRegisters() {
		print(registers.keys.sorted().map({ "\($0)=\(registers[$0]!)" }).joined(separator: ", "))
	}

	func printProgram() {
		for cmd in instructions {
			print(cmd)
		}
	}

	// Returns number of instructions to jump.
	private mutating func run(_ cmd: Instruction) -> Int {
		switch cmd.op {
		case "cpy": registers[cmd.arg2!] = value(cmd.arg1)
		case "inc": registers[cmd.arg1]! += 1
		case "dec": registers[cmd.arg1]! -= 1
		case "jnz":
			if value(cmd.arg1) != 0 {
				return value(cmd.arg2!)
			}
		case "tgl":
			let addr = pc + value(cmd.arg1)
			if addr >= 0 && addr < instructions.count {
				instructions[addr].toggle()
			}
		default: fatalError("Invalid instruction: '\(cmd.op)'.")
		}
		
		return 1
	}
	
	private func value(_ term: String) -> Int {
		if let v = Int(term) {
			return v
		} else if let v = registers[term] {
			return v
		} else {
			fatalError("'\(term)' doesn't seem to be a valid value specifier.")
		}
	}
}

NSLog("START")
var machine = Machine(getInputLines("input.txt"))
machine.setRegister("a", 7)  // Part 1.
//machine.setRegister("a", 12)  // Part 2.
machine.run()
NSLog("END")




