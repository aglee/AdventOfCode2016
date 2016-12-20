from math import log, floor

NAME_TO_WATCH = 'X'

def index_to_remove(players):
	return (len(players))/2
	
def display_string(players):
	players_copy = players[:]
	i = index_to_remove(players)
	players_copy[i] = '[' + players_copy[i] + ']'
	return '{}   ({} remaining)'. format(' '.join(players_copy), len(players))

def show_k_iterations(k, players, verbosity = 2):
	if verbosity == 2:
		print(display_string(players))
	for _ in range(0, k):
		ind = index_to_remove(players)
		players = players[1:ind] + players[ind+1:] + players[:1]
		if (verbosity == 2) or (verbosity == 1 and len(players) == 1):
			print(display_string(players))
	print('')

def show_multiple_of_2(k):
	print('Let n = 2k, k = {}, with "{}" at (1-based) position k.'.format(k, NAME_TO_WATCH))
	print('After k iterations "{}" is in the last (kth) position.'.format(NAME_TO_WATCH))
	players = ['_']*(k - 1) + [NAME_TO_WATCH] + ['_']*k
	show_k_iterations(k, players)

def show_multiple_of_3(k):
	print('Let n = 3k, k = {}, with "{}" in the last position.'.format(k, NAME_TO_WATCH))
	print('After k iterations "{}" is at (1-based) position k.'.format(NAME_TO_WATCH))
	players = [str(x + 1) for x in range(0, k)] + ['_']*(2*k - 1) + [NAME_TO_WATCH]
	show_k_iterations(k, players)

# 1-based position of the winning player.
# I wonder if there's a more concise way to express this.
def winning_position(num_players):
	power_of_3 = 3 ** int(floor(log(num_players, 3)))
	r = num_players % power_of_3
	if power_of_3 == num_players:
		return power_of_3
	elif 2*power_of_3 <= num_players:
		return power_of_3 + 2*r
	else:
		return r

def show_whole_game(n, verbosity = 1):
	w = winning_position(n)
	print('Answer for n = {} is {}'.format(n, w))

	players = [str(x + 1) for x in range(0, n)]
	players[w - 1] = NAME_TO_WATCH  # We subtract 1 because w is 1-based.
	show_k_iterations(n - 1, players, verbosity)

show_multiple_of_2(7)
show_multiple_of_3(5)

show_whole_game(5, verbosity = 2)
#show_whole_game(7, verbosity = 2)
#show_whole_game(8, verbosity = 2)
#show_whole_game(9)
#show_whole_game(18)
#show_whole_game(54)
#show_whole_game(55)
#show_whole_game(56)

#for num in range(1, 100):
#	show_whole_game(num, verbosity = 1)

