extends "res://addons/gut/test.gd"
# This is a GUT test script for your GameManager.
# Extending gut/test.gd gives you test utilities like:
# - assert_eq()
# - add_child_autofree()
# and a test runner that automatically discovers functions starting with "test_...".

const GM_PATH := "res://scripts/game_manager.gd"
# The file path to the GameManager script we want to test.

func _make_gm_with_required_ui() -> Node:
	# Helper function: creates a GameManager instance AND builds the UI nodes
	# it expects to exist so that _process() won't crash.
	#
	# Why do we do this?
	# Because game_manager.gd uses:
	#   $CanvasLayer/ScoreLabel
	#   $CanvasLayer/LevelLabel
	# If those nodes don't exist, calling _process() would throw an error.

	var gm_script: GDScript = load(GM_PATH)
	# load() reads the script file and returns it as a resource we can instantiate.

	var gm: Node = gm_script.new()
	# Create a new instance of the GameManager script.
	# Since game_manager.gd extends Node, this returns a Node.

	add_child_autofree(gm)
	# Add the GameManager to the test scene tree.
	# "autofree" means GUT will remove and free it automatically after the test ends.

	var canvas: CanvasLayer = CanvasLayer.new()
	# Create a CanvasLayer node.
	# CanvasLayer is commonly used to hold UI so it stays on screen.

	canvas.name = "CanvasLayer"
	# Name it exactly "CanvasLayer" so $CanvasLayer/... in the GameManager script can find it.

	gm.add_child(canvas)
	# Add the CanvasLayer as a child of gm.
	# Now gm has a child at path: "CanvasLayer"

	var score_label: Label = Label.new()
	# Create a Label node that will show the score.

	score_label.name = "ScoreLabel"
	# Name it exactly "ScoreLabel" so $CanvasLayer/ScoreLabel works.

	canvas.add_child(score_label)
	# Add ScoreLabel under CanvasLayer, making the path:
	# CanvasLayer/ScoreLabel

	var level_label: Label = Label.new()
	# Create a Label node that will show the level.

	level_label.name = "LevelLabel"
	# Name it exactly "LevelLabel" so $CanvasLayer/LevelLabel works.

	canvas.add_child(level_label)
	# Add LevelLabel under CanvasLayer, making the path:
	# CanvasLayer/LevelLabel

	return gm
	# Return the fully constructed GameManager so tests can interact with it safely.

func test_addPoints_increments_score() -> void:
	# TEST GOAL:
	# Verify that addPoints(points) increases the score correctly.

	var gm: Node = _make_gm_with_required_ui()
	# Create a GameManager instance

	gm.set("score", 0)
	# Force score to 0 to start with a clean known value.
	# gm.set("score", 0) sets the script variable called "score".

	gm.call("addPoints", 3)
	# Call the GameManager method addPoints with 3.
	# Using call() is a dynamic way to call a method by name (string).

	assert_eq(gm.get("score"), 3)
	# Confirm score was incremented to 3.
	# gm.get("score") reads the "score" variable from the script.

func test_process_updates_labels() -> void:
	# TEST GOAL:
	# Verify that _process() updates the ScoreLabel and LevelLabel text correctly.

	var gm: Node = _make_gm_with_required_ui()
	# Create a GameManager instance with required UI nodes.

	gm.set("score", 12)
	# Set score to a test value.

	gm.set("level", 4)
	# Set level to a test value.

	gm.call("_process", 0.016)
	# Call GameManager._process(delta) manually.
	# delta here is ~16ms, which is about one frame at 60 FPS.
	# We do this so the script updates label text right now during the test.

	assert_eq(gm.get_node("CanvasLayer/ScoreLabel").text, "12")
	# Check the score label text was updated to "12".
	# Note: ScoreLabel.text is always a STRING, so we compare to "12", not 12.

	assert_eq(gm.get_node("CanvasLayer/LevelLabel").text, "Level: 4")
	# Check the level label text was updated to exactly "Level: 4".
