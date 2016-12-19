# I recognized this problem.  The formula for the solution is to
# move the first 1-bit of n to the end.

def leftmost_1(num):
	result = 0
	for shift in range(0, 64):
		if num & (1<<shift) != 0:
			result = (1<<shift)
	return result

def solve(num):
	left_bit = leftmost_1(num)
	num_without_left_bit = num & (~leftmost_1(num))
	return (num_without_left_bit << 1) | 1

#print(solve(5))  # Should say 3.
print(solve(3017957))
