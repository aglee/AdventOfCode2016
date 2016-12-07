import md5
import inspect, os

fileDir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
filePath = os.path.join(fileDir, "input.txt")  # "input.txt" or "test.txt"
lines = [line.rstrip('\n') for line in open(filePath)]

doorID = lines[0]
pw = ""
for i in range(0, 10000000):
	s = doorID + str(i)
	m = md5.new(s).hexdigest()
	if m[:5] == "00000":
		pw += m[5]
		print("%s -- %s -- %s" % (s, m, pw))
		if len(pw) == 8:
			break
print("Done")
