extends "res://addons/gut/test.gd"
# This is a GUT unit test file for your Level generator (level.gd).
# Extending GUT's base test class gives you assertions and test helpers.

const LEVEL_PATH := "res://scripts/level.gd"
# Path to the script we are testing.

func make_level_with_seed(seed_value: int) -> Node2D:
	# Helper function: creates a Level instance, sets its seed, adds it to the tree,
	# and then the caller can wait a frame so _ready() runs.
	#
	# This helps avoid duplicating boilerplate code in every test.

	var script: GDScript = load(LEVEL_PATH)
	# load() fetches the script resource from disk.

	var lvl: Node2D = script.new()
	# Instantiate a new Level node from the script.
	# Because level.gd extends Node2D, this returns a Node2D.

	# IMPORTANT: seed BEFORE adding to tree so _ready uses it
	lvl.set_seed(seed_value)
	# We set the RNG seed BEFORE the node enters the scene tree.
	# Why? Because in level.gd, _ready() calls setupLevel().
	# If we seeded AFTER adding to the tree, _ready() might generate bricks using a random seed.

	add_child_autofree(lvl)
	# Add to the test scene tree so Godot will call its _ready().
	# autofree means GUT will remove/free it automatically after the test.

	# wait for _ready() to run and generate bricks once
	return lvl
	# We return immediately. The test will `await get_tree().process_frame`
	# to allow _ready() to execute and bricks to spawn.

func count_bricks(lvl: Node) -> int:
	# Helper function: counts how many brick nodes exist under the level.
	# It uses group membership, so your brick scene must be in group "Brick".

	var n := 0
	# Start count at 0.

	for child in lvl.get_children():
		# Loop through all direct children of the level node.

		if child.is_in_group("Brick"):
			# Only count children that are in the "Brick" group.
			# This is how your level tests identify bricks reliably.

			n += 1
			# Increment the count.

	return n
	# Return total bricks found.

func test_same_seed_same_brick_count() -> void:
	# TEST GOAL:
	# If we generate the level twice with the SAME seed and SAME GameManager.level,
	# we expect the brick generation randomness to be identical,
	# resulting in the same number of bricks.

	GameManager.level = 3
	# Fix level to 3 so rows/difficulty stays the same for both runs.

	var a := make_level_with_seed(123)
	# Create level A with seed 123.

	await get_tree().process_frame
	# Wait a frame so Godot runs _ready() for this node,
	# which will generate bricks automatically.

	var ca := count_bricks(a)
	# Count how many bricks were created.

	var b := make_level_with_seed(123)
	# Create level B with the same seed.

	await get_tree().process_frame
	# Again, wait so _ready() runs and bricks spawn.

	var cb := count_bricks(b)
	# Count bricks for the second level.

	assert_eq(ca, cb)
	# Assert both counts match.
	# If this fails, it suggests the generation is not deterministic with the same seed.

func test_different_seed_usually_changes_brick_count() -> void:
	# TEST GOAL:
	# Using different seeds should *usually* change the generated level.
	# Because generation is random, we don't require it to always differ,
	# but we try a few seed pairs and expect at least one difference.

	GameManager.level = 3
	# Keep level fixed so only the seed affects output.

	var changed := false
	# We'll set this to true if we find at least one seed pair that changes brick count.

	for seed_a: int in [10, 20, 30, 40, 50]:
		# Try several different seeds to avoid flakiness.
		# (Sometimes different seeds can coincidentally produce the same count.)

		var seed_b: int = seed_a + 999
		# Pick a very different seed value.

		var a := make_level_with_seed(seed_a)
		# Create level A with seed_a.

		await get_tree().process_frame
		# Wait for _ready() to generate bricks.

		var ca := count_bricks(a)
		# Count bricks.

		var b := make_level_with_seed(seed_b)
		# Create level B with seed_b.

		await get_tree().process_frame
		# Wait for _ready().

		var cb := count_bricks(b)
		# Count bricks.

		if ca != cb:
			# If the brick count differs, it strongly suggests the seed affects generation.

			changed = true
			# Mark that we found a seed pair that changes output.

			break
			# Stop early because the test condition is satisfied.

	assert_true(changed)
	# The test passes if we found at least one seed pair where counts differ.
	# If not, it suggests seeds might not be affecting generation, or randomness is broken.

func test_bricks_spawn_on_grid() -> void:
	# TEST GOAL:
	# Verify that bricks spawn aligned to the expected grid.
	# Your level.gd places bricks at:
	#   x = margin + (34 * column)
	#   y = margin + (34 * row)
	# So (x - margin) and (y - margin) should be multiples of 34.

	GameManager.level = 2
	# Set a level value (doesn't matter much here, but ensures consistent setup).

	var lvl := make_level_with_seed(7)
	# Create a level with a known seed.

	await get_tree().process_frame
	# Wait so _ready() runs and bricks are generated.

	var margin: int = int(lvl.margin)
	# Read the level's margin variable and convert to int.
	# We use int because positions are often floats in Godot.

	var found := false
	# We'll set this true if we find at least one brick.
	# This prevents the test from passing without actually checking anything.

	for child in lvl.get_children():
		# Look through children to find a brick.

		if child.is_in_group("Brick"):
			# Found a brick.

			found = true
			# Mark that we actually found something to test.

			var x := int(child.position.x)
			# Convert x position to int to avoid tiny floating-point issues.

			var y := int(child.position.y)
			# Convert y position to int too.

			assert_eq((x - margin) % 34, 0)
			# Check that x aligns to the grid:
			# (x - margin) should be divisible by 34 with no remainder.

			assert_eq((y - margin) % 34, 0)
			# Same check for y.

			break
			# We only need to verify one brick to prove the rule is being followed.

	assert_true(found)
	# Ensure we actually found at least one brick.
	# If no bricks were spawned (rare but possible with randomness),
	# we fail the test so it doesn't silently do nothing.
