import Foundation

class QueueNode<T> {
	let value: T
	var next: QueueNode<T>?
	init(value: T) {
		self.value = value
	}
}

struct Queue<T> {
	private(set) var count: Int = 0
	private var head: QueueNode<T>?
	private var tail: QueueNode<T>?

	mutating func push(_ value: T) {
		let node = QueueNode<T>(value: value)
		if let oldTail = tail {
			oldTail.next = node
			tail = node
		} else {
			tail = node
			head = node
		}
		count += 1
	}

	mutating func pop() -> T? {
		if let oldHead = head {
			head = oldHead.next
			if head == nil {
				tail = nil
			}
			count -= 1
			return oldHead.value
		} else {
			return nil
		}
	}
}

