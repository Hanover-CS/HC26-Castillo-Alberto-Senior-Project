---
title: About
layout: page
---

# Proposal Draft: Dual Arcade Game (Brick Breaker + Pong)

This project aims to develop a **dual-mode arcade game** that combines two classics—*Brick Breaker* and *Pong*—into one polished application. The project is designed to strengthen my skills in *event loops, game state management, and modular design* while also gaining experience with a professional game engine (Godot).  

## Platform
- **Primary**: Desktop graphical UI (macOS, Windows, Linux).  
- **Optional Future Extension**: Export to web via HTML5 (Godot supports this natively).  

## Programming Languages
- **GDScript (primary)** — a Python-like scripting language built into Godot, chosen for simplicity and integration with the engine [1].  
- **Alternative Consideration:** C# (also supported by Godot), but GDScript is faster to prototype with.  

## Game Engine / Framework
- **Godot Engine** — a free, open-source game engine with strong 2D support, a built-in editor, and cross-platform export [1].  
- **Node/Scene System** — Godot’s design encourages modular components, making it ideal for managing game objects like paddles, balls, and bricks.  
- **Optional Libraries** — could use `random` for ball movement variability or Godot’s built-in physics engine for collisions.  

## Project Features
- **Brick Breaker Mode**: Single-player paddle and ball, destructible bricks, scoring, lives, and difficulty scaling.  
- **Pong Mode**: Two-player mode on the same computer, with score tracking and win conditions.  
- **Menu System**: Select between Brick Breaker and Pong.  
- **Pause/Restart** functionality.  
- **Sound effects** for collisions and events.  

## Comparable Solutions
- *Arkanoid/Breakout* — classic single-player with brick destruction [2].  
- *Pong* — iconic two-player paddle game [3].  
- **Difference:** My project combines both into one modern, polished application with clean UI and sound design.  

## Overview of Components
The game will be organized into the following modules/scenes:  
1. **Main Menu** — allows selection between Brick Breaker and Pong.  
2. **Game Scenes** — separate scenes for Brick Breaker and Pong, each with its own rules.  
3. **Input Handling** — Godot’s Input Map system will manage controls.  
4. **Game Logic** — collision detection, scoring, and win/loss conditions.  
5. **Rendering & UI** — Godot handles sprites, animations, and scoreboards.  
6. **Audio** — collision and win/loss sound effects integrated via Godot’s Audio nodes.  

These components will be tied together through Godot’s **scene tree** and **main loop.**  

## “New Stuff” Load
- Learning **GDScript** and Godot’s node/scene architecture.  
- Managing multiple **game states** in one project (menu, gameplay, pause).  
- Implementing physics and collisions with Godot’s 2D engine.  
- Exporting to multiple platforms (desktop, HTML5).  

## Data Storage
- Local high scores saved using Godot’s built-in JSON serialization.  

## Hosting/Deployment
- **Local execution** via Godot export to desktop.  
- **Distribution** as a standalone executable (Windows/Mac/Linux).  
- *(Optional)* **Web deployment** using Godot’s HTML5 export feature.  

## Comparison of Game Engines

### Godot vs Unity
- **Unity** is industry-standard for 3D and complex games, but has a steeper learning curve and heavier runtime [4].  
- **Godot** is lightweight, open-source, and excels at 2D games — making it more appropriate for a project like Brick Breaker + Pong.  

### Godot vs Pygame
- **Pygame** is a library, not a full engine. It requires more manual coding for scenes, physics, and collisions [5].  
- **Godot** provides a visual editor, built-in physics, and a structured project workflow, reducing boilerplate code.  

### Godot vs Phaser (JavaScript)
- **Phaser** is great for browser-based games but less flexible for desktop distribution [6].  
- **Godot** supports both desktop and browser exports, while also giving more powerful tools for UI and physics.  

### Why I Chose Godot
Godot strikes the right balance for my project:  
- **Beginner-friendly** with Python-like GDScript.  
- **Lightweight and open-source** (no licensing fees).  
- **Strong 2D support** — ideal for arcade-style games.  
- **Cross-platform** export (desktop + HTML5) with minimal configuration.  
- **Structured workflow** with nodes and scenes makes managing two game modes easier.  

## Deliverables
- Fully functioning game with **two playable modes**.  
- Annotated bibliography with references.  
- GitHub repository with code and documentation.  
- Final **demo video and write-up**.  

# References

## References (Annotated Bibliography)

1. **Godot Engine Documentation** — Main source for engine features, node/scene system, physics engine, and export options.  
   [https://docs.godotengine.org/](https://docs.godotengine.org/)

2. **GDScript Style Guide (Official)** — Explains best practices for scripting in Godot; ensures clean, maintainable code.  
   [https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)

3. **Godot 4 Release Notes** — Outlines scene improvements, 2D engine updates, and export features relevant to this project.  
   [https://godotengine.org/article/godot-4-0-release](https://godotengine.org/article/godot-4-0-release)

4. **Arkanoid/Breakout (Atari, 1986)** — Classic brick-breaker game used for comparison of mechanics.  
   [https://www.arcade-museum.com/game_detail.php?game_id=6939](https://www.arcade-museum.com/game_detail.php?game_id=6939)

5. **Pong (Atari, 1972)** — Historical inspiration for two-player paddle mechanics.  
   [https://www.atari.com/games/pong/](https://www.atari.com/games/pong/)

6. **Unity Documentation** — Used to contrast Unity’s professional 3D features with Godot’s lightweight 2D focus.  
   [https://docs.unity3d.com/](https://docs.unity3d.com/)

7. **Pygame Documentation** — Shows differences between a library (Pygame) and a full engine (Godot).  
   [https://www.pygame.org/docs/](https://www.pygame.org/docs/)

8. **Phaser Documentation** — Resource for browser-based game engines, contrasted against Godot’s desktop-first workflow.  
   [https://phaser.io/](https://phaser.io/)

9. **Extra Godot Info** — Community experiences with Godot engine.  
   [https://blenderartists.org/t/anyone-had-experiences-with-godot-engine-good-bad-ugly/1514292](https://blenderartists.org/t/anyone-had-experiences-with-godot-engine-good-bad-ugly/1514292)



