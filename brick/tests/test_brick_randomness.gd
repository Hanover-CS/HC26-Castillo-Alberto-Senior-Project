extends "res://addons/gut/test.gd"
# This is a GUT test file.
# By extending gut/test.gd, we can write tests and use assertions like assert_true().

const LEVEL_PATH := "res://scripts/level.gd"
# Path to the Level script we want to test.

func _make_level() -> Node2D:
	# Helper function: create a Level instance, add it to the test scene tree,
	# and make sure it gets cleaned up after the test.

	var s: GDScript = load(LEVEL_PATH)
	# load() loads the script resource from disk.

	var l: Node2D = s.new()
	# Create a new instance of that script.
	# Since level.gd extends Node2D, this creates a Node2D node.

	add_child_autofree(l)
	# Add it to the scene tree and auto-free it after the test ends
	# (prevents nodes accumulating between tests).

	return l
	# Return the level instance so tests can call set_seed() and setupLevel().

func _sig(lvl: Node) -> Array:
	# Creates a "signature" for the brick layout.
	# The idea: if two generated levels have the same brick positions,
	# they are effectively the same layout (for our purposes).
	#
	# We return a sorted list of brick positions so we can compare layouts reliably.

	var pos_list: Array = []
	# This array will store the positions of all bricks we find.

	for child in lvl.get_children():
		# Loop through every child node in the level (these include bricks and maybe other nodes).

		if child.is_in_group("Brick"):
			# Only consider nodes that belong to the "Brick" group.
			# In your project, bricks should be added to this group (in the Brick scene).

			var x: int = int(child.position.x)
			# Read the child's x position and convert it to an int.
			# Converting to int removes tiny floating-point differences.

			var y: int = int(child.position.y)
			# Same for y position.

			pos_list.append(Vector2i(x, y))
			# Store the position as a Vector2i (integer vector).
			# This makes comparisons more stable than using floats.

	# Sorting makes the signature stable even if child order changes
	pos_list.sort()
	# The order children were added to the level might differ between runs.
	# Sorting ensures the list is in a consistent order, so comparisons are fair.

	return pos_list
	# Return the final "layout signature": a stable list of brick positions.

func _count(lvl: Node) -> int:
	# Counts how many bricks exist in the level (by checking group membership).

	var n := 0
	# Start our brick count at 0.

	for child in lvl.get_children():
		# Check each child.

		if child.is_in_group("Brick"):
			# Only count it if it is tagged as a brick.

			n += 1
			# Increment brick count.

	return n
	# Return total bricks found.

func test_random_seeds_change_layout() -> void:
	# TEST GOAL:
	# Verify that changing the RNG seed produces a different brick layout.
	# This confirms that set_seed() + rng are actually affecting generation.

	GameManager.level = 3
	# Fix the level so row count stays consistent during this test.
	# We only want to test seed differences here, not level differences.

	var found_difference := false
	# We'll set this to true if we detect at least one seed pair that creates different layouts.

	for seed_a: int in [11, 22, 33, 44, 55]:
		# Try multiple seeds so this test isn't too "fragile" (one bad seed pair won't fail everything).

		var seed_b: int = seed_a + 1000
		# Create a clearly different second seed from seed_a.

		var lvl_a := _make_level()
		# Create level A instance.

		lvl_a.set_seed(seed_a)
		# Force the RNG seed for level A.

		lvl_a.setupLevel()
		# Generate the brick layout for level A.

		var lvl_b := _make_level()
		# Create level B instance.

		lvl_b.set_seed(seed_b)
		# Force the RNG seed for level B.

		lvl_b.setupLevel()
		# Generate the brick layout for level B.

		if _sig(lvl_a) != _sig(lvl_b):
			# Compare the layout signatures.
			# If they differ, the layouts are different.

			found_difference = true
			# We found at least one example where changing the seed changes the layout.

			break
			# Stop early because the test condition has been satisfied.

	assert_true(found_difference)
	# The test passes if we found any difference at least once.
	# If every seed pair somehow produced identical layouts, this fails.

func test_brick_count_changes_with_level() -> void:
	# TEST GOAL:
	# Verify that changing GameManager.level changes the number of bricks generated.
	# This confirms that your setupLevel() logic (rows = 2 + level) impacts output.

	var found_change := false
	# We'll set this to true if we detect any seed where level 1 and level 6
	# produce different brick counts.

	for s: int in [101, 202, 303, 404, 505, 606]:
		# Try multiple seeds to reduce chance of accidental equality.
		# (Random placement might sometimes create same brick count by luck.)

		GameManager.level = 1
		# Set the level low.

		var lvl1 := _make_level()
		# Create a level instance for level 1.

		lvl1.set_seed(s)
		# Use the SAME seed for both levels so randomness is controlled.
		# That way, differences should mostly come from level logic, not random changes.

		lvl1.setupLevel()
		# Generate bricks.

		var c1 := _count(lvl1)
		# Count bricks in the level 1 layout.

		GameManager.level = 6
		# Set the level higher, which should increase rows (up to your cap).

		var lvl6 := _make_level()
		# Create a separate level instance for level 6.

		lvl6.set_seed(s)
		# Use the same seed  again so the random sequence is comparable.

		lvl6.setupLevel()
		# Generate bricks.

		var c6 := _count(lvl6)
		# Count bricks in level 6 layout.

		if c1 != c6:
			# If brick count differs, then level affects generation (as expected).

			found_change = true
			# Mark that we found at least one change.

			break
			# Stop early because the test goal is achieved.

	assert_true(found_change)
	# Pass if we found any seed where brick count differs between level 1 and level 6.
