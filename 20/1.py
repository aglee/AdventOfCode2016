import inspect, os

fileDir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
filePath = os.path.join(fileDir, "input.txt")  # "input.txt" or "test.txt"
lines = [line.rstrip('\n') for line in open(filePath)]

# Represent each range of blacklisted addresses as a (min, max) pair.
address_ranges = map(lambda x: map(int, x.split('-')), lines)
#address_ranges = [[5, 8], [0, 2], [4, 7]]

# Sort the ranges in order of increasing min.
sorted_address_ranges = sorted(address_ranges, key = lambda pair: pair[0])

# Construct a new list of ranges that coalesces overlapping ranges
# in sorted_address_ranges.
merged_ranges = []
current_merge = None
for r in sorted_address_ranges:
	if current_merge is None:
		current_merge = r
	elif r[0] <= current_merge[1] + 1:
		# r overlaps current_merge.  But does it *extend* current_merge?
		if r[1] > current_merge[1]:
			# Yes, r extends current_merge.
			current_merge[1] = r[1]
	else:
		merged_ranges.append(current_merge)
		current_merge = r
merged_ranges.append(current_merge)

# Part 1: The lowest non-blocked IP is the number immediately
# after the first merged range.
print('Part 1: lowest allowed IP is {}'.format(merged_ranges[0][1] + 1))

# Part 2: Add up the gaps between successive ranges to get the
# total number of allowed IPs.
merged_ranges.append((4294967296, 4294967296))  # Fictitious range used to cap the end.
total_allowed = 0
for i in range(0, len(merged_ranges) - 1):
	total_allowed += merged_ranges[i+1][0] - merged_ranges[i][1] - 1
print('Part 2: total number of allowed IPs is {}'. format(total_allowed))

