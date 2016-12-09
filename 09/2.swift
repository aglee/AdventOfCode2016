import Foundation

let dirURL = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let fileURL = dirURL.appendingPathComponent("input.txt")  // "input.txt" or "test.txt"
let input = try! Array(String(contentsOf: fileURL).characters)

func decompressedLength(startIndex: Int, segmentLength: Int) -> Int {
	var outputLength = 0
	var charIndex = startIndex
	while charIndex < startIndex + segmentLength {
		let ch = input[charIndex]
		charIndex += 1
		if CharacterSet.whitespacesAndNewlines.contains(UnicodeScalar(String(ch))!) {
			// Skip whitespace characters.
		} else if ch == "(" {
			let (skip, subsegmentLength) = parseInt(charIndex, "x")
			charIndex += skip  // charIndex now points right after the "x".
			let (skip2, repeatCount) = parseInt(charIndex, ")")
			charIndex += skip2  // charIndex now points right after the ")".
			outputLength += repeatCount * decompressedLength(startIndex: charIndex, segmentLength: subsegmentLength)
			charIndex += subsegmentLength
		} else {
			outputLength += 1
		}
	}
	return outputLength
}

func parseInt(_ startIndex: Int, _ endChar: Character) -> (Int, Int) {
	var s = ""
	var skip = 0
	while true {
		let ch = input[startIndex + skip]
		skip += 1
		if ch == endChar {
			return (skip, Int(s)!)
		} else {
			s += String(ch)
		}
	}
}

print(decompressedLength(startIndex: 0, segmentLength: input.count))

