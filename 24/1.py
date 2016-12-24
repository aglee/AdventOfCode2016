import inspect, os
import datetime
import math
import Queue
import heapq

def get_input_lines(file_name):
	file_dir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
	file_path = os.path.join(file_dir, file_name)
	return [line.rstrip('\n') for line in open(file_path)]

def fatal_error(s):
	print('[ERROR] ' + s)
	exit()

def print_list(items):
	for x in items:
		print(str(x))

def print_dict(d):
	for k in sorted(d.keys()):
		print('{}: {}'.format(k, d[k]))

class Solver(object):
	def __init__(self):
		self.lookup = {}
		max_digit = 0
		for line in get_input_lines("dump2.txt"):
			triple = self._parse_line(line)
			if triple is None:
				continue
			(i, j, distance) = triple
			self.lookup[(i, j)] = distance
			if i > max_digit: max_digit = i
			if j > max_digit: max_digit = j
		self.num_digits = max_digit + 1

		self.best_total = 0
		self.best_path = []
		self.all_full_paths = []

		
		# Sanity check.
		for i in range(0, self.num_digits - 1):
			for j in range(i + 1, self.num_digits):
				if self.lookup.get((i, j)) is None:
					fatal_error('Missing distance for ({}, {}).'.format(i, j))
		print_dict(self.lookup)

	def _parse_line(self, line):
		parts = line.split()
		if len(parts) < 4: return None
		if parts[-4] != 'END': return None
		return (int(parts[-3]), int(parts[-2]), int(parts[-1]))
		
	def distance(self, i, j):
		if i == j: return 0
		if i > j: return self.lookup[(j, i)]
		return self.lookup[(i, j)]
	
	def solve(self):
		self.best_total = 30000000000
		self.best_path = []
		self.all_full_paths = []
		result = self.find_min_path_length(0, 0, [x for x in range(1, self.num_digits)], [0])
		print('-------------------')
		for i in range(self.num_digits - 1):
			(i, j) = (self.best_path[i], self.best_path[i + 1])
			print('{}: {}'.format((i, j), self.distance(i, j)))
		print('FINAL: {} gives {}'.format(self.best_path, self.best_total))
		print('{} full paths checked'.format(len(self.all_full_paths)))
		min_to_return_to_zero = 30000000000
		for (full_path, fp_cost) in self.all_full_paths:
			last_digit = full_path[-1]
			cost_of_last_leg = self.distance(last_digit, 0)
			test = fp_cost + cost_of_last_leg
			if test < min_to_return_to_zero:
				min_to_return_to_zero = test
		print('minimum including return to zero is {}'.format(min_to_return_to_zero))
		return result
	
	# Let's see if brute-force recursion works.
	def find_min_path_length(self, total_so_far, start_digit, remaining_digits, path_so_far):
		if len(remaining_digits) == 0:
#			print('{} gives {}'.format(path_so_far, total_so_far))
			self.all_full_paths.append((path_so_far, total_so_far))
			if total_so_far < self.best_total:
				self.best_total = total_so_far
				self.best_path = path_so_far
#				print('{} gives {}'.format(path_so_far, total_so_far))
			return total_so_far  # Part 1.
		min_path_length = None
		for d in remaining_digits:
			distance_to_d = self.distance(start_digit, d)
			digits_minus_d = remaining_digits[:]
			digits_minus_d.remove(d)
			test_length = self.find_min_path_length(total_so_far + distance_to_d, d, digits_minus_d, path_so_far + [d])
			if min_path_length is None:
				min_path_length = test_length
			elif test_length < min_path_length:
				min_path_length = test_length
		return min_path_length

solver = Solver()
print(solver.solve())


#print("[{}] START".format(datetime.datetime.now()))
#print("[{}] END".format(datetime.datetime.now()))





