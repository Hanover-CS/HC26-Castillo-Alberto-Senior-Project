extends CharacterBody2D

const SPEED := 1000.0

var dragging: bool = false
var drag_offset_x: float = 0.0
var active_touch_id: int = -1

func _unhandled_input(event: InputEvent) -> void:
	# Mouse (desktop testing)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_try_start_drag(event.position, -1)
		else:
			_stop_drag(-1)

	elif event is InputEventMouseMotion:
		if dragging and active_touch_id == -1:
			_drag_to(event.position.x)

	# Touch (phone)
	elif event is InputEventScreenTouch:
		if event.pressed:
			_try_start_drag(event.position, event.index)
		else:
			_stop_drag(event.index)

	elif event is InputEventScreenDrag:
		if dragging and event.index == active_touch_id:
			_drag_to(event.position.x)

func _physics_process(_delta: float) -> void:
	if dragging:
		velocity.x = 0.0
	else:
		# Keyboard fallback
		var direction: float = Input.get_axis("ui_left", "ui_right")
		if direction != 0.0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0.0, SPEED)
		move_and_slide()

# --- helpers ---

func _screen_to_world(p: Vector2) -> Vector2:
	# Converts screen/viewport coordinates to world/canvas coordinates (works in Web + mobile)
	return get_viewport().get_canvas_transform().affine_inverse() * p

func _try_start_drag(screen_pos: Vector2, touch_id: int) -> void:
	var world_pos: Vector2 = _screen_to_world(screen_pos)

	if _is_point_on_paddle(world_pos):
		dragging = true
		active_touch_id = touch_id
		drag_offset_x = global_position.x - world_pos.x

func _stop_drag(touch_id: int) -> void:
	if dragging and active_touch_id == touch_id:
		dragging = false
		active_touch_id = -1
		velocity.x = 0.0

func _drag_to(screen_x: float) -> void:
	var world_x: float = _screen_to_world(Vector2(screen_x, 0.0)).x
	global_position.x = world_x + drag_offset_x

func _is_point_on_paddle(world_pos: Vector2) -> bool:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var params: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	params.position = world_pos
	params.collide_with_bodies = true
	params.collide_with_areas = true

	var hits: Array[Dictionary] = space_state.intersect_point(params, 8)
	for h: Dictionary in hits:
		var col: Object = h.get("collider")
		if col == self:
			return true
	return false
