def solve(disc_pairs):
	print(disc_pairs)
	mod_values_of_t = []
	for i, (modulo, disc_start) in enumerate(disc_pairs):
		mod_value = (modulo - disc_start - i - 1) % modulo
		mod_values_of_t.append(mod_value)
		print('we want t = {} mod {}'.format(mod_value, modulo))

	all_modulos = map(lambda x: x[0], disc_pairs)
	product_of_modulos = reduce(lambda x, y: x*y, all_modulos)
	print('product_of_modulos = {}'.format(product_of_modulos))
	num_list = [x for x in range(product_of_modulos)]
	for i, (modulo, disc_start) in enumerate(disc_pairs):
		mod_value = (modulo - disc_start - i - 1) % modulo
		for k in range(0, product_of_modulos):
			if k % modulo != mod_value:
				num_list[k] = None
	filtered_list = [x for x in num_list if x is not None]
	answer = filtered_list[0]
	print('{} numbers remain in list, list begins with {}'.format(len(filtered_list), filtered_list[:6]))
	for i, modulo in enumerate(all_modulos):
		print('{}: answer = {} mod {} (recall {})'.format(i + 1, answer % modulo, modulo, disc_pairs[i]))

input = [(13, 1), (19, 10), (3, 2), (7, 1), (5, 3), (17, 5)]
solve(input)
print("")
input.append((11, 0))
solve(input)






