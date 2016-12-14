from copy import deepcopy
import datetime

(g_elements, g_floorMasks) = {
	111: (["H", "L"], [0b0101, 0b1000, 0b0010, 0b0000]),
	222: (["T", "P", "S", "X", "R"], [0b1110100000, 0b0001010000, 0b0000001111, 0b0000000000]),
	333: (["T", "P", "S", "X", "R", "E", "D"],
			[0b11101000001111, 0b00010100000000, 0b00000011110000, 0b0000000000])
}[222]

g_bitsPerFloor = 2*len(g_elements)

def fatalError(message):
	print("FATAL ERROR: " + message)
	exit

class Group(object):
	def __init__(self, mask):
		self.mask = mask

	@property
	def isDeadly(self):
		return self.containsUnprotectedMicrochip and self.containsGenerator

	@property
 	def containsUnprotectedMicrochip(self):
		for elementIndex in range(0, len(g_elements)):
			if self.mask & 1<<(2*elementIndex) != 0 and self.mask & 1<<(2*elementIndex+1) == 0:
				return True
		return False

	@property
	def containsGenerator(self):
		for elementIndex in range(0, len(g_elements)):
			if self.mask & 1<<(2*elementIndex+1) != 0:
				return True
		return False

	@property
	def possibleLoadMasks(self):
		loads = []
		# All possible single loads.
		for pos in range(0, g_bitsPerFloor):
			if self.mask & 1<<pos != 0:
				loads.append(1<<pos)
		# All possible double loads.
		numSingleLoads = len(loads)
		for i in range(0, numSingleLoads - 1):  # i ranges from first to next-to-last
			for j in range(i + 1, numSingleLoads):  # j ranges from i+1 to last
				loads.append(loads[i] | loads[j])
		return loads

	@property
	def description(self):
		d = ""
		m = self.mask
		for elemLetter in reversed(g_elements):
			lastTwoBits = m & 0b11
			d = (".  " if (lastTwoBits & 0b01 == 0) else "%sM " % elemLetter) + d
			d = (".  " if (lastTwoBits & 0b10 == 0) else "%sG " % elemLetter) + d
			m >>= 2
		return d

class Building(object):
	def __init__(self, floors, elevator):
		self.sanityCheck(floors, elevator)
		self.floors = floors
		self.elevator = elevator

	@property
	def mask(self):
		m = self.elevator
		for f in self.floors:
			m <<= g_bitsPerFloor
			m |= f.mask
		return m

	@property
	def isDeadly(self):
		for f in self.floors:
			if f.isDeadly:
				return True
		return False

	@property
	def missionAccomplished(self):
		return self.floors[-1].mask == (1<<g_bitsPerFloor) - 1

	@property
	def possibleLoadMasks(self):
		return self.floors[self.elevator].possibleLoadMasks

	def resultOfMove(self, loadMask, direction):
		newElevator = self.elevator + direction
		if newElevator < 0 or newElevator >= len(self.floors):
			return None

		newFloors = deepcopy(self.floors)
		newFloors[newElevator] = Group(self.floors[newElevator].mask | loadMask)
		newFloors[self.elevator] = Group(self.floors[self.elevator].mask & ~loadMask)

		newBuilding = Building(floors = newFloors, elevator = newElevator)
		return newBuilding

	def sanityCheck(self, floors, elevator):
		combined = 0
		for f in floors:
			if f.mask >= (1 << g_bitsPerFloor):
				fatalError("floor mask 0b\(f.brief) has too many bits")
			if f.mask & combined != 0:
				fatalError("floor mask 0b\(f.brief) contains a bit already used")
			combined |= f.mask

		if combined != (1 << g_bitsPerFloor) - 1:
			formatString = "%\(g_bitsPerFloor * floors.count)b"
			fatalError("combined mask 0b\(String(format: formatString, combined)) is missing a bit")

		if not elevator in range(0, len(floors)):
			fatalError("elevator \(elevator) is out of bounds")

	@property
	def description(self):
		d = ""
		for floorIndex in range(len(self.floors) - 1, -1, -1):
			d += "F{} ".format(floorIndex + 1)
			d += "E  " if floorIndex == self.elevator else ".  "
			d += self.floors[floorIndex].description
			d += "\n"
		return d

class Move(object):
	def __init__(self, depth, prevMove, resultingBuilding):
		self.depth = depth
		self.prevMove = prevMove
		self.resultingBuilding = resultingBuilding

	def dump(self):
		moves = []
		m = self
		while m:
			moves.append(m)
			m = m.prevMove
		for mv in reversed(moves):
			print(mv.resultingBuilding.description)

class QueueNode(object):
	def __init__(self, value):
		self.value = value
		self.next = None

class Queue(object):
	def __init__(self):
		self.count = 0
		self.head = None
		self.tail = None

	def push(self, value):
		node = QueueNode(value)
		oldTail = self.tail
		if oldTail:
			oldTail.next = node
			self.tail = node
		else:
			self.tail = node
			self.head = node
		self.count += 1

	def pop(self):
		oldHead = self.head
		if oldHead:
			self.head = oldHead.next
			if self.head is None:
				self.tail = None
			self.count -= 1
			return oldHead.value
		else:
			return None

def doSearch(usingLinkedList):
	#NSLog("starting search using %@ for the BFS queue", usingLinkedList ? "linked list" : "array")

	building = Building(map(lambda x: Group(x), g_floorMasks), 0)
#	print("BUILDING:")
#	print(building.description)

	print("[{}] START".format(datetime.datetime.now()))
	depthCheckpointFactor = 25
	lastCheckpoint = 50
	visitedBuildingMasks = set()

	queue = Queue()
	queue.push(Move(0, None, building))

	maxQueueLength = queue.count
	while queue.count > 0:
		move = queue.pop()
		if (move.depth >= lastCheckpoint) and (move.depth % depthCheckpointFactor == 0):
			print("About to go to depth {}, queue length is {}".format(move.depth, queue.count))
			lastCheckpoint += depthCheckpointFactor
		if move.resultingBuilding.missionAccomplished:
			print("[{}] END at depth {}".format(datetime.datetime.now(), move.depth))
			print("maxQueueLength: {}, visited: {}".format(maxQueueLength, len(visitedBuildingMasks)))
			#move.dump()
			print("")
			break
		possibleLoadMasks = move.resultingBuilding.possibleLoadMasks
		for loadMask in possibleLoadMasks:
			for dir in [-1, 1]:
				b2 = move.resultingBuilding.resultOfMove(loadMask, dir)
				if b2:
					b2mask = b2.mask
					if b2mask in visitedBuildingMasks:
						continue
					visitedBuildingMasks.add(b2mask)
					if len(visitedBuildingMasks) % 5000000 == 0:
						print("visited: {}".format(len(visitedBuildingMasks)))
					if b2.isDeadly:
						continue
					queue.push(Move(move.depth+1, move, b2))
					if maxQueueLength < queue.count:
						maxQueueLength = queue.count
						if maxQueueLength % 50000 == 0:
							print("maxQueueLength: {}".format(maxQueueLength))
	print("DONE -- %s" % datetime.datetime.now())

#doSearch(usingLinkedList = False)
doSearch(usingLinkedList = True)


#print(Group(mask: 0))
#print(Group(mask: 0b0010))
#print(Group(mask: 0b1000))
#print(Group(mask: 0b0101))
#

#print(Group(mask: 0b0101).isDeadly)
#print(Group(mask: 0b0101).containsGenerator)
#print(Group(mask: 0b0101).containsUnprotectedMicrochip)
#print(Group(mask: 0b0111).possibleLoadMasks())




