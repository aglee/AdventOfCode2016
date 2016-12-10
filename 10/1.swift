import Foundation

let dirURL = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let fileURL = dirURL.appendingPathComponent("input.txt")  // "input.txt" or "test.txt"
let fileContents = try! String(contentsOf: fileURL)
let lines = fileContents.components(separatedBy: "\n")

class ValueHolder {
	let idNum: Int
	
	required init(idNum: Int) {
		self.idNum = idNum
	}
	
	func receiveValue(_ value: Int) {
		fatalError("Must override receiveValue")
	}
}

class OutputBin: ValueHolder, CustomStringConvertible {
	var value: Int?

	var description: String {
		return "<\(type(of: self)) id=\(idNum) value=\(value)>"
	}

	override func receiveValue(_ value: Int) {
		self.value = value
	}
}

class Bot: ValueHolder, CustomStringConvertible {
	var values: [Int] = []
	var lowDest: ValueHolder?
	var highDest: ValueHolder?
	private var didFire = false
	
	var description: String {
		return "<\(type(of: self)) id=\(idNum) values=\(values.sorted())>"
	}

	func fireIfReady() -> Bool {
		if values.count == 2 && lowDest != nil && highDest != nil && !didFire {
			let (low, high) = (min(values[0], values[1]), max(values[0], values[1]))
			lowDest!.receiveValue(low)
			highDest!.receiveValue(high)
			didFire = true
			return true
		} else {
			return false
		}
	}
	
	override func receiveValue(_ value: Int) {
		if values.count >= 2 {
			fatalError("Attempt to give bot \(idNum) more than 2 values.")
		}
		values.append(value)
		
		if Set(values) == Set([17, 61]) {
			print("bot \(idNum) is the answer to Part 1")
		}
	}
}

struct Lookup<T: ValueHolder> {
	private var valueHolders: [Int: T] = [:]
	var all: [T] {
		return Array(valueHolders.values)
	}
	
	mutating func get(idNum: Int) -> T {
		if let vh = valueHolders[idNum] {
			return vh
		} else {
			let vh = T(idNum: idNum)
			valueHolders[idNum] = vh
			return vh
		}
	}
	
	func dump() {
		for vh in valueHolders.values.sorted(by: { $0.idNum < $1.idNum }) {
			print(vh)
		}
	}
}

var outputBins = Lookup<OutputBin>()
var bots = Lookup<Bot>()

func valueHolder(type: String, idNum: Int) -> ValueHolder {
	switch type {
		case "bot": return bots.get(idNum: idNum)
		case "output": return outputBins.get(idNum: idNum)
		default: fatalError("Unexpected ValueHolder type '\(type)'.")
	}
}

for line in lines where !line.isEmpty {
	let parts = line.components(separatedBy: " ")
	if parts[0] == "bot" {
		// bot A gives low to bot B and high to bot C
		// bot A gives low to output B and high to bot C
		let bot = bots.get(idNum: Int(parts[1])!)
		bot.lowDest = valueHolder(type: parts[5], idNum: Int(parts[6])!)
		bot.highDest = valueHolder(type: parts[10], idNum: Int(parts[11])!)
	} else {
		// value A goes to bot B
		let bot = bots.get(idNum: Int(parts[5])!)
		bot.receiveValue(Int(parts[1])!)
	}
}

while true {
	var numFired = 0
	for bot in bots.all {
		if bot.fireIfReady() {
			numFired += 1
		}
	}
	print("\(numFired) bots fired")
	if numFired == 0 {
		break
	}
}

outputBins.dump()
bots.dump()
