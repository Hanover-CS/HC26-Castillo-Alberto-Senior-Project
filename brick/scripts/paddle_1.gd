extends CharacterBody2D

const SPEED := 1000.0

# --- Touch state ---
var touch_active := false
var touch_x := 0.0

func _unhandled_input(event: InputEvent) -> void:
	# Finger touching / dragging on screen
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_active = true
			touch_x = event.position.x
		else:
			touch_active = false

	elif event is InputEventScreenDrag:
		touch_active = true
		touch_x = event.position.x

func _physics_process(delta: float) -> void:
	# If using touch, move paddle toward finger x-position
	if touch_active:
		var target_x := touch_x
		var dx := target_x - global_position.x

		# Convert distance to a velocity, capped by SPEED
		var desired_vx := dx * 10.0  # responsiveness (bigger = snappier)
		desired_vx = clamp(desired_vx, -SPEED, SPEED)

		velocity.x = desired_vx
	else:
		# Keyboard fallback (desktop)
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction != 0.0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0.0, SPEED)

	move_and_slide()
