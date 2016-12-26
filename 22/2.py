# coding: utf8

import AStar
import datetime
import heapq
import inspect
import math
import os
import Queue

def get_input_lines(file_name = "input.txt"):
	file_dir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
	file_path = os.path.join(file_dir, file_name)
	return [line.rstrip('\n') for line in open(file_path)]

def print_list(items):
	for x in items:
		print(str(x))

class Tiering(object):
	def __init__(self, tier_size):
		self.tier_size = tier_size
		self.tier_lists = {}
	
	def add(self, number):
		tier = number / self.tier_size
		if self.tier_lists.get(tier):
			self.tier_lists[tier].append(number)
		else:
			self.tier_lists[tier] = [number]
	
	def summary(self):
		summ = [("min", "max", "count")]
		for tier in sorted(self.tier_lists.keys()):
			tier_list = sorted(self.tier_lists[tier])
			summ.append((tier_list[0], tier_list[-1], len(tier_list)))
		return summ

class GenericGrid(object):
	def __init__(self, width, height, values = None):
		self.width = width
		self.height = height
		if values is None:
			self.values = [None] * width * height
		else:
			self.values = values

	def get(self, x, y):
		return self.values[y * self.width + x]
	
	def get_xy(self, xy):
		(x, y) = xy
		return self.get(x, y)
	
	def set(self, x, y, value):
		self.values[y * self.width + x] = value
	
	def set_xy(self, xy, value):
		(x, y) = xy
		self.set(x, y, value)

# Search node that we use for the A* algorithm.  Contains load values for
# every point in the grid, plus other info used by A*.
class PuzzleSearchNode(GenericGrid):
	def __init__(self, width, height, values = None):
		super(PuzzleSearchNode, self).__init__(width, height, values)
		# State of the grid.
		self.empty_xy = None
		self.payload_xy = None
		
		# Info that isn't part of the grid state, (and is therefore
		# not copied by the dupe() method), but is associated with the
		# grid state for purposes of using it as an A* search node.
		self.g_score = 100000000  # Effectively infinity.
		self.f_score = 100000000  # Effectively infinity.
		self.frontier = False
		self.closed = False
		self.parent = None
		self.depth = 0
	
	def hashable_value(self):
# After simplifying the problem data (turns out a lot of the numbers can be
# replaced with, essentially, 0, 1, or infinity), I was also able to simplify
# this hashable value.  In fact, I didn't need search nodes to be entire grids
# at all -- they only had to note the position of the empty square and the
# payload square.
#
# This simplification of hashable_value reduced my execution time from 1.5 seconds
# to half a second.  I bet it could be even faster if I didn't bother duplicating
# the entire grid for each search node.
#		return tuple(self.values) + self.empty_xy + self.payload_xy
		return self.empty_xy + self.payload_xy
	
	def dupe(self):
		new_node = PuzzleSearchNode(self.width, self.height, self.values[:])
		new_node.empty_xy = self.empty_xy
		new_node.payload_xy = self.payload_xy
		return new_node
	
	def dump(self, nodes_to_highlight = set()):
		tiering = Tiering(100)
		for y in range(self.height):
			s = ''
			for x in range(self.width):
				load = self.get(x, y)
				tiering.add(load)
				if (x, y) == self.payload_xy:
					s += u'🐙'
				elif load == 0:
					s += u'❤️'
				elif load > 100:
					s += u'⬛️'
				elif (x, y) in nodes_to_highlight:
					s += u'❤️'
				else:
					s += u'⬜️'
			print(s)
		print('load tiers: {}'.format(tiering.summary()))
		

class Puzzle22b(AStar.AStar):
	def __init__(self, capacity_grid):
		super(Puzzle22b, self).__init__()
		self.capacity_grid = capacity_grid
		self.frontier_heap = []
		self.unique_node_pool = {}

	@property
	def width(self):
		return self.capacity_grid.width
	
	@property
	def height(self):
		return self.capacity_grid.height
		
	def can_move_load_from_to(self, search_node, from_xy, to_xy):
		(from_x, from_y) = from_xy
		if from_x < 0 or from_x >= self.width or from_y < 0 or from_y >= self.height:
			return False
		from_load = search_node.get_xy(from_xy)
		to_avail = self.capacity_grid.get_xy(to_xy) - search_node.get_xy(to_xy)
		return from_load <= to_avail
		
	def move_load_to_empty_xy(self, search_node, from_xy):
		to_xy = search_node.empty_xy
		if from_xy == to_xy:
			print("ERROR: Trying to move load with from_xy == to_xy.")
			exit()
		from_load = search_node.get_xy(from_xy)
		to_load = search_node.get_xy(to_xy)
		if to_load != 0:
			print("ERROR: Trying to move load into non-empty xy.")
			exit()
		search_node.set_xy(from_xy, 0)
		search_node.set_xy(to_xy, from_load + to_load)
		if from_xy == search_node.payload_xy:
			search_node.payload_xy = to_xy
		search_node.empty_xy = from_xy
	
	# Avoid having two instances of the same node, so that when we set a
	# node's F score, G score, etc., we only do it in one place.
	def unique_node(self, search_node):
		node_key = search_node.hashable_value()
		u = self.unique_node_pool.get(node_key)
		if u is None:
			self.unique_node_pool[node_key] = search_node
			return search_node
		else:
			return u			

	def dump(self):
		tiering = Tiering(100)
		for y in range(self.height):
			for x in range(self.width):
				capacity = self.capacity_grid.get(x, y)
				tiering.add(capacity)
		print('capacity tiers: {}'.format(tiering.summary()))

	# AStar method overrides.  search_node is PuzzleState.

	def meets_goal(self, search_node): return search_node.payload_xy == (0, 0)

	def get_neighbors(self, search_node):
		pairs = []
		(empty_x, empty_y) = search_node.empty_xy
		for (dx, dy) in ((0, 1), (1, 0), (0, -1), (-1, 0)):
			(from_x, from_y) = (empty_x + dx, empty_y + dy)
			if self.can_move_load_from_to(search_node, (from_x, from_y), (empty_x, empty_y)):
				neighbor = search_node.dupe()
				self.move_load_to_empty_xy(neighbor, (from_x, from_y))
				neighbor = self.unique_node(neighbor)
				pairs.append((neighbor, 1))
		return pairs

	def h_score(self, search_node):
		# I figure it's most likely we want to get the empty next to the payload first,
		# which will allow both of them to move toward (0, 0), since nothing can move
		# until the empty space is next to it.
		(empty_x, empty_y) = search_node.empty_xy
		(payload_x, payload_y) = search_node.payload_xy
		(dx, dy) = (abs(empty_x - payload_x), abs(empty_y - payload_y))
		if dx + dy > 1:
#			return math.sqrt(dx*dx + dy*dy)
			return 100*(dx*dx + dy*dy)
		else:
			return math.sqrt(payload_x*payload_x + payload_y*payload_y)
	
	def g_score(self, search_node): return search_node.g_score
	def set_g_score(self, search_node, score): search_node.g_score = score
	def f_score(self, search_node): return search_node.f_score
	def set_f_score(self, search_node, score): search_node.f_score = score

	def frontier_is_empty(self): return len(self.frontier_heap) == 0
	def add_to_frontier(self, search_node):
		heapq.heappush(self.frontier_heap, (search_node.f_score, search_node))
		search_node.frontier = True
	def pop_from_frontier(self):
		heap_top = heapq.heappop(self.frontier_heap)
		if heap_top:
			search_node = heap_top[1]
			search_node.is_in_frontier = False
		return search_node
	def is_in_frontier(self, search_node): return search_node.frontier

	def add_to_closed_set(self, search_node): search_node.closed = True
	def is_in_closed_set(self, search_node): return search_node.closed

	# Reconstructing the path from the start node to the winning node.
	def parent(self, search_node): return search_node.parent
	def set_parent(self, search_node, parent_node):
		search_node.parent = parent_node
		search_node.depth = parent_node.depth + 1
	def path_from_start(self, search_node):
		path = []
		n = search_node
		while n is not None:
			path.append(n)
			n = n.parent
		return list(reversed(path))


# Input looks like this:
#	root@ebhq-gridcenter# df -h
#	Filesystem              Size  Used  Avail  Use%
#	/dev/grid/node-x0-y0     91T   66T    25T   72%
#	/dev/grid/node-x0-y1     87T   68T    19T   78%
#	/dev/grid/node-x0-y2     93T   73T    20T   78%
def parse_line(line):
	parts = line.split()
	(x_string, y_string) = parts[0].split('-')[-2:]  # E.g. ['x3', 'y17'].
	(x, y) = (int(x_string[1:]), int(y_string[1:]))
	capacity = int(parts[1][:-1])
	load = int(parts[2][:-1])
	return (x, y, capacity, load)

def parse_puzzle_info(input_lines):
	nodes = {}
	max_x = max_y = -1
	for line in input_lines:
		if not line.startswith('/dev'):
			continue
		(x, y, capacity, load) = parse_line(line)
		nodes[(x, y)] = (capacity, load)
		if max_x < x: max_x = x
		if max_y < y: max_y = y
	(grid_width, grid_height) = (max_x + 1, max_y + 1)
	return (grid_width, grid_height, nodes)

(grid_width, grid_height, nodes) = parse_puzzle_info(get_input_lines("input.txt"))

capacity_grid = GenericGrid(grid_width, grid_height)
start_node = PuzzleSearchNode(grid_width, grid_height)
start_node.payload_xy = (grid_width - 1, 0)
for x in range(grid_width):
	for y in range(grid_height):
		(capacity, load) = nodes[(x, y)]
		if load < 100:
			capacity = 100
			if load > 0:
				load = 100
		capacity_grid.set(x, y, capacity)
		start_node.set(x, y, load)
		if load == 0:
			start_node.empty_xy = (x, y)

start_node.dump()
search = Puzzle22b(capacity_grid)
search.dump()
print("[{}] START".format(datetime.datetime.now()))
success_path = search.search(start_node)
print("[{}] END".format(datetime.datetime.now()))
success_points = map(lambda x: x.empty_xy, success_path)
start_node.dump(success_points)
print('shortest path is {}'.format(len(success_path) - 1))



