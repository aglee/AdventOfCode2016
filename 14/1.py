import md5
import re

def solve(salt, times_to_hash, verbose):
	def salted_hex(i):
		result = salt + str(i)
		for _ in range(0, times_to_hash):
			result = md5.new(result).hexdigest()
		return result
	
	tripler_pattern = re.compile('(000|111|222|333|444|555|666|777|888|999|aaa|bbb|ccc|ddd|eee|fff)')
	quintupler_pattern = re.compile('(00000|11111|22222|33333|44444|55555|66666|77777|88888|99999|aaaaa|bbbbb|ccccc|ddddd|eeeee|fffff)')
	
	triplers = {}  # digit: [tripler_index]
	key_producing_indexes = []
	index = -1
	WHEN_TO_STOP = 100000
	while True:
		index += 1
		if index >= WHEN_TO_STOP:
			key_producing_indexes.sort()
			print('stopping at index = {} after finding {} key-producing indexes'.format(index, len(key_producing_indexes)))
			print('64th key-producing index is {}'.format(key_producing_indexes[63]))
			return key_producing_indexes[63]

		# See if we contain a triple.
		hex = salted_hex(index)
		triple_match = tripler_pattern.search(hex)
		if triple_match is None:
			continue
		#print('(3) found {} in {} using index {}'.format(triple_match.group(1), hex, index))
		
		# Find all quintuples to see if this is a key.  Handle the case of more than one quintuple in this hex string.
		quint_matches = quintupler_pattern.findall(hex)
		if quint_matches:
			#print('(5) found {} in {} using index {}'.format(quint_matches, hex, index))
			
			for q_digit in map(lambda x: x[0], quint_matches):
				for t_index in triplers[q_digit][:]:
					if index <= t_index + 1000:
						key_producing_indexes.append(t_index)
						if verbose:
							print('{:>2} FOUND KEY [{}] t={}:{} q={}:{}'.format(len(key_producing_indexes), q_digit*3, t_index, salted_hex(t_index), index, salted_hex(index)))
						triplers[q_digit].remove(t_index)
						if len(key_producing_indexes) == 64:
							# Keep looking, because although we have found 64
							# key-producing indexes, we may not have found the
							# 64 *smallest* key-producing indexes.
							WHEN_TO_STOP = index + 1000

		# Remember the triple we found.  Do this *after* checking for quintuples.
		digit = triple_match.group(1)[0]
		indexes = triplers.get(digit)
		if indexes:
			indexes.append(index)
		else:
			indexes = [index]
			triplers[digit] = indexes

seed = 'qzyelonm'  # 'abc' or 'qzyelonm'
verbose = False  # True or False
print('Part 1 answer: {}'.format(solve(seed, 1, verbose)))
print('Part 2 answer: {}'.format(solve(seed, 2017, verbose)))



