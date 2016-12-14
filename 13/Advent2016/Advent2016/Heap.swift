import Foundation

// Returns true if lhs has higher priority than rhs.
typealias PriorityBlock<T> = (_ lhs: T, _ rhs: T)->Bool

struct Heap<T> {
	private var elements: [T] = []
	private let priorityBlock: PriorityBlock<T>

	var count: Int {
		return elements.count
	}

	init(priorityBlock: @escaping PriorityBlock<T>) {
		self.priorityBlock = priorityBlock
	}

	var top: T? {
		return elements.count == 0 ? nil : elements[0]
	}

	mutating func insert(_ value: T) {
		elements.append(value)

		// Percolate up.
		var k = elements.count - 1
		while k > 0 {
			if swapWithParentIfNeeded(k) {
				k = indexOfParent(k)
			} else {
				break
			}
		}
	}

	private var elementString: String {
		let parts = elements.map({ $0 == nil ? "nil" : "\($0!)" })
		return "\(parts)"
	}

	mutating func pop() -> T? {
		if elements.count == 0 {
			return nil
		}
		let value = elements[0]
		//print("popping \(value) from \(self.elementString)")
		let last = elements.removeLast()
		if elements.count == 0 {
			return value
		}
		elements[0] = last

		// Percolate down.
		var k = 0
		while k < elements.count {
			//print("  \(self.elementString)")
			guard let childIndex = indexOfGreaterChild(k) else {
				break
			}
			guard swapWithParentIfNeeded(childIndex) else {
				break
			}
			k = childIndex
		}
		//sanityCheck()

		return value
	}

	func sorted() -> [T] {
		var tempHeap = self
		var result: [T] = []
		while tempHeap.count > 0 {
			result.append(tempHeap.pop()!)
		}
		return result
	}

	private func sanityCheck() {
		for k in stride(from: elements.count - 1, through: 1, by: -1) {
			if priorityBlock(elements[k], elements[indexOfParent(k)]) {
				fatalError("failed sanity check")
			}
		}
	}

	private func indexOfGreaterChild(_ parentIndex: Int) -> Int? {
		let leftIndex = 2*parentIndex + 1
		if leftIndex <= 0 || leftIndex >= elements.count {
			return nil
		}

		let rightIndex = leftIndex + 1
		if rightIndex <= 0 || rightIndex >= elements.count {
			return leftIndex
		}

		return priorityBlock(elements[leftIndex], elements[rightIndex]) ? leftIndex : rightIndex
	}

	private func indexOfParent(_ childIndex: Int) -> Int {
		return (childIndex - 1) / 2
	}

	private mutating func swapWithParentIfNeeded(_ childIndex: Int) -> Bool {
		if childIndex <= 0 || childIndex >= elements.count {
			return false
		}

		let parentIndex = indexOfParent(childIndex)
		if priorityBlock(elements[parentIndex], elements[childIndex]) {
			return false
		}

		let temp = elements[parentIndex]
		elements[parentIndex] = elements[childIndex]
		elements[childIndex] = temp
		return true
	}
}

//var heap = Heap<Int>()
//var list: [Int] = []
//for _ in 0..<10 {
//	let n = Int(arc4random_uniform(50))
//	heap.insert(n)
//	list.append(n)
//}
//let a = heap.sorted()
//let b = Array(list.sorted().reversed())
//print(a)
//print(b)
//if a != b {
//	print("wtf")
//}
//
//
