---
# Creating the Ball
---

The ball is implemented as a **RigidBody2D**, allowing Godot’s physics engine to handle movement and collisions.

## Ball Scene Setup
---

Create a new scene:

1. Root: **RigidBody2D**
2. Add:
   - **Sprite2D**
   - **CollisionShape2D**

Add this script to `Ball.gd`:

```gdscript
extends RigidBody2D

@export var initial_speed := 300.0

func _ready():
    linear_velocity = Vector2(initial_speed, -initial_speed)
```

The ball now launches upward at the start.

---

**Next:** [Bricks & Signals](bricks_and_signals.md)  
**Prev:** [Creating the Paddle](create_paddle.md)
