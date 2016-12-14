import Foundation

extension Int {
	var numBits: Int {
		var n = self
		var bitCount = 0
		while n != 0 {
			if n & 1 != 0 {
				bitCount += 1
			}
			n = n>>1
		}
		return bitCount
	}

	var binaryString: String {
		return String(self, radix: 2)
	}
}

