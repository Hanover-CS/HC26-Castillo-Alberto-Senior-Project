extends Node


var passed: int = 0
var failed: int = 0

func _ready() -> void:
	print("=== Running tests ===")
	await get_tree().process_frame
	await run_all()
	print("=== Done: %d passed, %d failed ===" % [passed, failed])
	# Código de salida: 0 = OK, 1 = fallo (para terminal/CI)
	get_tree().quit(0 if failed == 0 else 1)


# ==============
# ASSERT HELPERS
# ==============

func _record_result(ok: bool, message: String) -> void:
	if ok:
		passed += 1
		print("[PASS] %s" % message)
	else:
		failed += 1
		push_error("[FAIL] %s" % message)

func assert_true(condition: bool, message: String) -> void:
	_record_result(condition, message)

func assert_equal(actual, expected, message: String) -> void:
	var ok: bool = (actual == expected)
	var full_message := "%s (expected: %s, got: %s)" % [message, str(expected), str(actual)]
	_record_result(ok, full_message)


# ============
# RUNNER
# ============

func run_all() -> void:
	await test_ball_speed_increases_with_level()
	await test_brick_disappears_on_hit()


# =========================================
# TEST 1: la bola aumenta de velocidad
#        cuando sube el nivel
# =========================================

func test_ball_speed_increases_with_level() -> void:
	print("-- test_ball_speed_increases_with_level")

	var ball_scene := preload("res://scenes/ball.tscn")

	# Nivel 1
	GameManager.level = 1
	var ball_level_1 = ball_scene.instantiate()
	get_tree().root.add_child(ball_level_1)
	await get_tree().process_frame
	var speed_level_1: float = ball_level_1.speed
	ball_level_1.queue_free()
	await get_tree().process_frame

	# Nivel 2
	GameManager.level = 2
	var ball_level_2 = ball_scene.instantiate()
	get_tree().root.add_child(ball_level_2)
	await get_tree().process_frame
	var speed_level_2: float = ball_level_2.speed
	ball_level_2.queue_free()
	await get_tree().process_frame

	assert_true(
		speed_level_2 > speed_level_1,
		"Ball speed should increase when level increases"
	)


# =========================================
# TEST 2: el ladrillo desaparece al ser golpeado
#        (se vuelve invisible y sin colisión)
# =========================================

func test_brick_disappears_on_hit() -> void:
	print("-- test_brick_disappears_on_hit")

	var brick_scene := preload("res://scenes/brick.tscn")

	# Creamos 2 ladrillos para NO activar la rama de
	# "último ladrillo" que hace reload de la escena.
	var brick1 = brick_scene.instantiate()
	var brick2 = brick_scene.instantiate()

	get_tree().root.add_child(brick1)
	get_tree().root.add_child(brick2)

	# Por si acaso, nos aseguramos de que están en el grupo "Brick".
	brick1.add_to_group("Brick")
	brick2.add_to_group("Brick")

	await get_tree().process_frame

	# Simulamos el golpe llamando a la función hit().
	brick1.hit()
	await get_tree().process_frame

	var sprite: Sprite2D = brick1.get_node("Sprite2D")
	var collision: CollisionShape2D = brick1.get_node("CollisionShape2D")

	assert_true(
		sprite.visible == false,
		"Brick sprite should be invisible after being hit"
	)

	assert_true(
		collision.disabled == true,
		"Brick collision should be disabled after being hit"
	)

	brick1.queue_free()
	brick2.queue_free()
	await get_tree().process_frame
