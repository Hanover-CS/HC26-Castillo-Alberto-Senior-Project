extends RigidBody2D
# This script is attached to a Brick in a Breakout-style game.
# The Brick is a physics object (RigidBody2D), and it reacts when it gets hit by the ball.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# _ready() runs once when the node is fully in the scene tree.
	# It's commonly used to initialize variables, connect signals, or cache node references.
	pass
	# pass means: "do nothing".
	# So right now, this brick does not need any setup when it spawns.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# _process runs every rendered frame (not fixed like physics).
	# Usually used for animations, UI updates, timers, etc.
	# delta = seconds since last frame (helps make things frame-rate independent).
	pass
	# Currently this brick does not need per-frame logic.

func hit():
	# This function is meant to be called when the ball hits the brick.
	# It's the "brick gets destroyed / reacts" handler.

	GameManager.addPoints(1)
	# Give the player 1 point.
	# GameManager is likely an AutoLoad (singleton) that stores global game state.
	# addPoints(1) updates the score.

	$CPUParticles2D.emitting = true
	# `$NodeName` is shorthand for `get_node("NodeName")`.
	# This turns ON particle emission for a CPUParticles2D child node.
	# So you get a destruction effect (sparks, dust, etc.) when the brick is hit.

	$Sprite2D.visible = false
	# Hide the brick's sprite so it looks like it disappeared immediately.
	# The node still exists in memory right now — we just hide the visuals.

	$CollisionShape2D.disabled = true
	# Disable the brick's collision so the ball won't keep colliding with it.
	# This prevents multiple hits or weird bounce behavior while we wait for timers.

	var bricksLeft = get_tree().get_nodes_in_group('Brick')
	# get_tree() gives you the SceneTree (Godot's global "scene manager").
	# get_nodes_in_group('Brick') returns an array of ALL nodes in the group "Brick".
	# So this collects all bricks that currently exist in the level.

	if (bricksLeft.size() == 1):
		# If there is only 1 brick left in the group,
		# that means THIS brick is the last remaining brick (because we haven't freed it yet).
		# So we're about to finish the level.

		get_parent().get_node("Ball").is_active = false
		# Get the parent node of this brick (likely the level/root node),
		# then find a child node called "Ball",
		# and set its is_active to false to stop ball movement/logic.
		# (This assumes the Ball script has a variable called `is_active`.)

		await get_tree().create_timer(1).timeout
		# Wait 1 second before continuing.
		# create_timer(1) makes a one-shot timer.
		# await ... timeout pauses this function until the timer finishes.
		# This gives time for particles/animation and makes the win feel better.

		GameManager.level += 1
		# Increase the level number in the GameManager.
		# This is global state that can affect difficulty, layout, etc.

		get_tree().reload_current_scene()
		# Reload the current level scene.
		# This is a quick way to "restart" the scene using the next level value.
		# (How the level changes depends on how your game uses GameManager.level.)

	else:
		# If there are still other bricks left after this one,
		# we just destroy this brick and continue the same level.

		await get_tree().create_timer(1).timeout
		# Wait 1 second before deleting the brick.
		# This delay lets particles play even though the sprite is hidden.

		queue_free()
		# Schedule this brick node to be deleted safely.
		# Godot deletes it at the end of the frame so it doesn't break things mid-frame.

	
