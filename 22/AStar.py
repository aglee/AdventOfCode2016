# Abstract class that implements the A* search algorithm.
class AStar(object):
	# The search algorithm.
	def search(self, start):
		self.set_g_score(start, 0)
		self.set_f_score(start, self.h_score(start))
		self.add_to_frontier(start)
		
		while not self.frontier_is_empty():
			current = self.pop_from_frontier()
			if self.meets_goal(current):
				return self.path_from_start(current)

			self.add_to_closed_set(current)
			
			neighbors = self.get_neighbors(current)
			for (neighbor, distance_to_neighbor) in neighbors:
				# Case 1: The neighbor was previously popped from the frontier; skip it.
				if self.is_in_closed_set(neighbor):
					continue

				# Case 2: The neighbor was never in the frontier; add it.
				g = self.g_score(current) + distance_to_neighbor
				if not self.is_in_frontier(neighbor):
					self.set_g_score(neighbor, g)
					self.set_f_score(neighbor, g + self.h_score(neighbor))
					self.set_parent(neighbor, current)
					self.add_to_frontier(neighbor)
					continue
				
				# Case 3: The neighbor is currently in the frontier; see if
				# we can improve its G score.
				if g < self.g_score(neighbor):
					self.set_g_score(neighbor, g)
					self.set_f_score(neighbor, g + self.h_score(neighbor))
					self.set_parent(neighbor, current)

	# The following methods must all be overridden.

	# The search termination condition.
	def meets_goal(self, search_node): return None
	
	# Expanding the frontier.  Returns list of (neighbor, distance_to_neighbor) pairs.
	def get_neighbors(self, search_node): return None

	# The various scores -- h(n), g(n), f(n).
	def h_score(self, search_node): return None
	def g_score(self, search_node): return None
	def set_g_score(self, search_node, score): return None
	def f_score(self, search_node): return None
	def set_f_score(self, search_node, score): return None

	# The frontier aka fringe aka open set.  A min heap ordered by F score.
	def frontier_is_empty(self): return None
	def add_to_frontier(self, search_node): return None
	def pop_from_frontier(self): return None
	def is_in_frontier(self, search_node): return None

	# The closed set aka interior.
	def add_to_closed_set(self, search_node): return None
	def is_in_closed_set(self, search_node): return None

	# Reconstructing the path from the start node to the winning node.
	def parent(self, search_node): return None
	def set_parent(self, search_node, parentNode): return None
	def path_from_start(self, search_node): return None

