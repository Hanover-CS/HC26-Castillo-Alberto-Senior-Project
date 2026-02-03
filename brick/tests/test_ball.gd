extends "res://addons/gut/test.gd"

const BALL_PATH := "res://scripts/ball.gd"

class HitBody:
	extends StaticBody2D
	var hit_called := false
	func hit() -> void:
		hit_called = true

func _make_ball() -> CharacterBody2D:
	var ball_script: GDScript = load(BALL_PATH)
	var ball: CharacterBody2D = ball_script.new()
	add_child_autofree(ball)
	return ball

func test_ready_scales_speed_with_level_and_sets_initial_velocity() -> void:
	GameManager.level = 3
	var ball := _make_ball()

	# IMPORTANT: _ready() is called automatically after the node enters the tree.
	await get_tree().process_frame

	assert_eq(ball.get("speed"), 200 + 20 * 3)
	assert_eq(ball.velocity.x, -(ball.get("speed")))
	assert_eq(ball.velocity.y, ball.get("speed"))

func test_physics_forces_y_negative_when_small_positive() -> void:
	var ball := _make_ball()
	await get_tree().process_frame

	ball.is_active = true
	ball.velocity = Vector2(50, 50) # 0 < y < 100
	ball._physics_process(1.0/60.0)

	assert_eq(ball.velocity.y, -200)

func test_physics_forces_x_negative_when_zero() -> void:
	var ball := _make_ball()
	await get_tree().process_frame

	ball.is_active = true
	ball.velocity = Vector2(0, -500)
	ball._physics_process(1.0/60.0)

	assert_eq(ball.velocity.x, -200)

func test_collision_calls_hit_on_collider_with_hit_method() -> void:
	var ball := _make_ball()
	await get_tree().process_frame

	ball.is_active = true

	# Collision shape for ball
	var ball_shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 8
	ball_shape.shape = circle
	ball.add_child(ball_shape)

	# Collider that has hit()
	var body := HitBody.new()
	add_child_autofree(body)

	var body_shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(200, 10)
	body_shape.shape = rect
	body.add_child(body_shape)

	# Put ball above body, moving down
	ball.global_position = Vector2(0, 0)
	body.global_position = Vector2(0, 20)
	ball.velocity = Vector2(0, 800)

	await get_tree().physics_frame

	ball._physics_process(1.0/60.0)

	assert_true(body.hit_called)
