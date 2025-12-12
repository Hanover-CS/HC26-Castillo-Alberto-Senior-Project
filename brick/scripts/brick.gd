extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func hit():
	
	GameManager.addPoints(1)
	
	$CPUParticles2D.emitting = true
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
	
	var bricksLeft = get_tree () .get_nodes_in_group ('Brick')
	
	if (bricksLeft.size() == 1):
		get_parent () .get_node ("Ball").is_active = false
		await get_tree().create_timer(1).timeout
		GameManager.level += 1
		get_tree().reload_current_scene()
	else:
		await get_tree().create_timer(1).timeout
		queue_free()
	
