extends CharacterBody2D
# This script is attached to a node that is a CharacterBody2D.
# CharacterBody2D is a Godot node made for things that move with collision/physics.
# It comes with a built-in `velocity` variable and movement helpers like `move_and_slide()`.

const SPEED = 1000.0
# Constant value for paddle movement speed.
# "const" means it won’t change while the game runs.
# 1000.0 is typically interpreted as "pixels per second" in Godot 2D movement logic.

func _physics_process(_delta: float) -> void:
	# This function runs automatically every physics frame.
	# It's the right place to do movement and collision-related updates.
	#
	# delta = time (in seconds) since the last physics frame.
	# Example: at 60 physics FPS, delta is about 0.0167.
	# (Even if we don't use delta here, Godot still gives it to us.)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# ^These two lines below are comments that were already in your file.
	# They mean:
	# - "direction" is derived from player input
	# - It's better to create input actions like "move_left" instead of using "ui_left"
	var direction := Input.get_axis("ui_left", "ui_right")
	# Input.get_axis(left_action, right_action) returns a single float:
	#   - -1.0 when left is pressed
	#   - +1.0 when right is pressed
	#   -  0.0 when neither (or both) are pressed
	#
	# So `direction` becomes a simple "steering wheel":
	# left = -1, right = +1, idle = 0

	if direction:
		# In GDScript, `if direction:` means:
		# "if direction is not zero"
		# So this branch runs when the player is pressing left OR right.

		velocity.x = direction * SPEED
		# We set the horizontal velocity (x-axis) based on direction:
		# If direction = -1, velocity.x = -SPEED  => move left
		# If direction = +1, velocity.x = +SPEED  => move right
		# This does NOT move the object yet — it just sets the velocity used for movement.

	else:
		# This branch runs when direction == 0 (no left/right pressed).

		velocity.x = move_toward(velocity.x, 0, SPEED)
		# move_toward(current, target, step) moves "current" closer to "target"
		# by up to "step" each frame.
		#
		# Here we are saying:
		#   "Reduce horizontal velocity toward 0 so the paddle stops."
		#
		# IMPORTANT nuance:
		# Because step = SPEED (1000), this may stop VERY fast (often instantly).
		# If you want smoother, frame-rate-consistent deceleration, you'd often use:
		#   velocity.x = move_toward(velocity.x, 0, SPEED * delta)

	move_and_slide()
	# This is the line that actually applies movement.
	# It moves the CharacterBody2D according to `velocity`,
	# while also handling collisions and sliding along obstacles.
