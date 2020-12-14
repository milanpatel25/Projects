from tkinter import *
import random
import time

class ResizingCanvas(Canvas):
    def __init__(self, parent, **kwargs):
        Canvas.__init__(self, parent, **kwargs)
        self.bind("<Configure>", self.on_resize)
        self.height = self.winfo_reqheight()
        self.width = self.winfo_reqwidth()

    def on_resize(self,event):
        # determine the ratio of old width/height to new width/height
        wscale = event.width/self.width
        hscale = event.height/self.height
        self.width = event.width
        self.height = event.height
        # rescale all the objects
        self.scale("all", 0, 0, wscale, hscale)


board = Tk()
board.title("Ludo")
board.geometry("1920x1080")
tiles = []
safe_tiles = [4,11,16,21,28,33,38,45,50,55,62,67]


## tile_order for evry color
yellow_tile_order = {}
blue_tile_order = {}
red_tile_order = {}
green_tile_order ={}
for j in range(1,73):
    yellow_tile_order[j] = j+4
for j in range(1,73):
    if j > 64:
        blue_tile_order[j] = j + 12
    elif j > 47:
        blue_tile_order[j] = (j+21)%68
    else: 
        blue_tile_order[j] = (j+21)%69
for j in range(1,73):
    if j > 64:
        red_tile_order[j] = j + 20
    elif j > 30 :
        red_tile_order[j] = (j+38)%68
    else: 
        red_tile_order[j] = (j+38)%69 
for j in range(1,73):
    if j > 64:
        green_tile_order[j] = j + 28
    elif j > 13 :
        green_tile_order[j] = (j+55)%68
    else: 
        green_tile_order[j] = (j+55)%69
        
order_list = [ yellow_tile_order , blue_tile_order , red_tile_order  , green_tile_order]
    
## main frame / menu
main_frame = ResizingCanvas(board, bg="gray", height=1050, width=1050)
main_frame.pack(fill="both", expand=True)
main_frame.grid(row=0, column=0, columnspan=3, rowspan=3)
menu = Frame(board, height = 100, width = 100, bg = "gray")
menu.grid(row = 0, column = 4, rowspan = 3 , columnspan = 3, sticky = (N,E,S,W))

class Counter:
    def __init__(self,current_tile, current_tile_order, original_position,id_num,can_circle, block):
        self.current_tile = current_tile
        self.current_tile_order = current_tile_order
        self.id_num = id_num
        self.original_position = original_position
        self.can_circle = can_circle
        self.block = block


    def __str__(self):
            return "Counter : %s %s %s" % (self.id_num, self.current_tile,self.block)

    def __repr__(self):
            return str(self)
    def move(self, tile_order_destination): 
        if self.current_tile_order == 0:
            self.current_tile_order = 1
        if tile_order_destination == 72:
            move_object(main_frame,self.can_circle, (525, 525), 0)
        elif self.block:
            move_object(main_frame,self.can_circle,(main_frame.coords(order_list[players.index(current_player)][tile_order_destination])[0]+25,main_frame.coords(order_list[players.index(current_player)][tile_order_destination])[1]), 0)
        else:
            move_object(main_frame,self.can_circle,(main_frame.coords(order_list[players.index(current_player)][tile_order_destination])[0],main_frame.coords(order_list[players.index(current_player)][tile_order_destination])[1]), 0)
        self.block = False
        self.current_tile = order_list[players.index(current_player)][tile_order_destination]
        self.current_tile_order = tile_order_destination                                                  
    def hui_jia(self):
        self.current_tile = 0
        self.current_tile_order = 0
        move_object(main_frame,self.can_circle,self.original_position, 1)

def move_object(canvas, object_id, destination, speed=1):
    dest_x, dest_y = destination
    coords = canvas.coords(object_id)
    current_x = coords[0]
    current_y = coords[1]

    new_x, new_y = current_x, current_y
    delta_x = delta_y = 0
    if current_x < dest_x:
        delta_x = 1
    elif current_x > dest_x:
        delta_x = -1

    if current_y < dest_y:
        delta_y = 1
    elif current_y > dest_y:
        delta_y = -1

    if (delta_x, delta_y) != (0, 0):
        canvas.move(object_id, delta_x, delta_y)

    if (new_x, new_y) != (dest_x, dest_y):
        canvas.after(speed, move_object, canvas, object_id, destination, speed)


# Creating all the tiles
for i in range(8):
    if i == 4:
        tiles.append(main_frame.create_rectangle(1000 - (i * 50), 350, 1050 - (i * 50), 470, fill="yellow"))
    else:
        tiles.append(main_frame.create_rectangle(1000 - (i * 50), 350, 1050 - (i * 50), 470, fill="white"))

for i in range(8):
    if i == 3:
        tiles.append(main_frame.create_rectangle(580, 350 - (i * 50), 700, 400 - (i * 50), fill="gray"))
    else:    
        tiles.append(main_frame.create_rectangle(580, 350 - (i * 50), 700, 400 - (i * 50), fill="white"))

tiles.append(main_frame.create_rectangle(470, 0, 580, 50, fill="gray"))

for i in range(8):
    if i == 4:
        tiles.append(main_frame.create_rectangle(350, 0 + (i * 50), 470, 50 + (i * 50), fill="blue"))
    else:
        tiles.append(main_frame.create_rectangle(350, 0 + (i * 50), 470, 50 + (i * 50), fill="white"))
        

for i in range(8):
    if i ==  3:
        tiles.append(main_frame.create_rectangle(400 - (i * 50), 350, 350 - (i * 50), 470, fill="gray"))
    else:
        tiles.append(main_frame.create_rectangle(400 - (i * 50), 350, 350 - (i * 50), 470, fill="white"))

tiles.append(main_frame.create_rectangle(0, 470, 50, 580, fill="gray"))

for i in range(8):
    if i == 4:
        tiles.append(main_frame.create_rectangle(0 + (i * 50), 580, 50 + (i * 50), 700, fill="red"))
    else:
        tiles.append(main_frame.create_rectangle(0 + (i * 50), 580, 50 + (i * 50), 700, fill="white"))

for i in range(8):
    if i == 3:
        tiles.append(main_frame.create_rectangle(350, 650 + (i * 50), 470, 700 + (i * 50), fill="gray"))
    else:
        tiles.append(main_frame.create_rectangle(350, 650 + (i * 50), 470, 700 + (i * 50), fill="white"))

tiles.append(main_frame.create_rectangle(470, 1000, 580, 1050, fill="gray"))

for i in range(8):
    if i == 4:
        tiles.append(main_frame.create_rectangle(580,1050-(i*50),700,1000 - (i * 50), fill = "green"))
    else:
        tiles.append(main_frame.create_rectangle(580, 1050 - (i * 50), 700, 1000 - (i * 50), fill="white"))

for i in range(8):
    if i == 3:
        tiles.append(main_frame.create_rectangle(650 + (i * 50), 700, 700 + (i * 50), 580, fill="gray"))
    else:
        tiles.append(main_frame.create_rectangle(650 + (i * 50), 700, 700 + (i * 50), 580, fill="white"))

tiles.append(main_frame.create_rectangle(1000, 470, 1050, 580, fill="gray"))

# yellow house tiles
for i in range(7):
    tiles.append(main_frame.create_rectangle(1000 - (i * 50), 470, 950 - (i * 50), 580, fill="yellow"))
tiles.append(main_frame.create_polygon(650,400,525,525,650,650, fill="yellow", outline = "black"))

# blue house tiles
for i in range(7):
    tiles.append(main_frame.create_rectangle(470,50+ (i * 50),580,100+ (i * 50), fill = "blue"))
tiles.append(main_frame.create_polygon(650,400,525,525,400,400, fill = "blue", outline = "black"))

# red house tiles

for i in range(7):
    tiles.append(main_frame.create_rectangle(50+ (i * 50),470,100+ (i * 50),580, fill = "red"))
tiles.append(main_frame.create_polygon(400,650,525,525,400,400, fill = "red", outline = "black"))

#green house tiles

for i in range(7):
    tiles.append(main_frame.create_rectangle(470,1000- (i * 50),580,950- (i * 50), fill = "green"))

tiles.append(main_frame.create_polygon(400,650,525,525,650,650, fill = "green", outline = "black"))

main_frame.tag_raise(8)

# creating all the numbers
for i in range(68):
    if i == 24:
        main_frame.create_text(main_frame.coords(tiles[i])[0] + 60, main_frame.coords(tiles[i])[1] + 10, text=i + 1)
    else:
        main_frame.create_text(main_frame.coords(tiles[i])[0] + 10, main_frame.coords(tiles[i])[1] + 10, text=i + 1)


# player square


top_left_rec = main_frame.create_rectangle(0, 0, 350, 350, fill="blue")
top_right_rec = main_frame.create_rectangle(700, 0, 1050, 350, fill="Yellow")
bottom_left_rec = main_frame.create_rectangle(0, 700, 350, 1050, fill="red")
bottom_right_rec = main_frame.create_rectangle(700, 700, 1050, 1050, fill="green")

## players
blue = []

blue.append(Counter(0, 0, (100, 100) ,"b1",main_frame.create_oval(100, 100, 135, 135, fill="royal blue"), block = False))
blue.append(Counter(0, 0, (250, 250) ,"b2",main_frame.create_oval(250, 250, 215, 215, fill="royal blue"), block = False))
blue.append(Counter(0, 0, (250, 100),"b3",main_frame.create_oval(250, 100, 215, 135, fill="royal blue"), block = False))
blue.append(Counter(0, 0, (100, 250) ,"b4",main_frame.create_oval(100, 250, 135, 215, fill="royal blue"), block = False))

yellow = []
yellow.append(Counter(0, 0, (800, 100),"y1",main_frame.create_oval(800, 100, 835, 135, fill="yellow"), block = False))
yellow.append(Counter(0, 0, (950, 250),"y2",main_frame.create_oval(950, 250, 915, 215, fill="yellow"), block = False))
yellow.append(Counter(0, 0, (950, 100),"y3",main_frame.create_oval(950, 100, 915, 135, fill="yellow"), block = False))
yellow.append(Counter(0, 0, (800, 250),"y4",main_frame.create_oval(800, 250, 835, 215, fill="yellow"), block = False))


red = []

red.append(Counter(0, 0, (100, 800),"r1",main_frame.create_oval(100, 800, 135, 835, fill="red2"), block = False))
red.append(Counter(0, 0, (250, 950),"r2",main_frame.create_oval(250, 950, 215, 915, fill="red2"), block = False))
red.append(Counter(0, 0, (250, 800),"r3",main_frame.create_oval(250, 800, 215, 835, fill="red2"), block = False))
red.append(Counter(0, 0, (100, 950),"r4",main_frame.create_oval(100, 950, 135, 915, fill="red2"), block = False))

green = []

green.append(Counter(0, 0, (800, 800),"g1",main_frame.create_oval(800, 800, 835, 835, fill="green"), block = False))
green.append(Counter(0, 0, (950, 950),"g2",main_frame.create_oval(950, 950, 915, 915, fill="green"), block = False))
green.append(Counter(0, 0, (950, 800),"g3",main_frame.create_oval(950, 800, 915, 835, fill="green"), block = False))
green.append(Counter(0, 0, (800, 950),"g4",main_frame.create_oval(800, 950, 835, 915, fill="green"), block = False))

# functions
            
def valid_move(counter, dice_roll):
    safe_tiles = [1,8,13,18,25,30,35,42,47,52,59,64]
    print(counter)
    if counter.current_tile_order + dice_roll > 72:
        return False
    for i in range (counter.current_tile_order+1,counter.current_tile_order+dice_roll+1):
        for j in players:
            x = 0
            for b in j:                                
                if b.current_tile ==  order_list[players.index(current_player)][i] and i != 72:
                    x += 1
                if x == 2:
                    return False
    
    for player in players:
        for victim in player:
            if victim not in current_player and order_list[players.index(current_player)][counter.current_tile_order + dice_roll] == victim.current_tile and victim.current_tile_order in safe_tiles:
                return False
    if counter.current_tile_order+dice_roll > 72:
                return False
    return True

def will_eat(counter,dice_roll):
    for j in players:
        for b in j:
            if order_list[players.index(current_player)][counter.current_tile_order + dice_roll] == b.current_tile:
                    return True
    return False

def will_make_blockade(counter,dice_roll):
    for j in players:
        for b in j:                
            if b in current_player and order_list[players.index(current_player)][counter.current_tile_order + dice_roll] == b.current_tile:
                return True
    return False

players_string = ["yellow","blue","red","green"]
def change_turn():
    global current_player
    c = players.index(current_player)
    current_player = players[(c+1)%4]
    players_string = ["yellow","blue","red","green"]
    turn_label = Label(menu, text = players_string[(c+1)%4], font=("Helvetica", 32), bg = players_string[(c+1)%4])
    turn_label.grid(row = 3, column = 0, sticky = (N,E,S,W))

def eat_player(counter, dice_roll, is_a):
    global aUsed, bUsed, a, b
    for player in players:
        for counters in player:
            if order_list[players.index(current_player)][counter.current_tile_order + dice_roll] == counters.current_tile:
                counter.move(counter.current_tile_order + dice_roll)
                counters.hui_jia()
    if is_a:
        a = 20
        aUsed = False
    else:
        b = 20
        bUsed = False
    
def win(player):
    for i in player:
        if i.current_tile_order != 72:
            return False
    return True                
                

prevprev = False
prev = False
def dice_roll():
    global a , b, prev , prevprev
    dice.config(state = "disabled")
    a = random.randint(1,6)
    b = random.randint(1,6)
    a_l = Label(menu, text = a,font=("Helvetica", 32), bg = "gray")
    a_l.grid(row = 1 ,column = 0,sticky = (N,E,S,W))
    b_l = Label(menu, text = b,font=("Helvetica", 32),bg = "gray")
    b_l.grid(row = 2 ,column = 0,sticky = (N,E,S,W) )
    if a == b:     
        if prevprev and prev:
            current_biggest = current_player[0]                      
            for i in current_player:
                if i.current_tile_order >= current_biggest.current_tile_order and i.current_tile_order <= 64:
                    current_biggest = i
            current_biggest.hui_jia() 
            change_turn()
            print("hi")
            prevprev = False
            prev = False
            dice.config(state = "normal")
        else:
            turn()                               
            prevprev = prev
            prev = True
            dice.config(state = "normal")
    else:
        turn()
        change_turn()
        prevprev = False
        prev = False
        dice.config(state = "normal") 
    
aUsed = False
bUsed = False
check_a = IntVar()### waits untill the variable is updated 
check_b = IntVar()

def move_counter_a(counter,movable_list_a,movable_list_button_a,movable_list_text_a,movable_list_b,movable_list_button_b,movable_list_text_b):
    global bUsed, aUsed, a, b
    hasEaten = False
    if(will_make_blockade(counter, a)):
        print("making blockade")
        counter.block = True
        counter.move(counter.current_tile_order+a)
        aUsed = True
    elif(will_eat(counter, a)):
        print("eating")
        eat_player(counter, a, True)
        print(a, aUsed)
        for i in range(0, len(movable_list_a)):
            main_frame.delete(movable_list_a[i])
            main_frame.delete(movable_list_button_a[i])
            main_frame.delete(movable_list_text_a[i])
        movable_list_a.clear()
        movable_list_button_a.clear()
        movable_list_text_a.clear()
        for counters in current_player:
            if counters.current_tile !=0 and (not aUsed) and valid_move(counters, a):   
                movable_list_a.append(counters)
                movable_list_button_a.append(main_frame.create_oval(main_frame.coords(counters.current_tile)[0], main_frame.coords(counters.current_tile)[1]+40,main_frame.coords(counters.current_tile)[0]+20,main_frame.coords(counters.current_tile)[1]+60, fill="NavajoWhite2", outline="grey60"))
                movable_list_text_a.append(main_frame.create_text(main_frame.coords(counters.current_tile)[0]+10, main_frame.coords(counters.current_tile)[1]+50, text = a, font=("Helvetica", 10)))
                main_frame.tag_bind(movable_list_button_a[len(movable_list_button_a)-1], "<Button-1>", lambda event, counter=movable_list_a[len(movable_list_button_a)-1]: move_counter_a(counter,movable_list_a,movable_list_text_a,movable_list_button_a,movable_list_b,movable_list_text_b,movable_list_button_b))
                main_frame.tag_bind(movable_list_text_a[len(movable_list_button_a)-1], "<Button-1>", lambda event, counter=movable_list_a[len(movable_list_button_a)-1]: move_counter_a(counter,movable_list_a,movable_list_text_a,movable_list_button_a,movable_list_b,movable_list_text_b,movable_list_button_b))
        if len(movable_list_a) == 0:
            aUsed = True
        hasEaten = True
    else:
        counter.move(counter.current_tile_order+a)
        aUsed = True
            
    for i in range(0, len(movable_list_b)):
        main_frame.delete(movable_list_b[i])
        main_frame.delete(movable_list_button_b[i])
        main_frame.delete(movable_list_text_b[i])
    movable_list_b.clear()
    movable_list_button_b.clear()
    movable_list_text_b.clear()
    if not hasEaten:
        for i in range(0, len(movable_list_a)):
            main_frame.delete(movable_list_a[i])
            main_frame.delete(movable_list_button_a[i])
            main_frame.delete(movable_list_text_a[i])
        movable_list_a.clear()
        movable_list_button_a.clear()
        movable_list_text_a.clear()
    for counters in current_player:    
        if counters.current_tile !=0 and (not bUsed) and valid_move(counters, b):   
            movable_list_b.append(counters)
            movable_list_button_b.append(main_frame.create_oval(main_frame.coords(counters.current_tile)[0]+20, main_frame.coords(counters.current_tile)[1]+40,main_frame.coords(counters.current_tile)[0]+40,main_frame.coords(counters.current_tile)[1]+60, fill="NavajoWhite2", outline="grey60"))
            movable_list_text_b.append(main_frame.create_text(main_frame.coords(counters.current_tile)[0]+30, main_frame.coords(counters.current_tile)[1]+50, text = b, font=("Helvetica", 10)))
            main_frame.tag_bind(movable_list_button_b[len(movable_list_button_b)-1], "<Button-1>", lambda event, counter=movable_list_b[len(movable_list_button_b)-1]: move_counter_b(counter,movable_list_b,movable_list_text_b,movable_list_button_b,movable_list_a,movable_list_text_a,movable_list_button_a))
            main_frame.tag_bind(movable_list_text_b[len(movable_list_button_b)-1], "<Button-1>", lambda event, counter=movable_list_b[len(movable_list_button_b)-1]: move_counter_b(counter,movable_list_b,movable_list_text_b,movable_list_button_b,movable_list_a,movable_list_text_a,movable_list_button_a))
    if len(movable_list_b) == 0:
        bUsed = True
    if(aUsed):
        check_a.set(1)
    
    
def move_counter_b(counter,movable_list_b,movable_list_button_b,movable_list_text_b,movable_list_a,movable_list_button_a,movable_list_text_a):
    global bUsed, aUsed,a, b
    hasEaten = False             
    if(will_make_blockade(counter, b)):
        print("making blockade")
        counter.block = True
        counter.move(counter.current_tile_order+b)
        bUsed = True
    elif(will_eat(counter, b)):
        print("eating")
        eat_player(counter, b, False)
        print(b, bUsed)
        for i in range(0, len(movable_list_b)):
            main_frame.delete(movable_list_b[i])
            main_frame.delete(movable_list_button_b[i])
            main_frame.delete(movable_list_text_b[i])
        movable_list_b.clear()
        movable_list_button_b.clear()
        movable_list_text_b.clear()
        for counters in current_player:    
            if counters.current_tile !=0 and (not bUsed) and valid_move(counters, b):   
                movable_list_b.append(counters)
                movable_list_button_b.append(main_frame.create_oval(main_frame.coords(counters.current_tile)[0]+20, main_frame.coords(counters.current_tile)[1]+40,main_frame.coords(counters.current_tile)[0]+40,main_frame.coords(counters.current_tile)[1]+60, fill="NavajoWhite2", outline="grey60"))
                movable_list_text_b.append(main_frame.create_text(main_frame.coords(counters.current_tile)[0]+30, main_frame.coords(counters.current_tile)[1]+50, text = b, font=("Helvetica", 10)))
                main_frame.tag_bind(movable_list_button_b[len(movable_list_button_b)-1], "<Button-1>", lambda event, counter=movable_list_b[len(movable_list_button_b)-1]: move_counter_b(counter,movable_list_b,movable_list_text_b,movable_list_button_b,movable_list_a,movable_list_text_a,movable_list_button_a))
                main_frame.tag_bind(movable_list_text_b[len(movable_list_button_b)-1], "<Button-1>", lambda event, counter=movable_list_b[len(movable_list_button_b)-1]: move_counter_b(counter,movable_list_b,movable_list_text_b,movable_list_button_b,movable_list_a,movable_list_text_a,movable_list_button_a))
        if len(movable_list_b) == 0:
            bUsed = True
        hasEaten = True
    else:
        counter.move(counter.current_tile_order+b)
        bUsed = True
    if not hasEaten:   
        for i in range(0, len(movable_list_b)):
            main_frame.delete(movable_list_b[i])
            main_frame.delete(movable_list_button_b[i])
            main_frame.delete(movable_list_text_b[i])
        movable_list_b.clear()
        movable_list_button_b.clear()
        movable_list_text_b.clear()
    for i in range(0, len(movable_list_a)):
        main_frame.delete(movable_list_a[i])
        main_frame.delete(movable_list_button_a[i])
        main_frame.delete(movable_list_text_a[i])
    movable_list_a.clear()
    movable_list_button_a.clear()
    movable_list_text_a.clear()
    for counters in current_player:
        if counters.current_tile !=0 and (not aUsed) and valid_move(counters, a):   
            movable_list_a.append(counters)
            movable_list_button_a.append(main_frame.create_oval(main_frame.coords(counters.current_tile)[0], main_frame.coords(counters.current_tile)[1]+40,main_frame.coords(counters.current_tile)[0]+20,main_frame.coords(counters.current_tile)[1]+60, fill="NavajoWhite2", outline="grey60"))
            movable_list_text_a.append(main_frame.create_text(main_frame.coords(counters.current_tile)[0]+10, main_frame.coords(counters.current_tile)[1]+50, text = a, font=("Helvetica", 10)))
            main_frame.tag_bind(movable_list_button_a[len(movable_list_button_a)-1], "<Button-1>", lambda event, counter=movable_list_a[len(movable_list_button_a)-1]: move_counter_a(counter,movable_list_a,movable_list_text_a,movable_list_button_a,movable_list_b,movable_list_text_b,movable_list_button_b))
            main_frame.tag_bind(movable_list_text_a[len(movable_list_button_a)-1], "<Button-1>", lambda event, counter=movable_list_a[len(movable_list_button_a)-1]: move_counter_a(counter,movable_list_a,movable_list_text_a,movable_list_button_a,movable_list_b,movable_list_text_b,movable_list_button_b))
    if len(movable_list_a) == 0:
        aUsed = True
    if(bUsed):
        check_b.set(1)
    
        
def turn():
    global aUsed, bUsed, a, b
    spaces = 2
    invaders = []
    for player in players:
        if player != current_player:
            for counter in player:
                if counter.current_tile == order_list[players.index(current_player)][1]:
                    invaders.append(counter)
    came_out = 0
    if len(invaders) < 2:
        for i in current_player:
            if i.current_tile_order == 1:
                spaces -= 1
        for i in current_player:
            if i.current_tile == 0 and spaces >= 1:
                if (a == 5 and b == 5 ):
                    came_out += 1
                    if spaces != 2:
                        i.block = True
                        i.move(1)
                        spaces -= 1
                        bUsed = True
                    else:
                        i.move(1)
                        spaces -= 1
                        aUsed = True
                elif (a + b) == 5:
                    came_out += 1
                    if spaces != 2:
                        i.block = True
                        i.move(1)
                        bUsed = True
                        aUsed = True
                        break
                    else:
                        i.move(1)
                        bUsed = True
                        aUsed = True
                        break
                elif (a==5 or b==5):
                    came_out += 1
                    if spaces != 2:
                        i.block = True
                        i.move(1)
                        if a == 5:
                            aUsed = True
                        else:
                            bUsed = True
                        break
                    else:
                        i.move(1)
                        if a == 5:
                            aUsed = True
                        else:
                            bUsed = True
                        break
    if len(invaders) == 1 and came_out != 0:
        invaders[0].hui_jia()
        if aUsed:
            a = 20
            aUsed = False
        else:
            b = 20
            bUsed = False
    
    movable_list_a = []
    movable_list_button_a = []
    movable_list_text_a = []
    movable_list_b = []
    movable_list_button_b = []
    movable_list_text_b = []
    for counter in current_player:
        if counter.current_tile !=0 and (not aUsed) and valid_move(counter, a):   
            movable_list_a.append(counter)
            movable_list_button_a.append(main_frame.create_oval(main_frame.coords(counter.current_tile)[0], main_frame.coords(counter.current_tile)[1]+40,main_frame.coords(counter.current_tile)[0]+20,main_frame.coords(counter.current_tile)[1]+60, fill="NavajoWhite2", outline="grey60"))
            movable_list_text_a.append(main_frame.create_text(main_frame.coords(counter.current_tile)[0]+10, main_frame.coords(counter.current_tile)[1]+50, text = a, font=("Helvetica", 10)))
            main_frame.tag_bind(movable_list_button_a[len(movable_list_button_a)-1], "<Button-1>", lambda event, counter=movable_list_a[len(movable_list_button_a)-1]: move_counter_a(counter,movable_list_a,movable_list_text_a,movable_list_button_a,movable_list_b,movable_list_text_b,movable_list_button_b))
            main_frame.tag_bind(movable_list_text_a[len(movable_list_button_a)-1], "<Button-1>", lambda event, counter=movable_list_a[len(movable_list_button_a)-1]: move_counter_a(counter,movable_list_a,movable_list_text_a,movable_list_button_a,movable_list_b,movable_list_text_b,movable_list_button_b))
        if counter.current_tile !=0 and (not bUsed) and valid_move(counter, b):   
            movable_list_b.append(counter)
            movable_list_button_b.append(main_frame.create_oval(main_frame.coords(counter.current_tile)[0]+20, main_frame.coords(counter.current_tile)[1]+40,main_frame.coords(counter.current_tile)[0]+40,main_frame.coords(counter.current_tile)[1]+60, fill="NavajoWhite2", outline="grey60"))
            movable_list_text_b.append(main_frame.create_text(main_frame.coords(counter.current_tile)[0]+30, main_frame.coords(counter.current_tile)[1]+50, text = b, font=("Helvetica", 10)))
            main_frame.tag_bind(movable_list_button_b[len(movable_list_button_b)-1], "<Button-1>", lambda event, counter=movable_list_b[len(movable_list_button_b)-1]: move_counter_b(counter,movable_list_b,movable_list_text_b,movable_list_button_b,movable_list_a,movable_list_text_a,movable_list_button_a))
            main_frame.tag_bind(movable_list_text_b[len(movable_list_button_b)-1], "<Button-1>", lambda event, counter=movable_list_b[len(movable_list_button_b)-1]: move_counter_b(counter,movable_list_b,movable_list_text_b,movable_list_button_b,movable_list_a,movable_list_text_a,movable_list_button_a))
    
    if win(current_player):
        main_frame.create_text(425, 425, text = players_string[players.index(current_player)] + " Wins", font=("Helvetica", 100)) 
        
    if(len(movable_list_a) != 0):
        menu.wait_variable(check_a)
        
    if(not bUsed and len(movable_list_b) != 0):
        menu.wait_variable(check_b)
    
    if win(current_player):
        main_frame.create_text(425, 425, text = players_string[players.index(current_player)] + " Wins", font=("Helvetica", 100)) 
                 
    aUsed = False
    bUsed = False
           
        

  
                    

## dice
dice = Button(menu, text = "roll dice", font=("Helvetica", 32), command = dice_roll, relief = SUNKEN)
dice.grid(row = 0, column = 0,sticky = (N,E,S,W))


current_player = yellow
players = [yellow, blue, red , green]

board.mainloop()