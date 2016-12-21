def solve(num, verbose = False):
	elves = [True]*num
	num_surv = num

	def next_surv_index(k):
		while True:
			k = (k+1) % num
			if elves[k]:
				return k

	def add_surv_index(k, incr):
		for _ in range(0, incr):
			k = next_surv_index(k)
		return k
	
	i = 0
	while True:
		elf_to_remove = add_surv_index(i, num_surv/2)
		if verbose:
			print('[{}] {} -- i = {}, elf to remove is {}'.format(num_surv, elves, i+1, elf_to_remove+1))
		elves[elf_to_remove] = False
		num_surv -= 1
		if num_surv > 1:
			i = next_surv_index(i)
		else:
			return i

# The code below lists the first few values of n for which elf #1 wins.
# It uses brute force to calculate the answers, which won't be nearly
# fast enough for n = 3017957.  I noticed that for n > 2, the differences
# between successive n's on this list were tripling: 2, 6, 18, 54, 162, ....

prev_i = 1
for i in range(1, 251):
	answer = solve(i) + 1
	if answer == 1:
		print('answer for {} is {}'.format(i, answer))
		print('    diff is {}'.format(i - prev_i))
		prev_i = i


# The above observation led to the code below, which lists answers in
# base 3.  I noticed that for multiples of powers of 3, i.e. 3^k and
# 2*(3^k), the answer is 3^k:
#
#	answer for 10 is 10
#	answer for 20 is 10
#	answer for 100 is 100
#	answer for 200 is 100
#
# For all other n, the answer could seemingly be gotten by removing
# the first ternary digit of n:
#
#	answer for 11 is 1
#	answer for 12 is 2
#	answer for 21 is 12
#	answer for 22 is 21
#	answer for 101 is 1
#	answer for 102 is 2
#	answer for 110 is 10
#	answer for 111 is 11
#	answer for 112 is 12
#	answer for 120 is 20
#	answer for 121 is 21

def base3(num):
	if num == 0:
		return '0'
	s = ''
	while num > 0:
		digit = num % 3
		num = num / 3
		s = str(digit) + s
	return s

for i in range(1, 82):
	answer = solve(i)+1
	print('answer for {} ({} base 3) is {} ({} base 3)'.format(i, base3(i), answer, base3(answer)))

# I guessed that the above pattern would hold true for all n.  On
# this assumption, I hand-computed an answer, which turned out to
# be correct.  The code below, which computes the same answer, was
# written after the fact.

def solve2(num):
	# Find the largest power of 3 less than num.
	p = 1
	while 3*p < num:
		p *= 3
	# Use this to remove the leftmost ternary digit of num.
	return num % p

def show_answer(num):
	answer = solve2(num)
	print('{} = {} (base 3); answer is {} = {} (base 3)'.format(num, base3(num), answer, base3(answer)))

show_answer(3017957)  # Answer is 1423634.



