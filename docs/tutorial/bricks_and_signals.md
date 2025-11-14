---
# Bricks & Signals
---

Bricks act as **Area2D** nodes that notify the Level when the ball hits them. This is where you’ll use **signals**.


## Brick Scene Setup
---

Create a new scene:

1. Root: **Area2D**
2. Add:
   - **Sprite2D**
   - **CollisionShape2D**

Add the script `Brick.gd`:

```gdscript
extends Area2D

signal brick_destroyed

func _on_Brick_area_entered(area):
    emit_signal("brick_destroyed")
    queue_free()
```

Connect the built-in `area_entered` signal in the editor to `_on_Brick_area_entered()`.

---

## Why use signals?

- Clean and modular communication  
- Bricks don’t need references to the Level  
- The Level simply **listens and reacts**  

---

**Next:** [Connecting the Level](wire_it_together.md)  
**Prev:** [Creating the Ball](create_ball.md)
