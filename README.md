# Advent of Code 2016

My solutions to [Advent of Code 2016](http://adventofcode.com/2016).  I did some of the exercises in Swift, some in Python, some in Objective-C.

I've been using [CodeRunner](https://coderunnerapp.com/) to code, run, and debug these programs.  If you don't have CodeRunner you can run them from the command line:

```bash
# Swift when you have one standalone file
swift 2.swift

# Swift when you have multiple files, including main.swift
swiftc -o main *.swift && ./main
```

```bash
# Python
python 2.py
```

```bash
# Objective-C
xcrun clang -fobjc-arc -framework Foundation -ObjC -o 2.out 2.m
2.out
```

Often I download the input into a text file called input.txt.  I have some boilerplate code to read that file that I copy and paste from one day to the next.

Links for each day look like this:

- Problem description: <http://adventofcode.com/2016/day/1>.
- Input data: <http://adventofcode.com/2016/day/1/input>.


## Notes

- Beware accidental add trailing newlines in the input.txt files.
	- In Python, can strip trailing newlines before splitting the file into lines:
		```python
		return [line.rstrip('\n') for line in open(filePath)]
		```
	- In Swift, can use `where` as a loop condition:
		```swift
		for line in lines where !line.isEmpty {
		```
- In my Day 11 solutions Python was way, way slower than Swift.  In my Day 12 solutions Swift was way, way slower than Python.  I wonder that was about.
- There turns out to be a solution to Day 11 that's just a few easy lines of code.
- I used Xcode for Day 13 because for the amount of code I was writing (including reuse of a Queue object that I wrote for Day 11), I really wanted to split it into multiple files.  Also, there are quirks in CodeRunner that were starting to be annoying.  At some point it might be nice to figure out the terminal command to build that project and run it.  Might be a useful thing to know.



