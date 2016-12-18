import Foundation

struct RowOfTiles {
	private static let trapChar: Character = "^"
	private static let safeChar: Character = "."
	
	private var trapFlags: [Bool]
	
	var numSafe: Int {
		return trapFlags.filter({ $0 == false }).count
	}
	
	var debugString: String {
		return trapFlags.map({ String($0 ? RowOfTiles.trapChar : RowOfTiles.safeChar) }).joined()
	}
	
	init(trapFlags: [Bool]) {
		self.trapFlags = trapFlags
	}
	
	init(tileString: String) {
		self.init(trapFlags: tileString.characters.map({ $0 == RowOfTiles.trapChar }))
	}

	func nextRow() -> RowOfTiles {
		return RowOfTiles(trapFlags: (0..<trapFlags.count).map({ tileInNextRowIsTrap(at: $0) }))
	}
	
	private func tileIsTrap(at tileIndex: Int) -> Bool {
		if tileIndex < 0 || tileIndex >= trapFlags.count {
			return false
		} else {
			return trapFlags[tileIndex]
		}
	}
	
	private func tileInNextRowIsTrap(at tileIndex: Int) -> Bool {
		// The four rules can be summarized as:
		// are the tiles at (tileIndex - 1) and (tileIndex + 1) different?
		return tileIsTrap(at: tileIndex - 1) != tileIsTrap(at: tileIndex + 1)
	}
}

func generateRows(first: String, count: Int, verbose: Bool = true) {
	var row = RowOfTiles(tileString: first)
	var numSafe = 0
	for _ in 0..<count {
		//print(row.debugString)
		numSafe += row.numSafe
		row = row.nextRow()
	}
	print("\(numSafe) safe tiles in total")
}

//generateRows(first: "..^^.", count: 3)  // Should say 6 safe tiles.
//generateRows(first: ".^^.^.^^^^", count: 10)  // Should say 38 safe tiles.

let realInput = ".^^^.^.^^^.^.......^^.^^^^.^^^^..^^^^^.^.^^^..^^.^.^^..^.^..^^...^.^^.^^^...^^.^.^^^..^^^^.....^...."

NSLog("START PART 1")
generateRows(first: realInput, count: 40, verbose: false)  // Part 1
NSLog("END PART 1")
print("")
NSLog("START PART 2")
generateRows(first: realInput, count: 400000, verbose: false)  // Part 2
NSLog("END PART 2")


