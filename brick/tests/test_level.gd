extends "res://addons/gut/test.gd"

const LEVEL_PATH := "res://scripts/level.gd"

func make_level_with_seed(seed_value: int) -> Node2D:
	var script: GDScript = load(LEVEL_PATH)
	var lvl: Node2D = script.new()

	# IMPORTANT: seed BEFORE adding to tree so _ready uses it
	lvl.set_seed(seed_value)

	add_child_autofree(lvl)

	# wait for _ready() to run and generate bricks once
	return lvl

func count_bricks(lvl: Node) -> int:
	var n := 0
	for child in lvl.get_children():
		if child.is_in_group("Brick"):
			n += 1
	return n

func test_same_seed_same_brick_count() -> void:
	GameManager.level = 3

	var a := make_level_with_seed(123)
	await get_tree().process_frame
	var ca := count_bricks(a)

	var b := make_level_with_seed(123)
	await get_tree().process_frame
	var cb := count_bricks(b)

	assert_eq(ca, cb)

func test_different_seed_usually_changes_brick_count() -> void:
	GameManager.level = 3
	var changed := false

	for seed_a: int in [10, 20, 30, 40, 50]:
		var seed_b: int = seed_a + 999

		var a := make_level_with_seed(seed_a)
		await get_tree().process_frame
		var ca := count_bricks(a)

		var b := make_level_with_seed(seed_b)
		await get_tree().process_frame
		var cb := count_bricks(b)

		if ca != cb:
			changed = true
			break

	assert_true(changed)

func test_bricks_spawn_on_grid() -> void:
	GameManager.level = 2
	var lvl := make_level_with_seed(7)
	await get_tree().process_frame

	var margin: int = int(lvl.margin)

	var found := false
	for child in lvl.get_children():
		if child.is_in_group("Brick"):
			found = true
			var x := int(child.position.x)
			var y := int(child.position.y)
			assert_eq((x - margin) % 34, 0)
			assert_eq((y - margin) % 34, 0)
			break

	assert_true(found)
