extends Node2D

@onready var brickObject = preload("res://scenes/brick.tscn")

var columns = 32
var rows = 7
var margin = 50

# Level-local RNG (seedable for tests)
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	# If not seeded yet, randomize for normal gameplay
	if rng.seed == 0:
		rng.randomize()

	setupLevel()

func set_seed(seed_value: int) -> void:
	rng.seed = seed_value

func setupLevel() -> void:
	rows = 2 + GameManager.level
	if rows > 9:
		rows = 9

	var colors: Array[Color] = getColors()
	_shuffle_colors(colors)

	for r in range(rows):
		for c in range(columns):
			var random_number: int = rng.randi_range(0, 2)
			if random_number > 0:
				var new_brick: Node2D = brickObject.instantiate()
				add_child(new_brick)

				new_brick.get_node("Sprite2D").scale = Vector2(0.5, 0.5)
				new_brick.position = Vector2(margin + (34 * c), margin + (34 * r))

				var sprite: Sprite2D = new_brick.get_node("Sprite2D")
				if r <= 9:
					sprite.modulate = colors[0]
				if r < 6:
					sprite.modulate = colors[1]
				if r < 3:
					sprite.modulate = colors[2]

func _process(_delta: float) -> void:
	pass

func getColors() -> Array[Color]:
	return [
		Color(0, 1, 1, 1),
		Color(0.54, 0.17, 0.89, 1),
		Color(0.68, 1, 0.18, 1),
		Color(1, 1, 1, 1)
	]

func _shuffle_colors(colors: Array[Color]) -> void:
	# Fisher–Yates shuffle using this level's rng
	for i in range(colors.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: Color = colors[i]
		colors[i] = colors[j]
		colors[j] = tmp
