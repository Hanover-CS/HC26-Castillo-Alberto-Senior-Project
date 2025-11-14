---
# Connecting the Level
---

Now that paddle, ball, and bricks work independently, you can assemble them inside a dedicated Level scene.


## Level Scene Structure
---


```plaintext
Level (Node2D)
├── Paddle (instance)
├── Ball (instance)
└── Bricks (Node2D)
```

Attach this script to `Level.gd`:

```gdscript
extends Node2D

func _ready():
    for brick in $Bricks.get_children():
        brick.brick_destroyed.connect(_on_brick_destroyed)

func _on_brick_destroyed():
    print("Brick destroyed!")
```

This connects every brick’s signal when the level loads.

---


**Next:** [Exercises](exercises.md)  
**Prev:** [Bricks & Signals](bricks_and_signals.md)
