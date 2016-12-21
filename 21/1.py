import inspect, os

def get_input_lines(file_name = "input.txt"):
	file_dir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
	file_path = os.path.join(file_dir, file_name)
	return [line.rstrip('\n') for line in open(file_path)]

def swap_positions(s, x, y):
	if x == y:
		return s[:]
	if x > y:
		(x, y) = (y, x)
	return s[:x] + s[y] + s[(x+1):y] + s[x] + s[y+1:]

def swap_letters(s, x, y):
	return swap_positions(s, s.index(x), s.index(y))

def rotate_left(s, x):
	x = x % len(s)
	return s[x:] + s[:x]

def rotate_right(s, x):
	return rotate_left(s, -x)

def rotate_based_on_letter(s, x):
	pos = s.index(x)
	return rotate_right(s, 1 + pos + (1 if pos >= 4 else 0))

def unrotate_based_on_letter(s, x):
	for i in range(0, len(s)):
		t = rotate_left(s, i)
		if s == rotate_based_on_letter(t, x):
			return t

def reverse_range_inclusive(s, x, y):
	return s[:x] + s[x:y+1][::-1] + s[y+1:]

def move_from_to(s, x, y):
	if x == y:
		return s[:]
	elif x < y:
		#  Moving to the right.
		return s[:x] + s[(x+1):(y+1)] + s[x] + s[y+1:]
	else:
		#  Moving to the left.
		return s[:y] + s[x] + s[y:x] + s[x+1:]

def do_one_operation(s, line, undo = False):
	parts = line.split(' ')
	if (parts[0], parts[1]) == ('swap', 'position'):
		# swap position X with position Y
		s = swap_positions(s, int(parts[2]), int(parts[5]))
	elif (parts[0], parts[1]) == ('swap', 'letter'):
		# swap letter X with letter Y
		s = swap_letters(s, parts[2], parts[5])
	elif (parts[0], parts[1]) == ('rotate', 'left'):
		# rotate left X steps
		if undo:
			s = rotate_right(s, int(parts[2]))
		else:
			s = rotate_left(s, int(parts[2]))
	elif (parts[0], parts[1]) == ('rotate', 'right'):
		# rotate right X steps
		if undo:
			s = rotate_left(s, int(parts[2]))
		else:
			s = rotate_right(s, int(parts[2]))
	elif (parts[0], parts[1]) == ('rotate', 'based'):
		# rotate based on position of letter X
		if undo:
			s = unrotate_based_on_letter(s, parts[6])
		else:
			s = rotate_based_on_letter(s, parts[6])
	elif parts[0] == 'reverse':
		# reverse positions X through Y
		s = reverse_range_inclusive(s, int(parts[2]), int(parts[4]))
	elif parts[0] == 'move':
		# move position X to position Y
		(x, y) = (int(parts[2]), int(parts[5]))
		if undo:
			s = move_from_to(s, y, x)
		else:
			s = move_from_to(s, x, y)
	else:
		print('Could not parse command "{}"'.format(line))
	return s

def scramble(s, input_file_name, verbose = False):
	for line in get_input_lines(input_file_name):
		s = do_one_operation(s, line)
		if verbose:
			print(line)
			print('    ' + s)
	return s

def unscramble(s, input_file_name, verbose = False):
	for line in reversed(get_input_lines(input_file_name)):
		s = do_one_operation(s, line, undo = True)
		if verbose:
			print(line)
			print('    ' + s)
	return s

#print(scramble('abcde', 'test.txt'))  # Should print 'decab'.
#print(unscramble('decab', 'test.txt'))  # Should print 'abcde'.
print('Part 1: ' + scramble('abcdefgh', 'input.txt'))
print('Part 2: ' + unscramble('fbgdceah', 'input.txt'))


