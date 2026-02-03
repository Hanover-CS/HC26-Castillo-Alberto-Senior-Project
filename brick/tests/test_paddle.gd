extends "res://addons/gut/test.gd"

const PADDLE_PATH := "res://scripts/paddle_1.gd"

# Used floats for everything to stoop getting warning

func _make_paddle() -> CharacterBody2D:
	var paddle_script: GDScript = load(PADDLE_PATH)
	var paddle: CharacterBody2D = paddle_script.new()
	add_child_autofree(paddle)
	return paddle

func after_each() -> void:
	if Input.is_action_pressed("ui_left"):
		Input.action_release("ui_left")
	if Input.is_action_pressed("ui_right"):
		Input.action_release("ui_right")

func test_pressing_right_sets_positive_velocity() -> void:
	var paddle := _make_paddle()

	Input.action_press("ui_right")
	paddle._physics_process(1.0 / 60.0)

	assert_gt(paddle.velocity.x, 0.0)

func test_pressing_left_sets_negative_velocity() -> void:
	var paddle := _make_paddle()

	Input.action_press("ui_left")
	paddle._physics_process(1.0 / 60.0)

	assert_lt(paddle.velocity.x, 0.0)

func test_no_input_moves_velocity_toward_zero() -> void:
	var paddle := _make_paddle()

	Input.action_release("ui_left")
	Input.action_release("ui_right")

	paddle.velocity.x = 500.0
	paddle._physics_process(1.0 / 60.0)

	assert_lt(paddle.velocity.x, 500.0)
