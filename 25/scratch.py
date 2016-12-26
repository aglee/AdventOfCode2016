#b = a
#a = 0
#top:
#	c = 2
#	if b == 0 then goto bottom
#	b--
#	c--
#	if c == 1
#		a++
#	goto top
#bottom:

#cpy a b	; set b = a
#cpy 0 a	; set a = 0
#cpy 2 c	; LOOP
#	jnz b 2
#	jnz 1 6
#	dec b
#	dec c
#	jnz c -4
#	inc a	
#jnz 1 -7	; END LOOP
def test(x):
	b = x
	a = 0
	while True:
		c = 2
		while True:
			if b == 0:
				return (x, a, b, c)
			b -= 1
			c -= 1
			if c == 0:
				a += 1
				break

#start = 2539
#count = 20
#for x in range(start, start + count):
#	print(test(x))
print(bin(2538))
print(0b101010101010 - 2538)
