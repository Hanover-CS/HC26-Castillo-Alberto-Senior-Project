import tkinter as tk
import random

# --- Game Settings ---
WIDTH = 400
HEIGHT = 400
PADDLE_WIDTH = 80
PADDLE_HEIGHT = 10
BALL_SIZE = 15
BRICK_ROWS = 4
BRICK_COLS = 6
BRICK_WIDTH = WIDTH // BRICK_COLS
BRICK_HEIGHT = 20

# --- Setup Window ---
root = tk.Tk()
root.title("Brick Breaker with Power-Ups")
canvas = tk.Canvas(root, width=WIDTH, height=HEIGHT, bg="black")
canvas.pack()

# --- Paddle ---
paddle = canvas.create_rectangle(WIDTH//2 - PADDLE_WIDTH//2,
                                 HEIGHT-30,
                                 WIDTH//2 + PADDLE_WIDTH//2,
                                 HEIGHT-20,
                                 fill="white")

# --- Ball ---
ball = canvas.create_oval(WIDTH//2 - BALL_SIZE//2,
                          HEIGHT//2 - BALL_SIZE//2,
                          WIDTH//2 + BALL_SIZE//2,
                          HEIGHT//2 + BALL_SIZE//2,
                          fill="red")
ball_dx = 3
ball_dy = -3

# --- Bricks ---
bricks = []
for row in range(BRICK_ROWS):
    for col in range(BRICK_COLS):
        x1 = col * BRICK_WIDTH
        y1 = row * BRICK_HEIGHT
        x2 = x1 + BRICK_WIDTH
        y2 = y1 + BRICK_HEIGHT
        brick = canvas.create_rectangle(x1, y1, x2, y2, fill="blue")
        bricks.append(brick)

# --- Power-Ups ---
powerups = []   # list of active power-up balls (falling down)
active_power = None

# --- Controls ---
def move_left(event):
    canvas.move(paddle, -20, 0)

def move_right(event):
    canvas.move(paddle, 20, 0)

root.bind("<Left>", move_left)
root.bind("<Right>", move_right)

# --- Game Loop ---
def game_loop():
    global ball_dx, ball_dy, PADDLE_WIDTH, active_power

    # Move ball
    canvas.move(ball, ball_dx, ball_dy)
    bx1, by1, bx2, by2 = canvas.coords(ball)
    px1, py1, px2, py2 = canvas.coords(paddle)

    

    # Brick collision
    hit = None
    for brick in bricks:
        bx1b, by1b, bx2b, by2b = canvas.coords(brick)
        if bx2 >= bx1b and bx1 <= bx2b and by2 >= by1b and by1 <= by2b:
            hit = brick
            break
    if hit:
        canvas.delete(hit)
        bricks.remove(hit)
        ball_dy = -ball_dy
        # 30% chance to drop a power-up
        if random.random() < 0.3:
            x1, y1, x2, y2 = canvas.coords(hit)
            pu = canvas.create_oval(x1+10, y1+5, x1+30, y1+25, fill="green")
            powerups.append(pu)
        if not bricks:
            canvas.create_text(WIDTH//2, HEIGHT//2, text="YOU WIN!", fill="yellow", font=("Arial", 20))
            return

    # Move power-ups
    for pu in powerups[:]:
        canvas.move(pu, 0, 4)
        pux1, puy1, pux2, puy2 = canvas.coords(pu)
        if puy2 >= HEIGHT:  # fell out
            canvas.delete(pu)
            powerups.remove(pu)
        elif puy2 >= py1 and pux2 >= px1 and pux1 <= px2:  # caught
            canvas.delete(pu)
            powerups.rempve(pu)
            # Activate power-up: enlarge paddle
            if active_power != "big_paddle":
                # Make paddle bigger
                cx1, cy1, cx2, cy2 = canvas.coords(paddle)
                canvas.coords(paddle, cx1-20, cy1, cx2+20, cy2)
                active_power = "big_paddle"

    root.after(20, game_loop)

# Start game
game_loop()
root.mainloop()
