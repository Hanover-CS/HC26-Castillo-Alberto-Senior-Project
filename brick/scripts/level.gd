extends Node2D
# This script is attached to a Level node (2D scene root for the breakout level).
# Its main job is to spawn a grid of bricks and color them depending on the row and level.

@onready var brickObject = preload("res://scenes/brick.tscn")
# `preload()` loads the resource at parse time (when the script is loaded), not later.
# Here we preload the Brick scene (a .tscn) so we can instantiate (spawn) bricks quickly.
# `@onready` means: this variable gets assigned when the node is ready (after entering the tree).
# (In this case, preload is already immediate; @onready isn't strictly necessary but it's fine.)

var columns = 32
# Number of bricks per row (grid width).

var rows = 7   
# Default number of rows (grid height). This gets overridden based on GameManager.level.

var margin = 50
# Pixel offset from the top-left corner of the level.
# Used so bricks don't spawn right at (0,0) and overlap UI/borders.

# Level-local RNG (seedable for tests)
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
# Create a random number generator instance that belongs to this level.
# Keeping RNG "local" is nice because:
# - You can control randomness per level
# - You can seed it for predictable testing (same layout every time)

func _ready() -> void:
	# Called once when this level node enters the scene tree.
	# Good place to initialize RNG and build the level.

	# If not seeded yet, randomize for normal gameplay
	if rng.seed == 0:
		# If the RNG seed is still 0, we treat it as "not set yet".
		# (This is your convention: 0 means "no custom seed was provided".)

		rng.randomize()
		# randomize() sets the seed using the current time / system randomness,
		# so brick layout differs each run.

	setupLevel()
	# Build the bricks for the current level.

func set_seed(seed_value: int) -> void:
	# Allows external code (tests, menu, debug tools) to force a specific seed.
	# When you set the seed, the RNG will produce the same sequence of numbers each time.

	rng.seed = seed_value
	# Assign the seed. Same seed => same random pattern => reproducible brick layouts.

func setupLevel() -> void:
	# This function creates the brick layout for the current level.

	rows = 2 + GameManager.level
	# Scale difficulty: as level increases, you get more rows of bricks.
	# Level 1 => 3 rows, Level 2 => 4 rows, etc.

	if rows > 9:
		rows = 9
		# Cap rows at 9 so the level doesn't become too tall / impossible / off-screen.

	var colors: Array[Color] = getColors()
	# Fetch the base list of colors used for brick tinting.

	_shuffle_colors(colors)
	# Randomize the order of colors (so each level can have a different palette order).
	# This uses your level-local RNG, so it respects seeding.

	for r in range(rows):
		# Loop through each row index (0 to rows-1).

		for c in range(columns):
			# Loop through each column index (0 to columns-1).

			var random_number: int = rng.randi_range(0, 2)
			# Generate an integer random number between 0 and 2 inclusive.
			# Possible values: 0, 1, 2

			if random_number > 0:
				# This means: only spawn a brick if the number is 1 or 2.
				# So bricks spawn about 2/3 of the time, leaving gaps 1/3 of the time.

				var new_brick: Node2D = brickObject.instantiate()
				# Create (instantiate) a new brick node from the brick scene.

				add_child(new_brick)
				# Add the brick to the level so it becomes part of the scene tree.
				# Now it will render, collide, and run its own scripts.

				new_brick.get_node("Sprite2D").scale = Vector2(0.5, 0.5)
				# Get the brick's Sprite2D child and scale it down to half size.
				# This changes how big it looks (and likely affects spacing decisions too).

				new_brick.position = Vector2(margin + (34 * c), margin + (34 * r))
				# Position the brick in a grid:
				# - x increases by 34 pixels each column
				# - y increases by 34 pixels each row
				# margin offsets everything away from the edges.

				var sprite: Sprite2D = new_brick.get_node("Sprite2D")
				# Cache the sprite reference so we can set its tint color (modulate).

				if r <= 9:
					sprite.modulate = colors[0]
					# For essentially all rows (since r will be <= 8 due to rows cap),
					# set the default color to colors[0].

				if r < 6:
					sprite.modulate = colors[1]
					# For rows 0..5, overwrite the previous color with colors[1].
					# This creates a "color band" for the top portion of the bricks.

				if r < 3:
					sprite.modulate = colors[2]
					# For rows 0..2, overwrite again with colors[2].
					# So the very top rows get a different color.
					# Final effect:
					# - r 0..2 => colors[2]
					# - r 3..5 => colors[1]
					# - r 6..8 => colors[0]
					# Note: colors[3] is never used in your current logic.

func _process(_delta: float) -> void:
	# Called every rendered frame.
	# `_delta` is unused here (underscore means "intentionally unused").
	pass
	# No per-frame behavior needed for the level spawner right now.

func getColors() -> Array[Color]:
	# Returns an array of Color objects used for brick tints.
	# Color(r, g, b, a) uses floats from 0 to 1:
	# - r: red amount
	# - g: green amount
	# - b: blue amount
	# - a: alpha (opacity)

	return [
		Color(0, 1, 1, 1),
		# Cyan (no red, full green, full blue)

		Color(0.54, 0.17, 0.89, 1),
		# Purple-ish (mix of red/blue)

		Color(0.68, 1, 0.18, 1),
		# Lime-green/yellow-ish

		Color(1, 1, 1, 1)
		# White
		# NOTE: this 4th color exists but your current assignment logic never uses colors[3].
	]

func _shuffle_colors(colors: Array[Color]) -> void:
	# Shuffles the given colors array in-place (it modifies the same array you pass in).
	# This uses the Fisher–Yates shuffle algorithm, which is a standard fair shuffle.
	# Important: it uses THIS level's rng, so if you seed rng, the shuffle is repeatable too.

	# Fisher–Yates shuffle using this level's rng
	for i in range(colors.size() - 1, 0, -1):
		# Iterate backwards from last index down to 1.
		# Example: if size is 4, i goes 3, 2, 1.

		var j: int = rng.randi_range(0, i)
		# Pick a random index j between 0 and i inclusive.

		var tmp: Color = colors[i]
		# Save colors[i] temporarily.

		colors[i] = colors[j]
		# Move colors[j] into slot i.

		colors[j] = tmp
		# Put the saved color into slot j.
		# Result: each element has a fair chance to end up anywhere.
