# Proof

Informal proof of the following algorithm for solving part 2.  This is a corrected form of the algorithm I used to get the answer.  My original algorithm was not correct in all cases, though it was correct for my specific case.

```python
def winning_position(num_players):
	power_of_3 = 3 ** int(floor(log(num_players, 3)))
	r = num_players % power_of_3
	if power_of_3 == num_players:
		return power_of_3  # See "Case 1" below.
	elif power_of_3 + r == num_players:
		return r  # See "Case 2" below.
	else:
		return power_of_3 + 2*r  # See "Case 3" below.
```

I suspect there is a more concise way to express this in code.  I also wouldn't be surprised if there's a shorter proof.  I won't prove everything in detail; I'll rely on illustrative examples and leave things as exercises for the reader.

We'll notate the circle of players by listing them by name on one line of text.  The first player on the list is the one whose turn it is to steal from another player.  Each player is rotated to the end of the list after their turn.  Square brackets will show which player is about to be stolen from.

Each player's name is one of the following:

- A number indicating their original (1-based) position.
- A generic '_'.
- The special name 'X' when we want to track a particular player over time.

Example where n = 5:

<pre>
1 X [3] 4 5   (5 remaining)
X 4 [5] 1   (4 remaining)
4 [1] X   (3 remaining)
X [4]   (2 remaining)
[X]   (1 remaining)
</pre>

**Claim 1 (`n = 2k`): Suppose n = 2k and player X starts at position k (just before the halfway point in the list).  After k iterations, X will again be at the end of the list (now at position k).**

Here is an example that helps visualize this claim:

<pre>
Let n = 2k, k = 7, with "X" at (1-based) position k.
After k iterations "X" is in the last (kth) position.
_ _ _ _ _ _ X [_] _ _ _ _ _ _   (14 remaining)
_ _ _ _ _ X [_] _ _ _ _ _ _   (13 remaining)
_ _ _ _ X _ [_] _ _ _ _ _   (12 remaining)
_ _ _ X _ [_] _ _ _ _ _   (11 remaining)
_ _ X _ _ [_] _ _ _ _   (10 remaining)
_ X _ _ [_] _ _ _ _   (9 remaining)
X _ _ _ [_] _ _ _   (8 remaining)
_ _ _ [_] _ _ X   (7 remaining)
</pre>

You can see that because X starts in the first half of the list, it stays in the first half of the list until being rotated to the end.

**Claim 2 (`n = 3k`): Suppose n = 3k and player X starts at the end of the list (in position n).  After 2k iterations X will again be at the end of the list (now at position k).**

It suffices to show that after k iterations we have the situation described in Claim 1.  Here is an example that helps show this is true:

<pre>
Let n = 3k, k = 5, with "X" in the last position.
After k iterations "X" is at (1-based) position k.
1 2 3 4 5 _ _ [_] _ _ _ _ _ _ X   (15 remaining)
2 3 4 5 _ _ _ [_] _ _ _ _ X 1   (14 remaining)
3 4 5 _ _ _ [_] _ _ _ X 1 2   (13 remaining)
4 5 _ _ _ _ [_] _ X 1 2 3   (12 remaining)
5 _ _ _ _ [_] X 1 2 3 4   (11 remaining)
_ _ _ _ X [1] 2 3 4 5   (10 remaining)
</pre>

Note how the first k players have been rotated in order to the end of the list.

**Claim 3 (`n = 3**k`): Suppose n is a power of 3.  Then n is the winning position for the whole game.**

This follows from Claim 2.  Suppose player X starts at the end of the list.  Each time the list is shortened by exactly 2/3, X will again be at the end of the list.  This will continue to be true until the list only has 1 element, namely X.

Now: what is the winning position for any arbitrary n?

Let p be the largest power of 3 that does not exceed n.  Let r = n mod p.  Then there are 3 possible cases:

**Case 1: n = p.  The winning position is n.**

This follows immediately from Claim 3.

**Case 2: n = p + r, r != 0.  The winning position is r.**

Suppose player X starts at position r.  The r'th iteration will rotate X to the end of the list.  At that point, r players will have been removed, so the number of players remaining will be a power of 3, and Claim 3 tells us X will win.

This is really the same as Case 1.  In Case 1, r = 0 = n mod n.

**Case 3: n = 2p + r.  The winning position is p+2r.**

Suppose player X starts at position p+2r.  With each of the first r iterations, X's position decreases by two -- one because of a player being eliminated, and one because the first player in the list gets rotated to the end.  Thus after r iterations, X is at position p among a list of 2p players.  Claim 1 tells us that after p more iterations the list will contain p players with X again at the end.  Claim 3 tells us X will be the winner.

QED
