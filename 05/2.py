import md5
import inspect, os

fileDir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
filePath = os.path.join(fileDir, "input.txt")  # "input.txt" or "test.txt"
lines = [line.rstrip('\n') for line in open(filePath)]

doorID = lines[0]

PW_LENGTH = 8
outputDigits = [None] * PW_LENGTH
numDigitsDone = 0
for index in range(0, 30000000):
	h = md5.new(doorID + str(index))
	m = h.hexdigest()
	if m[:5] == '00000':
		pos = int(m[5], 16)
		if pos >= PW_LENGTH or outputDigits[pos] != None:
			continue
		dig = m[6]
		outputDigits[pos] = dig
		print('%s -- %s -- %s' % (index, pos, dig))
		numDigitsDone += 1
		if numDigitsDone == 8:
			break
print('Done - ' + ''.join(outputDigits))
