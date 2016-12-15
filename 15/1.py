def solve(disc_pairs):
	print(disc_pairs)
	
	# We want the solution t to have various values modulo various moduli.
	# Figure out what those values and moduli are.
	desired_mod_values = []
	for i, (modulus, disc_start) in enumerate(disc_pairs):
		# For any given disc, assuming the capsule falls through the ones above
		# it, the capsule is going to fall a distance of t followed by (i + 1).
		desired_value = (modulus - disc_start - (i + 1)) % modulus
		desired_mod_values.append((modulus, desired_value))
		print('we want t % {} == {}'.format(modulus, desired_value))

	# Keep trying successive values of t until we find one that works.
	t = 0
	while True:
		if reduce(lambda x, y: x and y, [t % mod == desired_value for (mod, desired_value) in desired_mod_values]):
			print('answer seems to be {}'.format(t))
			break
		t += 1
	
	# Print some sanity-checking info to convince myself the answer is right.
	for i, (mod, desired) in enumerate(desired_mod_values):
		print('{}: {} % {} == {} (recall {})'.format(i + 1, t, mod, t % mod, disc_pairs[i]))

input = [(13, 1), (19, 10), (3, 2), (7, 1), (5, 3), (17, 5)]
solve(input)
print("")
input.append((11, 0))
solve(input)

