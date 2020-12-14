from tkinter import *
import random as rand
import time
import _thread

board = Tk()
board.title("Sudoku")
board.geometry("900x900")

with open('sudoku.csv') as i :
    a = i.readlines()
game_solution =[x.split(",") for x in a]
hints = 3
lives = 3
mode = "Marker"
numbers = ["1","2","3","4","5","6","7","8","9"]

### add timer
### add winning screen
### add arrow keys control
### top 10 times // leaderboards
### difficulties
### menu screen





class Square:
    def __init__(self, rectangle):
        self.rectangle = rectangle
        self.x = canvas.coords(rectangle)[0]
        self.y = canvas.coords(rectangle)[1]
        self.pencil_lable = canvas.create_text(self.x+40, self.y+40, text = "", font=("Helvetica", 10), fill = "green")
        self.marker_lable = canvas.create_text(self.x+40,self.y+40, text = "", font=("Helvetica", 20))
        self.row = 0
        self.column = 0

    def __str__(self):
            return "Square"

    def __repr__(self):
            return str(self)
    
    def set_coords(self, row, column):
            self.row = row
            self.column = column
            
            
            

def key_pressed(event):
    global current_square , canvas, numbers, mode, lives
    kp = event.char
    print(kp)
    if current_square is not None:
        if kp == "m":
            mode_change("Marker")
            sink("Marker")
        elif kp == "p":
            sink("Pencil")
            mode_change("Pencil")
        elif mode == "Pencil" and kp in numbers and canvas.itemcget(current_square.marker_lable, 'text') == "":
            txt = canvas.itemcget(current_square.pencil_lable, 'text')
            if kp not in txt:
                canvas.itemconfig(current_square.pencil_lable, text = txt + kp)
        elif mode == "Marker" and kp in numbers:
            canvas.itemconfig(current_square.pencil_lable, text = "")
            if correct(kp):
                canvas.itemconfig(current_square.marker_lable, text = kp, fill = "black")
                confliction(kp)
            else:
                canvas.itemconfig(current_square.marker_lable, text = kp, fill = "red")
                if lives == 0:
                    tryagain_text = canvas.create_text(450, 400, text = "Press to try again", activefill = "red", font=("Helvetica", 50))
                    newgame_text = canvas.create_text(450, 600, text = "Press for new game", activefill = "red", font=("Helvetica", 50))
                    canvas.tag_bind(tryagain_text, "<ButtonPress-1>", lambda event, labeltry = tryagain_text, labelnew = newgame_text : retry_game(tryagain_text,newgame_text))
                    canvas.tag_bind(newgame_text, "<ButtonPress-1>", lambda event, labeltry = tryagain_text, labelnew = newgame_text : new_game(tryagain_text,newgame_text))
        elif kp == '\b' :
            canvas.itemconfig(current_square.marker_lable, text = "")
            txt = canvas.itemcget(current_square.pencil_lable, 'text')
            txt = txt[0:len(txt)-1]
            canvas.itemconfig(current_square.pencil_lable, text = txt)

def new_game(tryagain_text,newgame_text):
    global game_number
    canvas.delete(tryagain_text)
    canvas.delete(newgame_text)
    game_number = rand.randint(0,72)
    draw_board()
    

def retry_game(tryagain_text,newgame_text):
    canvas.delete(tryagain_text)
    canvas.delete(newgame_text)
    draw_board()

def correct(kp):
    global current_square, game_solution, game_number, lives
    game = game_solution[game_number][1]
    if game[(current_square.column)+(current_square.row*9)] != kp:
        lives -=1
        life_lable.config(text = "Lives: " + str(lives))
        return False
    return True

def confliction(number):
    global current_square
    row = current_square.row
    column = current_square.column
    canvas.itemconfig(current_square.pencil_lable, text = "")
    square_x = current_square.column // 3
    square_y = current_square.row // 3
    for i in range(square_x * 3 , square_x * 3 +3):
        for j in range(square_y * 3, square_y * 3 + 3):
            txta = canvas.itemcget(grid[i][j].pencil_lable, 'text')
            if number in txta:
                index = txta.index(number)
                txta = txta[0 : index : ] + txta[index + 1 : :]
                canvas.itemconfig(grid[i][j].pencil_lable, text = txta)
    for i in range(9):
        txta = canvas.itemcget(grid[column][i].pencil_lable, 'text')
        txtb = canvas.itemcget(grid[i][row].pencil_lable, 'text')
        if number in txta:
            index = txta.index(number)
            txta = txta[0 : index : ] + txta[index + 1 : :]
        if number in txtb:
            index = txtb.index(number)
            txtb = txtb[0 : index : ] + txtb[index + 1 : :]         
        canvas.itemconfig(grid[column][i].pencil_lable, text = txta)
        canvas.itemconfig(grid[i][row].pencil_lable, text = txtb)
        
def set_square(square, is_complete):
    global current_square
    current_square = square
    for columns in grid:
        for squares in columns:
            canvas.itemconfig(squares.rectangle, fill = "gray74")
    row = current_square.row
    column = current_square.column
    for i in range(9):        
        canvas.itemconfig(grid[column][i].rectangle, fill = "gray63")
        canvas.itemconfig(grid[i][row].rectangle, fill = "gray63")
    square_x = current_square.column // 3
    square_y = current_square.row // 3
    for i in range(square_x * 3 , square_x * 3 +3):
        for j in range(square_y * 3, square_y * 3 + 3):
            canvas.itemconfig(grid[i][j].rectangle, fill = "gray63")
    for i in range(9):
        for j in range(9):
            if canvas.itemcget(grid[i][j].marker_lable, 'text') == canvas.itemcget(current_square.marker_lable, 'text') and canvas.itemcget(grid[i][j].marker_lable, 'text') != "":
                canvas.itemconfig(grid[i][j].rectangle, fill = "gray85")
    if is_complete:
        current_square = None

def mode_change(new):
    global mode
    mode = new

current_square = None

def get_hint():
    global game_solution, hints, game_number, current_square
    if hints == 0:
        return print("sorry")    
    if current_square is not None:
        solution = game_solution[game_number][1]
        index = (current_square.column)+(current_square.row*9)
        canvas.itemconfig(current_square.marker_lable, text = solution[index])
        hints -= 1
        hint_button.config(text = "Get hint " + str(hints))
    
def sink(button):
    marker_button.config(relief = RAISED)
    pencil_button.config(relief = RAISED)
    if button == "Marker":
        marker_button.config(relief = SUNKEN)
    elif button == "Pencil":
        pencil_button.config(relief = SUNKEN)
        
def draw_board():
    global game_solution, game_number, lives
    
    _thread.start_new_thread(update,())
    lives = 3
    hints = 3
    game = game_solution[game_number][0]
    c = -1
    life_lable.config(text = "Lives: " + str(lives))
    hint_button.config(text = "Get hint " + str(hints))
    for i in range(9):
        for j in range(9):
            c += 1
            if game[c] == "0":
                canvas.tag_bind(grid[j][i].rectangle, "<ButtonPress-1>", lambda event, square = grid[j][i], is_complete = False :set_square(square, is_complete))
                canvas.tag_bind(grid[j][i].marker_lable, "<ButtonPress-1>", lambda event, square = grid[j][i], is_complete = False :set_square(square, is_complete))
                canvas.tag_bind(grid[j][i].pencil_lable, "<ButtonPress-1>", lambda event, square = grid[j][i], is_complete = False :set_square(square, is_complete))
                canvas.itemconfig(grid[j][i].marker_lable, text = "")
            else:
                canvas.tag_bind(grid[j][i].rectangle, "<ButtonPress-1>", lambda event, square = grid[j][i], is_complete = True :set_square(square, is_complete))
                canvas.tag_bind(grid[j][i].marker_lable, "<ButtonPress-1>", lambda event, square = grid[j][i], is_complete = True :set_square(square, is_complete))
                canvas.tag_bind(grid[j][i].pencil_lable, "<ButtonPress-1>", lambda event, square = grid[j][i], is_complete = True :set_square(square, is_complete))
                canvas.itemconfig(grid[j][i].marker_lable, text = game[c], fill = "blue")

game_number = rand.randint(0,71)
canvas = Canvas(board, bg = "gray63", width = 810, height = 810)
canvas.grid(row=0, column=0, columnspan=9, rowspan=9)
board.bind("<Key>", key_pressed)


# Buttons / Label
marker_button = Button(board, text = "Marker", relief = SUNKEN, command=lambda : [sink("Marker"),mode_change("Marker")])
pencil_button = Button(board, text = "Pencil", command=lambda : [sink("Pencil"),mode_change("Pencil")])
hint_button = Button(board, text = "Get hint " + str(hints), command = lambda : get_hint())
life_lable = Label(board, text = "Lives: " + str(lives))
# Button placement
marker_button.grid(row = 10, column = 0, sticky = (N,E,S,W))
pencil_button.grid(row = 10, column = 1, sticky = (N,E,S,W))
hint_button.grid(row = 10, column = 2, sticky = (N,E,S,W))
life_lable.grid(row = 10, column = 3, sticky = (N,E,S,W))

time_lable = Label(board, text = "0")
time_lable.grid(row = 10, column = 4, sticky = (N,E,S,W))
def update():
    global time_lable
    while True:
        time_elapsed = time.time()-start_time
        minutes = time_elapsed // 60
        seconds = time_elapsed%60
        time_lable.config(text = "Time elapsed: "+ str(int(minutes))+ " mintues "+str(int(seconds)) + " seconds")

grid = [[]for i in range(9)]
for j in range(9):
    for i in range(9):
        b = Square(canvas.create_rectangle(0+(i*90),0+(j*90),90+(i*90),90+(j*90), fill = "gray74"))
        rec = b.rectangle
        grid[i].append(b)
        b.set_coords(j, i)
for i in range(2):
    canvas.create_line(270+(i*270), 0, 270+(i*270), 900, fill="black", width=3)
    canvas.create_line(0, 270+(i*270), 900, 270+(i*270), fill="black", width=3)
    
start_time = time.time()
draw_board()

board.mainloop()