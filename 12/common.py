import datetime
import inspect, os

def readInputLines():
	fileDir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
	filePath = os.path.join(fileDir, "input.txt")  # "input.txt" or "test.txt"
	return [line.rstrip('\n') for line in open(filePath)]

def fatalError(message):
	print("FATAL ERROR: " + message)
	exit()

def run(registers):
	def value(term):
		return registers[term] if (term in 'abcd') else int(term)

	instructions = map(lambda x: x.split(' '), readInputLines())

	print("[{}] START".format(datetime.datetime.now()))
	pc = 0
	numCycles = 0
	while True:
		numCycles += 1
		if numCycles % 1000000 == 0:
			print("[{}] numCycles = {}".format(datetime.datetime.now(), numCycles))
		args = instructions[pc]
		jump = 1
		if args[0] == 'jnz':  # jnz <reg_or_int> <jump>
			if value(args[1]) != 0:
				jump = int(args[2])
		elif args[0] == 'cpy':  # cpy <reg_or_int> <reg>
			registers[args[2]] = value(args[1])
		elif args[0] == 'inc':  # inc <reg>
			registers[args[1]] += 1
		elif args[0] == 'dec':  # dec <reg>
			registers[args[1]] -= 1
		else:
			fatalError("Could not parse instruction {}".format(args))
		pc += jump
		if pc >= len(instructions):
			break
	print("[{}] DONE -- {} cycles".format(datetime.datetime.now(), numCycles))

	return registers
