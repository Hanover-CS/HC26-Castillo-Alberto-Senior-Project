extends "res://addons/gut/test.gd"

const LEVEL_PATH := "res://scripts/level.gd"

func _make_level() -> Node2D:
	var s: GDScript = load(LEVEL_PATH)
	var l: Node2D = s.new()
	add_child_autofree(l)
	return l

func _sig(lvl: Node) -> Array:
	var pos_list: Array = []

	for child in lvl.get_children():
		if child.is_in_group("Brick"):
			var x: int = int(child.position.x)
			var y: int = int(child.position.y)
			pos_list.append(Vector2i(x, y))

	# Sorting makes the signature stable even if child order changes
	pos_list.sort()
	return pos_list

func _count(lvl: Node) -> int:
	var n := 0
	for child in lvl.get_children():
		if child.is_in_group("Brick"):
			n += 1
	return n

func test_random_seeds_change_layout() -> void:
	GameManager.level = 3

	var found_difference := false
	for seed_a: int in [11, 22, 33, 44, 55]:
		var seed_b: int = seed_a + 1000

		var lvl_a := _make_level()
		lvl_a.set_seed(seed_a)
		lvl_a.setupLevel()

		var lvl_b := _make_level()
		lvl_b.set_seed(seed_b)
		lvl_b.setupLevel()

		if _sig(lvl_a) != _sig(lvl_b):
			found_difference = true
			break

	assert_true(found_difference)

func test_brick_count_changes_with_level() -> void:
	var found_change := false

	for s: int in [101, 202, 303, 404, 505, 606]:
		GameManager.level = 1
		var lvl1 := _make_level()
		lvl1.set_seed(s)
		lvl1.setupLevel()
		var c1 := _count(lvl1)

		GameManager.level = 6
		var lvl6 := _make_level()
		lvl6.set_seed(s)
		lvl6.setupLevel()
		var c6 := _count(lvl6)

		if c1 != c6:
			found_change = true
			break

	assert_true(found_change)
