import inspect, os

fileDir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
filePath = os.path.join(fileDir, "input.txt")  # "input.txt" or "test.txt"
lines = [line.rstrip('\n') for line in open(filePath)]

def findABAs(piece):
	found = []
	for charIndex in range(0, len(piece) - 2):
		s = piece[charIndex:charIndex+3]
		if (s[0] != s[1]) and (s[0] == s[2]):
			found.append(s)
	return found

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
	abas = []
	for piece in supernets:
		abas += findABAs(piece)
	for aba in abas:
		for piece in hypernets:
			if aba[1] + aba[0] + aba[1] in piece:
				#print('GOOD <%s> %s' % (aba, line))
				return True
	return False

numValid = 0
for line in lines:
	if isValid(line):
		numValid += 1
print(numValid)
