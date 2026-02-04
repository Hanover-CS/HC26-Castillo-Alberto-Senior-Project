extends "res://addons/gut/test.gd"
# This file is a unit test script using the GUT testing framework for Godot.
# By extending gut/test.gd, we get access to test helpers like assert_eq(), assert_true(),
# and scene-tree helpers like add_child_autofree().

const BALL_PATH := "res://scripts/ball.gd"
# Path to the Ball script we want to test.
# Using a constant makes it easy to change the path in one place.

class HitBody:
	extends StaticBody2D
	# This is a small "fake" physics object we create for testing collisions.
	# It behaves like something the ball can collide with (StaticBody2D doesn't move).

	var hit_called := false
	# A simple flag we can check in the test to see if hit() was called.

	func hit() -> void:
		# This method matches the "hit" method the Ball looks for.
		# If the ball collides with something that has hit(), it should call it.
		hit_called = true
		# We flip the flag to prove the function was called.

func _make_ball() -> CharacterBody2D:
	# Helper function to create a Ball instance for tests.
	# Underscore prefix usually means "internal helper" (not a test itself).

	var ball_script: GDScript = load(BALL_PATH)
	# load() loads the script resource at runtime using the path.
	# We store it as a GDScript type so we can create an instance from it.

	var ball: CharacterBody2D = ball_script.new()
	# .new() creates an instance of the script.
	# Because ball.gd extends CharacterBody2D, this creates a CharacterBody2D node.

	add_child_autofree(ball)
	# Adds the ball node into the test scene tree.
	# "autofree" means GUT will clean it up automatically after the test finishes
	# so you don't leak nodes between tests.

	return ball
	# Return the newly created ball so the test can inspect and manipulate it.

func test_ready_scales_speed_with_level_and_sets_initial_velocity() -> void:
	# This is a test case: it verifies _ready() behavior in ball.gd.
	# Specifically: speed should scale with GameManager.level and initial velocity should be set.

	GameManager.level = 3
	# Set the level to 3 so when the ball is created, it should initialize with that level.
	# In ball.gd, speed becomes: 200 + 20 * level.

	var ball := _make_ball()
	# Create the ball using the helper, and add it to the scene tree.

	# IMPORTANT: _ready() is called automatically after the node enters the tree.
	await get_tree().process_frame
	# Wait one frame so the engine actually runs _ready() for the ball.
	# Without this, you might read values before _ready() has executed.

	assert_eq(ball.get("speed"), 200 + 20 * 3)
	# ball.get("speed") reads the script variable called "speed".
	# We expect speed to equal 260 when level is 3.

	assert_eq(ball.velocity.x, -(ball.get("speed")))
	# In _ready(), velocity is set to Vector2(speed * -1, speed).
	# So x should be negative speed.

	assert_eq(ball.velocity.y, ball.get("speed"))
	# y should be positive speed.

func test_physics_forces_y_negative_when_small_positive() -> void:
	# This test verifies the "safety fix" in _physics_process:
	# if 0 < velocity.y < 100, the code forces velocity.y = -200.

	var ball := _make_ball()
	# Create ball and add to tree.

	await get_tree().process_frame
	# Wait so _ready() runs (even though this test will overwrite velocity anyway).

	ball.is_active = true
	# Ensure the ball logic is enabled.
	# In ball.gd, _physics_process does nothing unless is_active is true.

	ball.velocity = Vector2(50, 50) # 0 < y < 100
	# Set a velocity where y is small and positive.
	# This should trigger the "force y upward" rule.

	ball._physics_process(1.0/60.0)
	# Call the ball's physics function manually.
	# We pass a realistic delta (about one physics frame at 60fps).

	assert_eq(ball.velocity.y, -200)
	# Confirm the fix applied correctly.

func test_physics_forces_x_negative_when_zero() -> void:
	# This test verifies the other safety fix:
	# if velocity.x becomes exactly 0, force it to -200.

	var ball := _make_ball()
	await get_tree().process_frame

	ball.is_active = true
	# Make sure physics logic runs.

	ball.velocity = Vector2(0, -500)
	# Set x to 0 to trigger the rule.
	# y can be anything; it doesn't matter for this test.

	ball._physics_process(1.0/60.0)
	# Run one physics step manually.

	assert_eq(ball.velocity.x, -200)
	# Confirm the fix applied correctly.

func test_collision_calls_hit_on_collider_with_hit_method() -> void:
	# This test checks collision behavior:
	# If the ball collides with an object that has a hit() method,
	# the ball should call that hit() method.

	var ball := _make_ball()
	await get_tree().process_frame

	ball.is_active = true
	# Enable movement/collision logic.

	# Collision shape for ball
	var ball_shape := CollisionShape2D.new()
	# Create a CollisionShape2D node for the ball so it can collide.

	var circle := CircleShape2D.new()
	# Create a circle shape resource (used by the CollisionShape2D).

	circle.radius = 8
	# Set radius so the ball has a physical size.

	ball_shape.shape = circle
	# Attach the circle shape resource to the CollisionShape2D node.

	ball.add_child(ball_shape)
	# Add the collision shape under the ball so physics knows its collision bounds.

	# Collider that has hit()
	var body := HitBody.new()
	# Create our fake object that has a hit() method.

	add_child_autofree(body)
	# Put it in the scene tree and auto-clean it after the test.

	var body_shape := CollisionShape2D.new()
	# Create a collision shape for the fake body.

	var rect := RectangleShape2D.new()
	# Use a rectangle shape so it's like a flat platform.

	rect.size = Vector2(200, 10)
	# Make it wide and short (like a brick/paddle-ish surface).

	body_shape.shape = rect
	# Assign the rectangle to the CollisionShape2D.

	body.add_child(body_shape)
	# Add collision shape to the body so it can be collided with.

	# Put ball above body, moving down
	ball.global_position = Vector2(0, 0)
	# Place the ball at the top.

	body.global_position = Vector2(0, 20)
	# Place the body below it so the ball will hit it when moving down.

	ball.velocity = Vector2(0, 800)
	# Set velocity so the ball moves downward (positive y).
	# x is 0 so it falls straight down.

	await get_tree().physics_frame
	# Wait for a physics frame so Godot's physics/collision system "catches up"
	# and registers nodes/shapes in the physics world properly.

	ball._physics_process(1.0/60.0)
	# Run one physics tick manually. This should move the ball into the body and collide.

	assert_true(body.hit_called)
	# If collision happened and the ball called hit(), HitBody.hit_called should be true.
