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
	
	func getRegister(_ reg: String) -> Int {
		return registers[reg]!
	}
	
	mutating func setRegister(_ reg: String, _ value: Int) {
		registers[reg] = value
	}
	
	mutating func run() {
		pc = 0
		while pc < instructions.count {
			if shouldMultiply() {
				multiply()
			} else {
				// Normal flow.
				let cmd = instructions[pc]
				if cmd.hasCorrectArgTypes() {
					execute(cmd)
				} else {
					pc += 1
				}
			}			
		}
	}
	
	func printRegisters() {
		print(registers.keys.sorted().map({ "\($0)=\(registers[$0]!)" }).joined(separator: ", "))
	}

	func printProgram() {
		for (i, cmd) in instructions.enumerated() {
			let s = NSString(format: "%2d", i)
			print("\(s) \(cmd)")
		}
	}

	// Hand-optimize this sequence of instructions, which sets a = a*b and clears c and d.
	//	cpy a d
	//	cpy 0 a
	//	cpy b c
	//	inc a
	//	dec c
	//	jnz c -2
	//	dec d
	//	jnz d -5
	private mutating func multiply() {
		let product = registers["a"]! * registers["b"]!
//		print("[multiply] a=\(registers["a"]!), b=\(registers["b"]!), assigning \(product) to a")
		registers["a"] = product
		registers["c"] = 0
		registers["d"] = 0
		pc += 8
	}
	
	// Good enough sanity check of whether we're using the "real" Day 23 input
	// (at least *my* Day 23 input) *and* none of the relevant instructions
	// has been modified by a "tgl" instruction.
	private func shouldMultiply() -> Bool {
		if pc != 2 || instructions.count < 10 {
			return false
		}
		
		let block = instructions[pc..<pc+8]
		let ops = block.map({ $0.op })
		if ops != ["cpy", "cpy", "cpy", "inc", "dec", "jnz", "dec", "jnz"] {
			return false
		}
		
		return true
	}

	private mutating func execute(_ cmd: Instruction) {
		var jump = 1

		switch cmd.op {
		case "cpy": registers[cmd.arg2!] = value(cmd.arg1)
		case "inc": registers[cmd.arg1]! += 1
		case "dec": registers[cmd.arg1]! -= 1
		case "jnz":
			if value(cmd.arg1) != 0 {
				jump = value(cmd.arg2!)
			}
		case "tgl": toggle(pc + value(cmd.arg1))
		default: fatalError("Invalid instruction: '\(cmd.op)'.")
		}
		
		pc += jump
	}
	
	private func toggle(_ addr: Int) {
		if addr < 0 || addr >= instructions.count {
			return
		}
		
		let cmd = instructions[addr]
		let newOp: String
		if cmd.arg2 == nil {
			newOp = (cmd.op == "inc" ? "dec" : "inc")  // One-argument instruction.
		} else {
			newOp = (cmd.op == "jnz" ? "cpy" : "jnz")  // Two-argument instruction.
		}
//		print("[toggle] instruction \(addr), \(cmd.op) => \(newOp)")
		cmd.op = newOp
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

func solve(_ desc: String, _ a: Int) {
	var machine = Machine(getInputLines("input.txt"))
	machine.setRegister("a", a)
	NSLog("START %@", desc)
	machine.run()
	NSLog("END %@ -- register 'a' contains %ld", desc, machine.getRegister("a"))
}

solve("Part 1", 7)
print("")
solve("Part 2", 12)

