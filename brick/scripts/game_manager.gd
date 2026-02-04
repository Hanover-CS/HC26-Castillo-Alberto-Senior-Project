extends Node
# GameManager is a "global state" script for things like score and level.
# In many Godot projects, this is set up as an AutoLoad (Singleton),
# so other scripts can access it as `GameManager`.

var score = 0
# The player's current score.
# This value increases when you hit bricks (or do other scoring actions).

var level = 1
# The current level number.
# This increases when you clear the bricks and move to the next level.

func addPoints(points):
	# Adds a number of points to the score.
	# `points` is expected to be an integer (like 1, 5, 10).
	# Example: addPoints(1) increases score by 1.

	score += points
	# Shorthand for: score = score + points

func _process(_delta: float) -> void:
	# Runs every rendered frame (can be 60 FPS, 144 FPS, etc.).
	# This is used here to update the UI labels every frame so the player
	# always sees the latest score and level.
	# delta = seconds since the last frame (unused here, but Godot provides it).

	$CanvasLayer/ScoreLabel.text = str(score)
	# short for get_node("CanvasLayer/ScoreLabel").
	# This line updates the ScoreLabel UI text to show the current score.
	# str(score) converts the integer score into a string (text) for the label.

	$CanvasLayer/LevelLabel.text = "Level: " + str(level)
	# Updates the LevelLabel UI text to show the current level.
	# This builds a string like "Level: 3" by concatenating:
	# - the text "Level: "
	# - plus the level number converted to a string.
