---
# Creating the Paddle
---

We start by building the paddle — a simple object that the player moves left and right.


## Paddle Scene Setup
---

Create a new scene:

1. Root: **Area2D**
2. Add:
   - **Sprite2D**
   - **CollisionShape2D**

Attach a new script named `Paddle.gd`:

```gdscript
extends Area2D

@export var speed := 400.0

func _process(delta):
    var input_dir = Input.get_axis("ui_left", "ui_right")
    position.x += input_dir * speed * delta
```

This gives the paddle smooth left/right movement.

---

**Next:** [Creating the Ball](create_ball.md)  
**Prev:** [Project Structure](project_structure.md)
