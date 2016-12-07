import Foundation

let dirURL = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let fileURL = dirURL.appendingPathComponent("input.txt")  // "input.txt" or "test.txt"
let fileContents = try! String(contentsOf: fileURL)
let lines = fileContents.components(separatedBy: "\n")

func checksum(_ pieces: [String]) -> String {
	var d: [Character: Int] = [:]
	for s in pieces {
		for ch in s.characters {
			d[ch] = (d[ch] == nil ? 1 : d[ch]! + 1)
		}
	}
	
	let sortedChars = d.keys.sorted(by: { d[$0]! > d[$1]! || (d[$0] == d[$1] && $0 < $1) })
	var checksum = sortedChars.map({ String($0) }).joined()
	let checksumLength = 5
	if checksum.characters.count > checksumLength {
		let endIndex = checksum.index(checksum.startIndex, offsetBy: checksumLength)
		checksum = checksum.substring(to: endIndex)
	}
	return checksum
}

func parse(_ s: String) -> (pieces: [String], sectorID: Int, checksum: String) {
	var pieces = s.components(separatedBy: "-")
	let tailEnd = pieces.removeLast().components(separatedBy: CharacterSet.punctuationCharacters)
	return (pieces, Int(tailEnd[0])!, tailEnd[1])
}

func decryptPiece(_ piece: String, _ sectorID: Int) -> String {
	func decryptUnicodeScalar(_ ch: UnicodeScalar, _ sectorID: Int) -> String {
		return String(UnicodeScalar((((ch.value - 97) + UInt32(sectorID)) % 26) + 97)!)
	}
	return(piece.unicodeScalars.map({ decryptUnicodeScalar($0, sectorID) }).joined())
}

func decrypt(_ pieces: [String], _ sectorID: Int) -> String {
	let decryptedPieces = pieces.map({ decryptPiece($0, sectorID) })
	return decryptedPieces.joined(separator: " ")
}

for line in lines {
	let p = parse(line)
	if checksum(p.pieces) == p.checksum {
		print("\(decrypt(p.pieces, p.sectorID)) -- \(p.sectorID)")
	}
}

