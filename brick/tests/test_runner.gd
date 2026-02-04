extends Node
# This script is a simple custom test runner (your own mini testing framework).
# It runs a list of test functions, tracks pass/fail counts, prints results,
# and exits the game with an exit code (useful for terminal / CI automation).

var passed: int = 0
# Counts how many assertions/tests passed.

var failed: int = 0
# Counts how many assertions/tests failed.

func _ready() -> void:
	# _ready() runs once when this node is added to the scene tree.
	# We use it as the "main entry point" for running tests.

	print("=== Running tests ===")
	# Print a header so the output is easy to read.

	await get_tree().process_frame
	# Wait one frame so the engine is fully initialized.
	# This helps avoid timing issues where scenes/nodes aren't ready yet.

	await run_all()
	# Run all tests (run_all awaits each test function).

	print("=== Done: %d passed, %d failed ===" % [passed, failed])
	# Print summary using string formatting:
	# %d means "integer", and we fill it with passed and failed.

	# Exit code: 0 = OK, 1 = failure (for terminal/CI)
	get_tree().quit(0 if failed == 0 else 1)
	# Quit the game with an exit code:
	# - if failed == 0 => quit(0)  (success)
	# - else => quit(1)            (failure)
	#
	# This is useful for automated pipelines:
	# a terminal/CI system can detect if tests failed by checking exit code.


# ==============
# ASSERT HELPERS
# ==============

func _record_result(ok: bool, message: String) -> void:
	# Internal helper to record pass/fail results and print them nicely.
	# ok = true means pass, ok = false means fail.

	if ok:
		# If the check passed...
		passed += 1
		# Increase the "passed" count.

		print("[PASS] %s" % message)
		# Print a green-ish looking pass line (in text form).

	else:
		# If the check failed...
		failed += 1
		# Increase the "failed" count.

		push_error("[FAIL] %s" % message)
		# push_error prints an error in the Godot output and also shows it
		# in the editor console as an error entry.
		# This makes failures stand out more than a normal print().

func assert_true(condition: bool, message: String) -> void:
	# Public assertion: passes if condition is true, fails otherwise.
	_record_result(condition, message)
	# Simply forward to _record_result using condition as ok/fail.

func assert_equal(actual, expected, message: String) -> void:
	# Public assertion: checks if actual == expected and records the result.

	var ok: bool = (actual == expected)
	# Compare values and store the result (true/false) in ok.

	var full_message := "%s (expected: %s, got: %s)" % [message, str(expected), str(actual)]
	# Build a detailed message so failures show what went wrong.
	# str(...) converts values into text so we can display them.

	_record_result(ok, full_message)
	# Record pass/fail with the detailed message.


# ============
# RUNNER
# ============

func run_all() -> void:
	# This function controls which tests run and in what order.
	# Each test is awaited so they run sequentially (one after another).

	await test_ball_speed_increases_with_level()
	# Run test 1: ball speed scales with level.

	await test_brick_disappears_on_hit()
	# Run test 2: brick becomes invisible + disables collision after hit.


# =========================================
# TEST 1: ball speed increases
#         when the level increases
# =========================================

func test_ball_speed_increases_with_level() -> void:
	# This test checks that higher GameManager.level makes ball.speed higher.

	print("-- test_ball_speed_increases_with_level")
	# Print the test name so the log is easy to follow.

	var ball_scene := preload("res://scenes/ball.tscn")
	# preload loads the Ball scene resource immediately.
	# Using preload is faster and also catches missing file paths early.

	# Level 1
	GameManager.level = 1
	# Set global level to 1.

	var ball_level_1 = ball_scene.instantiate()
	# Create an instance of the ball scene.

	get_tree().root.add_child(ball_level_1)
	# Add it to the scene tree so _ready() will run.
	# (Ball._ready() updates speed based on GameManager.level.)

	await get_tree().process_frame
	# Wait one frame so Ball._ready() executes and sets speed/velocity.

	var speed_level_1: float = ball_level_1.speed
	# Read the ball's speed variable after _ready() has run.

	ball_level_1.queue_free()
	# Schedule the ball for deletion so it doesn't stay in the tree.

	await get_tree().process_frame
	# Wait a frame so the queued free happens cleanly.

	# Level 2
	GameManager.level = 2
	# Set global level to 2.

	var ball_level_2 = ball_scene.instantiate()
	# Instantiate a new ball again (fresh object, new _ready() run).

	get_tree().root.add_child(ball_level_2)
	# Add it to the tree so _ready() triggers.

	await get_tree().process_frame
	# Wait for initialization.

	var speed_level_2: float = ball_level_2.speed
	# Read speed after _ready() has applied level scaling.

	ball_level_2.queue_free()
	# Clean up.

	await get_tree().process_frame
	# Wait for cleanup to complete.

	assert_true(
		speed_level_2 > speed_level_1,
		"Ball speed should increase when level increases"
	)
	# Assertion: level 2 speed should be greater than level 1 speed.
	# If this fails, it means the ball speed is not scaling with level.


# =========================================
# TEST 2: brick disappears when hit
#         (becomes invisible and loses collision)
# =========================================

func test_brick_disappears_on_hit() -> void:
	# This test checks that calling brick.hit() makes it:
	# - hide its Sprite2D (visible=false)
	# - disable its collision (CollisionShape2D.disabled=true)
	#
	# It also avoids triggering the "last brick" branch in brick.gd
	# (because that branch stops the ball and reloads the scene).

	print("-- test_brick_disappears_on_hit")
	# Print test name.

	var brick_scene := preload("res://scenes/brick.tscn")
	# Load the brick scene resource.

	# Create 2 bricks so we DO NOT activate the branch:
	# "last brick" => reloads scene.
	var brick1 = brick_scene.instantiate()
	var brick2 = brick_scene.instantiate()
	# Two bricks exist so brick1 is not the last one when hit() is called.

	get_tree().root.add_child(brick1)
	get_tree().root.add_child(brick2)
	# Add both bricks to the scene tree so their children exist
	# and group queries can find them.

	# Just in case, ensure they are in the "Brick" group.
	brick1.add_to_group("Brick")
	brick2.add_to_group("Brick")
	# Brick.gd checks get_nodes_in_group("Brick") to see how many bricks remain.
	# Adding them here ensures the group logic works even if the scene wasn't configured.

	await get_tree().process_frame
	# Wait one frame so everything is properly added and ready.

	# Simulate the hit by calling hit() directly.
	brick1.hit()
	# This runs the brick logic:
	# - adds points
	# - plays particles
	# - hides sprite
	# - disables collision
	# - may queue_free after a timer (depending on last brick logic)

	await get_tree().process_frame
	# Wait one frame to let immediate property changes apply.
	# (Note: hit() also starts a timer/await inside itself, but the sprite/collision
	# changes happen immediately before the await.)

	var sprite: Sprite2D = brick1.get_node("Sprite2D")
	# Get the Sprite2D child so we can check visibility.

	var collision: CollisionShape2D = brick1.get_node("CollisionShape2D")
	# Get the collision shape so we can check whether collision was disabled.

	assert_true(
		sprite.visible == false,
		"Brick sprite should be invisible after being hit"
	)
	# Verify the brick is visually hidden.

	assert_true(
		collision.disabled == true,
		"Brick collision should be disabled after being hit"
	)
	# Verify the brick no longer collides with the ball.

	brick1.queue_free()
	brick2.queue_free()
	# Clean up bricks after the test.

	await get_tree().process_frame
	# Wait for cleanup to complete.
