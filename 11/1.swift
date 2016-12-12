import Foundation

enum InputOption {
	case test
	case partOne
	case partTwo
}

let elems: [String]
let floorMasks: [Int]
let runOption = InputOption.partOne  // Change this to try different inputs.
switch runOption {
	case .test: 
		// .  .  .  .
		// .  .  LG .
		// HG .  .  .
		// .  HM .  LM
		elems = ["H", "L"]
		floorMasks = [0b0101, 0b1000, 0b0010, 0b0000]
	case .partOne:
		// .  .  .  .  .  .  .  .  .  .
		// .  .  .  .  .  .  XG XM RG RM
		// .  .  .  PM .  SM .  .  .  .
		// TG TM PG .  SG .  .  .  .  .
		elems = ["T", "P", "S", "X", "R"]
		floorMasks = [0b1110100000, 0b0001010000, 0b0000001111, 0b0000000000]
	case .partTwo:
		// F4 .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  
		// F3 .  .  .  .  .  .  .  XG XM RG RM .  .  .  .  
		// F2 .  .  .  .  PM .  SM .  .  .  .  .  .  .  .  
		// F1 E  TG TM PG .  SG .  .  .  .  .  EG EM DG DM 
		elems = ["T", "P", "S", "X", "R", "E", "D"]
		floorMasks = [0b11101000001111, 0b00010100000000, 0b00000011110000, 0b0000000000]
}

extension Int {
	func brief(_ digits: Int? = nil) -> String {
		let digs = digits == nil ? 2*elems.count : digits!
		var s = ""
		for pos in Swift.stride(from: digs - 1, through: 0, by: -1) {
			s += (self & (1<<pos) == 0 ? "0" : "1")
		}
		return s
	}
}

struct Group: CustomStringConvertible {
	let mask: Int  // bit width is 2*elems.count

	var brief: String {
		return mask.brief()
	}

	var isDeadly: Bool {
		return containsUnprotectedMicrochip && containsGenerator
	}

	var containsUnprotectedMicrochip: Bool {
		for pos in 0..<elems.count {
			if mask & 1<<(2*pos) != 0 && mask & 1<<(2*pos+1) == 0 {
				return true
			}
		}
		return false
	}

	var containsGenerator: Bool {
		for pos in 0..<elems.count {
			if mask & 1<<(2*pos+1) != 0 {
				return true
			}
		}
		return false
	}

	var description: String {
		var d = ""
		var m = mask
		for elemLetter in elems.reversed() {
			let twoBits = m & 0b11
			d = (twoBits & 0b01 == 0 ? ".  " : "\(elemLetter)M ") + d
			d = (twoBits & 0b10 == 0 ? ".  " : "\(elemLetter)G ") + d
			m = m>>2
		}
		return d
	}

	func possibleLoadMasks() -> [Int] {
		var loads: [Int] = []
		for pos in 0..<2*elems.count {
			if mask & 1<<pos != 0 {
				loads.append(1<<pos)
			}
		}
		let numSingleLoads = loads.count
		for i in 0..<numSingleLoads-1 {
			for j in i+1..<numSingleLoads {
				loads.append(loads[i] | loads[j])
			}
		}
		return loads
	}
}

class Building: CustomStringConvertible {
	let floors: [Group]
	let elevator: Int

	var brief: String {
		return elevator.brief(2) + floors.map({ $0.brief }).joined()
	}

	var mask: Int {
		var m = elevator
		for f in floors {
			m <<= 2*elems.count
			m |= f.mask
		}
		return m
	}

	var isDeadly: Bool {
		for f in floors {
			if f.isDeadly {
				return true
			}
		}
		return false
	}

	var missionAccomplished: Bool {
		return floors.last!.mask == 1<<(2*elems.count) - 1
	}

	init(_ floors: [Group], _ elevator: Int) {
		self.floors = floors
		self.elevator = elevator
		Building.sanityCheck(floors, elevator)
	}

	convenience init(_ floorMasks: [Int], _ elevator: Int) {
		self.init(floorMasks.map({ Group(mask: $0) }), elevator)
	}

	var description: String {
		var d = ""
		for floorIndex in stride(from: floors.count - 1, through: 0, by: -1) {
			d += "F\(floorIndex + 1) "
			if floorIndex == elevator {
				d += "E  "
			} else {
				d += ".  "
			}
			d += "\(floors[floorIndex])\n"
		}
		return d
	}

	func possibleLoadMasks() -> [Int] {
		return floors[elevator].possibleLoadMasks()
	}

	func resultOfMove(loadMask: Int, direction: Int) -> Building? {
		let newElevator = elevator + direction
		if newElevator < 0 || newElevator >= floors.count {
			return nil
		}

		var newFloors = floors
		newFloors[newElevator] = Group(mask: floors[newElevator].mask | loadMask)
		newFloors[elevator] = Group(mask: floors[elevator].mask & ~loadMask)

		let newBuilding = Building(newFloors, newElevator)
		return newBuilding
	}

	private static func sanityCheck(_ floors: [Group], _ elevator: Int) {
		var combined = 0
		let bitwidth = 2 * elems.count
		for f in floors {
			if f.mask >= 1 << bitwidth {
				fatalError("floor mask 0b\(f.brief) has too many bits")
			}
			if f.mask & combined != 0 {
				fatalError("floor mask 0b\(f.brief) contains a bit already used")
			}
			combined |= f.mask
		}
		if combined != (1 << bitwidth) - 1 {
			let formatString = "%\(bitwidth * floors.count)b"
			fatalError("combined mask 0b\(String(format: formatString, combined)) is missing a bit")
		}

		if !(0..<floors.count).contains(elevator) {
			fatalError("elevator \(elevator) is out of bounds")
		}
	}
}

class Move {
	let depth: Int
	let prev: Move?
	let resultOfMove: Building

	init(depth: Int, prev: Move?, resultOfMove: Building) {
		self.depth = depth
		self.prev = prev
		self.resultOfMove = resultOfMove
	}
}

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

protocol MoveQueue {
	var count: Int { get }
	mutating func push(_: Move)
	mutating func pop() -> Move?
}

struct MoveQueueUsingArray: MoveQueue {
	private var moves: [Move] = []

	var count: Int {
		return moves.count
	}

	mutating func push(_ move: Move) {
		moves.append(move)
	}
	
	mutating func pop() -> Move? {
		return moves.isEmpty ? nil : moves.removeFirst()
	}
}

struct MoveQueueUsingLinkedList: MoveQueue {
	private var moves = Queue<Move>()

	var count: Int {
		return moves.count
	}

	mutating func push(_ move: Move) {
		moves.push(move)
	}
	
	mutating func pop() -> Move? {
		return moves.pop()
	}
}


func doSearch(usingLinkedList: Bool) {
	NSLog("starting search using %@ for the BFS queue", usingLinkedList ? "linked list" : "array")

	let building = Building(floorMasks, 0)
	print(building)

	let depthCheckpointFactor = 25
	var lastCheckpoint = 50
	var visitedBuildingMasks = Set<Int>()

	var queue: MoveQueue = usingLinkedList ? MoveQueueUsingLinkedList() : MoveQueueUsingArray()
	queue.push(Move(depth: 0, prev: nil, resultOfMove: building))

	var maxQueueLength = queue.count
	while queue.count > 0 {
		let move = queue.pop()!
		if move.depth >= lastCheckpoint && move.depth % depthCheckpointFactor == 0 {
			print("about to go to depth \(move.depth), queue length is \(queue.count)")
			lastCheckpoint += depthCheckpointFactor
		}
		if move.resultOfMove.missionAccomplished {
			NSLog("Mission accomplished at depth %ld", move.depth)
			NSLog("maxQueueLength: %ld, maxDepth: %ld, visited: %ld", maxQueueLength, visitedBuildingMasks.count)
			
			// Note: this displays the moves in reverse order.
//			var m = move
//			while m.prev != nil {
//				print(m.resultOfMove)
//				m = m.prev!
//			}
			break
		}
		let possibleLoadMasks = move.resultOfMove.possibleLoadMasks()
		for loadMask in possibleLoadMasks {
			for dir in [-1, 1] {
				if let b2 = move.resultOfMove.resultOfMove(loadMask: loadMask, direction: dir) {
					let b2mask = b2.mask
					if visitedBuildingMasks.contains(b2mask) {
						continue
					}
					visitedBuildingMasks.insert(b2mask)
					if visitedBuildingMasks.count % 5000000 == 0 {
						NSLog("visited: %ld", visitedBuildingMasks.count)
					}
					if b2.isDeadly {
						continue
					}
					queue.push(Move(depth: move.depth+1, prev: move, resultOfMove: b2))
					if maxQueueLength < queue.count {
						maxQueueLength = queue.count
						if maxQueueLength % 50000 == 0 {
							NSLog("maxQueueLength: %ld", maxQueueLength)
						}
					}
				}
			}
		}
	}
}

doSearch(usingLinkedList: false)
doSearch(usingLinkedList: true)


//print(Group(mask: 0))
//print(Group(mask: 0b0010))
//print(Group(mask: 0b1000))
//print(Group(mask: 0b0101))
//

//print(Group(mask: 0b0101).isDeadly)
//print(Group(mask: 0b0101).containsGenerator)
//print(Group(mask: 0b0101).containsUnprotectedMicrochip)
//print(Group(mask: 0b0111).possibleLoadMasks())




