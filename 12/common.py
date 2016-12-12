import inspect, os

def readInputLines():
	fileDir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
	filePath = os.path.join(fileDir, "input.txt")  # "input.txt" or "test.txt"
	return [line.rstrip('\n') for line in open(filePath)]

def loadInstructions():
	instructions = []
	for line in readInputLines():
		parts = line.split(' ')
		instructions.append((parts[0], parts[1:]))
	return instructions

def run(registers):
	def value(term):
		return registers[term] if (term in 'abcd') else int(term)

	instructions = loadInstructions()
	pc = 0
	while True:
		(cmd, args) = instructions[pc]
		if cmd == 'jnz':  # jnz <reg_or_int> <jump>
			pc += value(args[1]) if value(args[0]) != 0 else 1
		else:
			if cmd == 'cpy':  # cpy <reg_or_int> <reg>
				registers[args[1]] = value(args[0])
			elif cmd == 'inc':  # inc <reg>
				registers[args[0]] += 1
			elif cmd == 'dec':  # dec <reg>
				registers[args[0]] -= 1
			else:
				print("Could not parse instruction")
			pc += 1
		if pc >= len(instructions):
			break

	return registers
