import inspect, os

fileDir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
filePath = os.path.join(fileDir, 'input.txt')  # 'input.txt' or 'test.txt'
input = open(filePath).read()

def parseInt(startIndex, endChar):
	s = ''
	skip = 0
	while True:
		ch = input[startIndex+skip]
		skip += 1
		if ch == endChar:
			return (skip, int(s))
		else:
			s += ch

def decompressedLength(startIndex, segmentLength):
	outputLength = 0
	i = startIndex
	while i < startIndex + segmentLength:
		ch = input[i]
		i += 1
		if ch.isspace():
			continue
		elif ch == '(':
			(skip, subsegmentLength) = parseInt(i, 'x')
			i += skip
			(skip, repeatCount) = parseInt(i, ')')
			i += skip
			outputLength += repeatCount * decompressedLength(i, subsegmentLength)
			i += subsegmentLength
		else:
			outputLength += 1
	return outputLength

print(decompressedLength(0, len(input)))

