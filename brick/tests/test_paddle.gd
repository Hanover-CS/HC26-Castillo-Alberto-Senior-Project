extends "res://addons/gut/test.gd"
# This is a GUT unit test file for the Paddle script (paddle_1.gd).
# Extending gut/test.gd gives us assertion functions (assert_gt, assert_lt, etc.)
# and helpers like add_child_autofree().

const PADDLE_PATH := "res://scripts/paddle_1.gd"
# Path to the Paddle script we want to test.

# Used floats for everything to stop getting warning
# This comment means: you intentionally use float numbers like 0.0, 500.0, 1.0/60.0
# to avoid type warnings in Godot (because some values are floats in physics).

func _make_paddle() -> CharacterBody2D:
	# Helper function: create a Paddle instance and add it to the test scene tree.

	var paddle_script: GDScript = load(PADDLE_PATH)
	# load() loads the Paddle script resource from disk.

	var paddle: CharacterBody2D = paddle_script.new()
	# Create a new instance of the paddle script.
	# Since paddle_1.gd extends CharacterBody2D, this returns a CharacterBody2D node.

	add_child_autofree(paddle)
	# Add it to the scene tree for the test.
	# add_child_autofree also ensures it is freed automatically after the test ends.

	return paddle
	# Return the paddle so the test can simulate input and inspect velocity.

func after_each() -> void:
	# GUT calls after_each() after every test function in this file.
	# We use it to clean up global state so tests don't affect each other.
	#
	# Here, the global state is input actions being "pressed".
	# If we press a key in one test and forget to release it,
	# the next test might start with the key still pressed and fail.

	if Input.is_action_pressed("ui_left"):
		# Check if the left action is currently considered pressed.
		Input.action_release("ui_left")
		# Force release it to reset state.

	if Input.is_action_pressed("ui_right"):
		# Same for right action.
		Input.action_release("ui_right")
		# Force release it too.

func test_pressing_right_sets_positive_velocity() -> void:
	# TEST GOAL:
	# If we press "ui_right" and run one physics step,
	# the paddle's horizontal velocity should become positive (moving right).

	var paddle := _make_paddle()
	# Create a paddle instance.

	Input.action_press("ui_right")
	# Simulate pressing the right input action.
	# This makes Input.get_axis("ui_left", "ui_right") return +1.

	paddle._physics_process(1.0 / 60.0)
	# Manually call the paddle's physics loop once.
	# delta = 1/60 seconds simulates one physics tick at 60 FPS.

	assert_gt(paddle.velocity.x, 0.0)
	# assert_gt means "assert greater than".
	# This passes if paddle.velocity.x > 0.0 (moving right).

func test_pressing_left_sets_negative_velocity() -> void:
	# TEST GOAL:
	# If we press "ui_left" and run one physics step,
	# the paddle's horizontal velocity should become negative (moving left).

	var paddle := _make_paddle()
	# Create paddle.

	Input.action_press("ui_left")
	# Simulate pressing left.
	# This makes Input.get_axis(...) return -1.

	paddle._physics_process(1.0 / 60.0)
	# Run one physics tick.

	assert_lt(paddle.velocity.x, 0.0)
	# assert_lt means "assert less than".
	# This passes if paddle.velocity.x < 0.0 (moving left).

func test_no_input_moves_velocity_toward_zero() -> void:
	# TEST GOAL:
	# If there is no input, the paddle code should move velocity.x toward 0
	# (it should slow down / stop).
	#
	# We set velocity.x to something positive and then run one physics tick.
	# After that, velocity.x should be smaller than it was.

	var paddle := _make_paddle()
	# Create paddle.

	Input.action_release("ui_left")
	Input.action_release("ui_right")
	# Make sure no input is pressed.
	# (Even though after_each() releases input, we do it here again to be explicit.)

	paddle.velocity.x = 500.0
	# Force paddle to start with some horizontal speed.

	paddle._physics_process(1.0 / 60.0)
	# Run one physics tick with no input.
	# In paddle_1.gd, this triggers the "else" branch using move_toward()
	# which should reduce velocity.x toward 0.

	assert_lt(paddle.velocity.x, 500.0)
	# Verify it slowed down at least a little.
	# If it's still 500.0, then move_toward() logic didn't run.
