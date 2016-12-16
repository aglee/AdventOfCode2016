def bit_list(num):
	bits = []
	n = num
	while n != 0:
		bits.append(n & 1)
		n >>= 1
	return list(reversed(bits))

def bit_string(bit_list):
	return ''.join(map(lambda x: str(x), bit_list))

def checksum_bits(bit_list):
	bits = bit_list[:]
	while len(bits) % 2 == 0:
		new_bits = []
		for i in range(0, len(bits), 2):
			new_bits.append(1 if bits[i] == bits[i+1] else 0)
			#print(bit_string(new_bits))
		bits = new_bits
	return bits

def generate_data(input_num, length_to_fill):
	output = bit_list(input_num)
	while len(output) < length_to_fill:
		output = output + [0] + [1 - x for x in list(reversed(output))]
		#print(bit_string(output))
	return output[:length_to_fill]

#print(bit_string(generate_data(0b10000, 20)))
#print(bit_string(checksum_bits(bit_list(0b110010110100))))

for data_len in [272, 35651584]:  # Parts 1 and 2 of today's challenge.
	data = generate_data(0b11100010111110100, data_len)
	chk = checksum_bits(data)
	print(bit_string(chk))

