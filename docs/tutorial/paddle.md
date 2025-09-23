---
title: "Create the Paddle"
---

# Create the Paddle

1. Make a new scene: **Node2D** → name it `Paddle`.
2. Add a `ColorRect` or `Sprite2D` so you can see it.
3. Attach a new script `Paddle.gd`.

```gdscript
extends Node2D

var speed = 400
var half_width = 48   # half the paddle width

func _process(delta):
    var dir = 0
    if Input.is_action_pressed("ui_left"):
        dir -= 1
    if Input.is_action_pressed("ui_right"):
        dir += 1
    position.x += dir * speed * delta

    # keep paddle on screen
    var screen_w = get_viewport_rect().size.x
    position.x = clamp(position.x, half_width, screen_w - half_width)
