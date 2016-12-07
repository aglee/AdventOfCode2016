import inspect, os

fileDir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
filePath = os.path.join(fileDir, "input.txt")  # "input.txt" or "test.txt"
lines = [line.rstrip('\n') for line in open(filePath)]

# Assumes s is exactly 4 characters and contains no square brackets.
def isABBA(s):
	if s[0] == s[1]:
		return False
	return s[0] == s[3] and s[1] == s[2]

# Returns the "ABBA" if one is found so that I can print it for debugging purposes.
def findABBA(piece):
	for charIndex in range(0, len(piece) - 3):
		s = piece[charIndex:charIndex+4]
		if isABBA(s):
			return s
	return None

# "Supernets" are the pieces outside of square brackets.
# "Hypernets" are the pieces inside square brackets.
# Assumes brackets are balanced and not nested.
def getPieces(line):
	supernets = []
	hypernets = []
	for x in line.split(']'):
		y = x.split('[')
		supernets.append(y[0])
		if len(y) == 2:
			hypernets.append(y[1])
	return (supernets, hypernets)

def isValid(line):
	(supernets, hypernets) = getPieces(line)
	
	# No "hypernet" piece can contain an ABBA.
	for piece in hypernets:
		if findABBA(piece):
			return False

	# At least one "supernet" piece must contain an ABBA.
	for piece in supernets:
		if findABBA(piece):
			return True
	return False

numValid = 0
for line in lines:
	if isValid(line):
		numValid += 1
print(numValid)
