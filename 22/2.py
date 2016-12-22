import inspect, os
import copy
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

class Node(object):
	def __init__(self, size, used):
		self.size = size
		self.used = used
	
	def __str__(self):
		return '<size={} used={}>'.format(self.size, self.used)
		
	@property
	def avail(self):
		return self.size - self.used

# Input looks like this:
#	root@ebhq-gridcenter# df -h
#	Filesystem              Size  Used  Avail  Use%
#	/dev/grid/node-x0-y0     91T   66T    25T   72%
#	/dev/grid/node-x0-y1     87T   68T    19T   78%
#	/dev/grid/node-x0-y2     93T   73T    20T   78%
class Grid(object):
	def __init__(self):
		self.grid_width = 0
		self.grid_height = 0
		self.nodes_by_xy = {}  # Key is an (x,y) tuple. Value is a Node.
		self.goal_x = None
		self.goal_y = None
		self.empty_x = None
		self.empty_y = None
	
	# Returns a tuple containing one (size, used) pair for every node,
	# plus a (goal_x, goal_y) pair at the end.  This tuple is used for
	# remembering visited search states during breadth-first search.
	def info_tuple(self):
		pairs = []
		for y in range(self.grid_height):
			for x in range(self.grid_width):
				node = self.node_at_xy(x, y)
				pairs.append((node.size, node.used))
		pairs.append((self.goal_x, self.goal_y))
		return tuple(pairs)
		
	def load_input(self, input_lines):
		self.nodes_by_xy = {}
		for line in input_lines:
			if not line.startswith('/dev'):
				continue
			(x, y, size, used) = self._parse_line(line)
			self._add_node(x, y, size, used)
		if self.empty_x is None or self.empty_y is None:
			print('FATAL ERROR: no empty node found in input.')
			exit()
		self.goal_x = self.grid_width - 1
		self.goal_y = 0

	def _parse_line(self, line):
		parts = line.split()
		(x_string, y_string) = parts[0].split('-')[-2:]  # E.g. ['x3', 'y17'].
		(x, y) = (int(x_string[1:]), int(y_string[1:]))
		size = int(parts[1][:-1])
		used = int(parts[2][:-1])
		return (x, y, size, used)

	def _add_node(self, x, y, size, used):
		if used == 0:
			if self.empty_x is not None:
				print('FATAL ERROR: found a second empty node ({},{})'.format(x, y))
				exit()
			self.empty_x = x
			self.empty_y = y
		self.nodes_by_xy[(x, y)] = Node(size, used)
		if x >= self.grid_width:
			self.grid_width = x + 1
		if y >= self.grid_height:
			self.grid_height = y + 1

	def xy_is_in_bounds(self, x, y):
		return x >= 0 and x < self.grid_width and y >= 0 and y < self.grid_height
	
	# Returns a (size, used) tuple.
	def node_at_xy(self, x, y):
		if x < 0 or x >= self.grid_width or y < 0 or y >= self.grid_height:
			print('FATAL ERROR: ({},{}) out of bounds'.format(x, y))
			exit()
		return self.nodes_by_xy[(x, y)]

	def can_move_from_to(self, from_x, from_y, to_x, to_y):
		if not self.xy_is_in_bounds(from_x, from_y):
			return False
		if not self.xy_is_in_bounds(to_x, to_y):
			return False
		from_node = self.node_at_xy(from_x, from_y)
		to_node = self.node_at_xy(to_x, to_y)
		return from_node.used + to_node.used <= to_node.size

	def move_from_to(self, from_x, from_y, to_x, to_y):
		if not self.can_move_from_to(from_x, from_y, to_x, to_y):
			print('FATAL ERROR: overflow while moving load from ({},{}) to ({},{})'.format(from_x, from_y, to_x, to_y))
			exit()
		from_node = self.node_at_xy(from_x, from_y)
		to_node = self.node_at_xy(to_x, to_y)
		to_node.used += from_node.used
		from_node.used = 0
	
	def can_move_empty_by_xy(self, dx, dy):
		(from_x, from_y) = (self.empty_x + dx, self.empty_y + dy)
		(to_x, to_y) = (self.empty_x, self.empty_y)
		return self.can_move_from_to(from_x, from_y, to_x, to_y)
	
	def move_empty_by_xy(self, dx, dy):
		(from_x, from_y) = (self.empty_x + dx, self.empty_y + dy)
		(to_x, to_y) = (self.empty_x, self.empty_y)
		self.move_from_to(from_x, from_y, to_x, to_y)
		(self.empty_x, self.empty_y) = (from_x, from_y)
		if (from_x, from_y) == (self.goal_x, self.goal_y):
			(self.goal_x, self.goal_y) = (to_x, to_y)

	def move_empty_left(self):
		self.move_empty_by_xy(-1, 0)

	def move_empty_right(self):
		self.move_empty_by_xy(1, 0)

	def move_empty_up(self):
		self.move_empty_by_xy(0, -1)

	def move_empty_down(self):
		self.move_empty_by_xy(0, 1)

	def move_empty_with_commands(self, command_string, verbose = False):
		for c in command_string:
			if verbose:
				print('doing "{}":'.format(c))
			if c == 'U': self.move_empty_up()
			elif c == 'D': self.move_empty_down()
			elif c == 'L': self.move_empty_left()
			elif c == 'R': self.move_empty_right()
			else:
				print('FATAL ERROR: unrecognized move command "{}"'.format(c))
				exit()
			if verbose:
				self.dump()

	def possible_new_grids(self):
		grids = []
		for (dx, dy) in ((0, 1), (1, 0), (0, -1), (-1, 0)):
			if self.can_move_empty_by_xy(dx, dy):
				new_grid = copy.deepcopy(self)
				new_grid.move_empty_by_xy(dx, dy)
				grids.append(new_grid)
		return grids

	def print_overview(self):
		min_used_excluding_empty = 10000
		max_avail_excluding_empty = -1
		for node in self.nodes_by_xy.values():
			if node.used != 0:
				if node.used < min_used_excluding_empty:
					min_used_excluding_empty = node.used
				if node.avail > max_avail_excluding_empty:
					max_avail_excluding_empty = node.avail
		print('grid width: {}, grid height: {}'.format(self.grid_width, self.grid_height))
		print('empty node is ({},{})'.format(self.empty_x, self.empty_y))
		print('min used: {}, max_avail: {}'.format(min_used_excluding_empty, max_avail_excluding_empty))

	def print_nodes(self):
		for y in range(self.grid_height):
			for x in range(self.grid_width):
				print('({},{}) {}'.format(x, y, self.node_at_xy(x, y)))

	def dump(self):
		for y in range(self.grid_height):
			s = ''
			for x in range(self.grid_width):
				node = self.node_at_xy(x, y)
				if (x, y) == (self.goal_x, self.goal_y):
					s += 'G'
				elif node.used == 0:
					s += '_'
				else:
					s += '.'
			print(s)

	def solve(self):
		search_queue = Queue.Queue()
		search_queue.put((self, 0))  # (grid, depth) pair.
		visited_states = set()
		depth_so_far = 0

		while not search_queue.empty():
			(grid, depth) = search_queue.get()
			visited_states.add(grid.info_tuple())
			if depth > depth_so_far:
				depth_so_far = depth
				print('[{}] depth so far is {}, approx queue size is {}'.format(datetime.datetime.now(), depth_so_far, search_queue.qsize()))
			for new_grid in grid.possible_new_grids():
				if new_grid.goal_x == 0 and new_grid.goal_y == 0:
					print('[{}] AHA -- answer is depth {}.'.format(datetime.datetime.now(), depth + 1))
					return
				if new_grid.info_tuple() in visited_states:
					continue
				search_queue.put((new_grid, depth + 1))

#grid = Grid()
#grid.load_input(get_input_lines("test.txt"))
#grid.print_nodes()
#grid.print_overview()
#print('initial grid:')
#grid.dump()
#grid.move_empty_with_commands('URDLLUR', verbose = True)

grid = Grid()
grid.load_input(get_input_lines("test.txt"))
grid.print_overview()
grid.solve()






