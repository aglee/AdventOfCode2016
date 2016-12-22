import inspect, os
import datetime
import math
import Queue

def get_input_lines(file_name = "input.txt"):
	file_dir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
	file_path = os.path.join(file_dir, file_name)
	return [line.rstrip('\n') for line in open(file_path)]

def print_list(items):
	for x in items:
		print(str(x))

# Input looks like this:
#	root@ebhq-gridcenter# df -h
#	Filesystem              Size  Used  Avail  Use%
#	/dev/grid/node-x0-y0     91T   66T    25T   72%
#	/dev/grid/node-x0-y1     87T   68T    19T   78%
#	/dev/grid/node-x0-y2     93T   73T    20T   78%
class Node(object):
	def __init__(self, x, y, size, used):
		self.x = x
		self.y = y
		self.size = size
		self.used = used

	def __str__(self):
		return '<({},{}) size={} used={}>'.format(self.x, self.y, self.size, self.used)

	@property
	def avail(self):
		return self.size - self.used
	
class Grid(object):
	def __init__(self, input_lines):
		self.nodes = {}
		max_x = max_y = -1
		for line in input_lines:
			if not line.startswith('/dev'):
				continue
			parts = line.split()
			(x_string, y_string) = parts[0].split('-')[-2:]  # E.g. ['x3', 'y17'].
			(x, y) = (int(x_string[1:]), int(y_string[1:]))
			size = int(parts[1][:-1])
			used = int(parts[2][:-1])
			self.nodes[(x, y)] = Node(x, y, size, used)
			if max_x < x:
				max_x = x
			if max_y < y:
				max_y = y
		self.grid_width = max_x + 1
		self.grid_height = max_y + 1

	def node_at_point(self, x, y):
		if x < 0 or x >= self.grid_width or y < 0 or y >= self.grid_height:
			return None
		return self.nodes.get((x, y))

	def num_viable_pairs(self):
		viable_count = 0
		for x1 in range(self.grid_width):
			for y1 in range(self.grid_height):
				nodeA = self.node_at_point(x1, y1)
				if nodeA.used == 0:
					continue
				for x2 in range(self.grid_width):
					for y2 in range(self.grid_height):
						if x1 != x2 or y1 != y2:
							nodeB = self.node_at_point(x2, y2)
							if nodeA.used <= nodeB.avail:
								viable_count += 1
		return viable_count

grid = Grid(get_input_lines())
print("[{}] START".format(datetime.datetime.now()))
print('Part 1: number of viable pairs is {}.'.format(grid.num_viable_pairs()))
print("[{}] END".format(datetime.datetime.now()))

