def bit_count(num):
	n = num
	count = 0
	while n != 0:
		if n & 1 != 0:
			count += 1
		n = n>>1
	return count

def solve(*args):
	(REASON_TO_END, favorite_number, goal, maxsteps_walked) = args

	def square_is_open(x, y):
		if x < 0 or y < 0:
			return False
		num_bits = bit_count(x*x + 3*x + 2*x*y + y + y*y + favorite_number)
		return num_bits & 1 == 0
	
	visited = set()
	frontier = set([(1, 1)])
	steps_walked = 0  # Number of steps we have taken from the start square.
	while True:
		# Find all reachable neighbors of the current frontier,
		# and construct the next frontier.
		new_frontier = set()
		for point in frontier:
			if REASON_TO_END == 'part1':
				if point == goal:
					print('PART 1: depth = {}'.format(steps_walked))
					return

			visited.add(point)

			# Expand the frontier to include unvisited neighbors.
			for (dx, dy) in [(0, 1), (1, 0), (0, -1), (-1, 0)]:
				neighbor = (point[0] + dx, point[1] + dy)
				if not neighbor in visited and square_is_open(neighbor[0], neighbor[1]):
					new_frontier.add(neighbor)

		if REASON_TO_END == 'part2':
			# If maxsteps_walked is 50, we want to go through this loop 51 times.
			if steps_walked == maxsteps_walked:
				print('PART 2: visited {} squares'.format(len(visited)))
				return

		frontier = new_frontier
		steps_walked += 1

#solve('part1', 10, (7, 4), None)
solve('part1', 1352, (31, 39), None)
solve('part2', 1352, None, 50)

