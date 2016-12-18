import datetime
import inspect, os

fileDir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
filePath = os.path.join(fileDir, "input.txt")  # "input.txt" or "test.txt"
startLine = list(open(filePath))[0].rstrip('\n')

def next_line(line):
	def char_at_index(i):
		return '.' if i < 0 or i >= len(line) else line[i]
	def char_for_next_row(i):
		return '^' if char_at_index(i - 1) != char_at_index(i + 1) else '.'
	return ''.join(map(lambda i: char_for_next_row(i), range(0, len(line))))

def solve(start, count):
	line = start
	num_safe = 0
	for _ in range(0, count):
		#print(line)
		num_safe += line.count('.')
		line = next_line(line)
	print('total num safe is {}'.format(num_safe))

#solve('.^^.^.^^^^', 10)
print("[{}] START PART 1".format(datetime.datetime.now()))
solve(startLine, 40)
print("[{}] END PART 1".format(datetime.datetime.now()))
print("")
print("[{}] START PART 2".format(datetime.datetime.now()))
solve(startLine, 400000)
print("[{}] END PART 2".format(datetime.datetime.now()))

