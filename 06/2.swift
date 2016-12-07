import Foundation

let dirURL = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let fileURL = dirURL.appendingPathComponent("input.txt")  // "input.txt" or "test.txt"
let fileContents = try! String(contentsOf: fileURL)
let lines = fileContents.components(separatedBy: "\n")

var freqs = [[Character: Int]](repeating: [:], count: lines.first!.characters.count)
for line in lines {
	for (i, ch) in line.characters.enumerated() {
		freqs[i][ch] = (freqs[i][ch] == nil ? 1 : freqs[i][ch]! + 1)
	}
}
print(freqs.map({ String($0.sorted(by: { $0.value < $1.value }).first!.key) }).joined())
