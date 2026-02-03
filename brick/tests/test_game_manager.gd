extends "res://addons/gut/test.gd"

const GM_PATH := "res://scripts/game_manager.gd"

func _make_gm_with_required_ui() -> Node:
	var gm_script: GDScript = load(GM_PATH)
	var gm: Node = gm_script.new()

	add_child_autofree(gm)

	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.name = "CanvasLayer"
	gm.add_child(canvas)

	var score_label: Label = Label.new()
	score_label.name = "ScoreLabel"
	canvas.add_child(score_label)

	var level_label: Label = Label.new()
	level_label.name = "LevelLabel"
	canvas.add_child(level_label)

	return gm

func test_addPoints_increments_score() -> void:
	var gm: Node = _make_gm_with_required_ui()
	gm.set("score", 0)
	gm.call("addPoints", 3)
	assert_eq(gm.get("score"), 3)

func test_process_updates_labels() -> void:
	var gm: Node = _make_gm_with_required_ui()
	gm.set("score", 12)
	gm.set("level", 4)

	gm.call("_process", 0.016)

	assert_eq(gm.get_node("CanvasLayer/ScoreLabel").text, "12")
	assert_eq(gm.get_node("CanvasLayer/LevelLabel").text, "Level: 4")
