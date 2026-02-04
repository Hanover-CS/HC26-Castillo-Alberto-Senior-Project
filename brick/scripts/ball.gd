extends CharacterBody2D
# This script is attached to the Ball.
# CharacterBody2D is a Godot node type designed for moving objects that use a `velocity`
# and collide with the world using helpers like move_and_collide() / move_and_slide().

var speed = 200
# Base speed for the ball (will be increased based on the current level).

var dir = Vector2.DOWN
# Initial direction (Vector2.DOWN = (0, 1)).
# IMPORTANT: In THIS script, `dir` is never used after being declared.
# So it currently has no effect on movement (velocity drives movement instead).

var is_active = true
# A flag to pause/resume the ball.
# If is_active is false, the ball will not move or process collisions.

func _ready() -> void:
	# Called once when the Ball enters the scene tree.
	# Good place to initialize values before gameplay starts.

	speed = speed + (20 * GameManager.level)
	# Increase speed depending on the level:
	# level 1 => 200 + 20 = 220
	# level 2 => 200 + 40 = 240
	# etc.
	# GameManager is likely an AutoLoad (global singleton) that stores game state.

	velocity = Vector2(speed * -1, speed)
	# Set the initial velocity (movement per second) of the ball:
	# x = -speed => start moving left
	# y =  speed => start moving down
	# Example: speed = 220 => velocity = (-220, 220)

func _physics_process(delta: float) -> void:
	# Runs every physics tick (fixed timestep).
	# This is the correct place for movement and collision logic.

	if is_active:
		# Only move if the ball is active.
		# If a level is completed, other scripts can set is_active = false.

		var collision = move_and_collide(velocity * delta)
		# move_and_collide() expects a *movement amount for this frame* (a displacement),
		# not a raw velocity. That’s why we multiply by delta:
		# - velocity is "pixels per second"
		# - delta is "seconds since last physics frame"
		# => velocity * delta becomes "pixels to move this frame"
		#
		# If a collision happens, this returns a collision object with details.
		# If no collision happens, it returns null.

		if collision:
			# If we hit something...

			velocity = velocity.bounce(collision.get_normal())
			# Reflect the velocity vector using the collision surface normal.
			# This is what makes the ball "bounce" off walls/paddle/bricks.

			if collision.get_collider().has_method("hit"):
				# get_collider() returns the object we collided with (brick, paddle, wall, etc.).
				# has_method("hit") checks if that object has a function named hit().
				# This is a simple way to interact with different objects without hard-coding types.

				collision.get_collider().hit()
				# If the collider supports hit(), call it.
				# For example, Brick.gd has hit() and will add points + remove itself.

		if (velocity.y > 0 and velocity.y < 100):
			# "Safety fix" to prevent the ball from moving downward too slowly.
			# Condition:
			# - velocity.y > 0 means it's moving down
			# - velocity.y < 100 means it's moving down too slowly (almost horizontal)

			velocity.y = -200
			# Force a strong upward vertical component so the ball doesn't get stuck
			# in long shallow bounces that feel boring or buggy.

		if velocity.x == 0:
			# Another safety fix: if the horizontal component becomes exactly 0,
			# the ball would move straight up/down forever.

			velocity.x = -200
			# Force some horizontal movement to keep gameplay dynamic.

func gameOver():
	# Resets global game state and restarts the current scene.
	# Called when the ball falls into the "death zone".

	GameManager.score = 0
	# Reset score back to 0.

	GameManager.level = 1
	# Reset level back to 1.

	get_tree().reload_current_scene()
	# Reload the current scene (restart the level).

func _on_deathzone_body_entered(_body: Node2D) -> void:
	# This is usually connected to an Area2D signal: body_entered(body).
	# It triggers when a physics body enters the Deathzone area.
	#
	# `_body` is the body that entered the area (likely the ball).
	# The underscore means: "I receive it but I'm not using it."

	gameOver()
	# When the ball enters the deathzone, reset and restart.
