import md5

# Does BFS of states we can get to starting from the initial state.  Each state looks
# like ((x, y), path), where (x, y) indicates a room in the grid and path is a sequence
# of ULDR letters used to arrive at that room.
def solve(passcode):
	DIRECTIONS = (('U', (0, -1)), ('D', (0, 1)), ('L', (-1, 0)), ('R', (1, 0)))
	last_path_found = None
	states_queue = [((0, 0), '')]
	while len(states_queue) > 0:
		# See if we've reached the destination.
		((x, y), path) = states_queue.pop(0)
		if (x, y) == (3, 3):
			if last_path_found is None:
				print('PART 1: shortest path is ' + path)
			last_path_found = path
			continue
		
		# Generate between 0 and 4 new steps that we could take from
		# the current state.
		for i, hex_digit in enumerate(md5.new(passcode + path).hexdigest()[:4]):
			if hex_digit >= 'b' and hex_digit <= 'f':
				(letter, vector) = DIRECTIONS[i]
				(new_x, new_y) = (x + vector[0], y + vector[1])
				if new_x >= 0 and new_x < 4 and new_y >= 0 and new_y < 4:
					states_queue.append(((new_x, new_y), path + letter))

	# We've traversed the entire search tree.
	print('PART 2: longest path is {} (length {})'.format(last_path_found, len(last_path_found)))

solve('rrrbmfta')

