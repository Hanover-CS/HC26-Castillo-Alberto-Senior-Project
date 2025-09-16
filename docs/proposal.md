---
layout: page
title: About
---
# Proposal Draft: Dual-Mode Arcade Game (Brick Breaker + Pong)

## Platform
- Desktop graphical UI (macOs).  
- Optional future extension: Web App via HTML5/JavaScript.  

## Programming Languages
- **Python (primary)** — chosen for simplicity and access to the Pygame library.  
- **Alternative:** JavaScript (if deploying as a browser game).  
- Python is preferred because it is beginner-friendly, has strong support for 2D games, and allows rapid prototyping.  

## Frameworks / Libraries
- **Pygame** (library) — handles graphics, rendering, audio, input, and collisions.  
- **Random** (stdlib) — adds variability in ball movement.  
- *(Optional)* WebSockets/Socket — if I decide to support online multiplayer.  
- **Distinction:** Pygame is a library (collection of tools); the project is not tied to a strict framework.  

## Project Features
- **Brick Breaker Mode**: Single-player paddle and ball, destructible bricks, scoring, lives, and difficulty scaling.  
- **Pong Mode**: Two-player mode on the same computer (keyboard or game controllers), with score tracking and win condition.  
- **Menu System**: Select between Brick Breaker and Pong.  
- **Pause/Restart** functionality.  
- **Sound effects** for collisions and events.  

## Comparable Solutions
- *Arkanoid/Breakout* (classic single-player).  
- *Pong* (classic two-player).  
- My project differs by combining these modes into a single polished application.  

## “New Stuff” Load
- Learning more about **event loops** and **game state management** in Python.  
- Gaining experience with **Pygame’s rendering loop** and **collision detection**.  
- Organizing a game project into modules and managing assets (sprites, sounds).  
- Possibly learning simple networking if Pong is extended to online play.  

## Data Storage
- Minimal — local high scores stored in a text or JSON file.  

## Hosting/Deployment
- Local execution by running the Python script.  
- Distribution as a standalone executable using **PyInstaller**.  
- *(Optional)* Browser deployment if the project is re-implemented in JavaScript/HTML5.  

## Deliverables
- Fully functioning game with two playable modes.  
- Annotated bibliography with references (Pygame docs, tutorials, example projects).  
- GitHub repository with code and documentation.  
- Final write-up and demo video.  
