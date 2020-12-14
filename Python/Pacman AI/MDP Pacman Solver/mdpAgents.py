# mdpAgents.py
# parsons/20-nov-2017
#
# Version 1
#
# The starting point for CW2.
#
# Intended to work with the PacMan AI projects from:
#
# http://ai.berkeley.edu/
#
# These use a simple API that allow us to control Pacman's interaction with
# the environment adding a layer on top of the AI Berkeley code.
#
# As required by the licensing agreement for the PacMan AI we have:
#
# Licensing Information:  You are free to use or extend these projects for
# educational purposes provided that (1) you do not distribute or publish
# solutions, (2) you retain this notice, and (3) you provide clear
# attribution to UC Berkeley, including a link to http://ai.berkeley.edu.
# 
# Attribution Information: The Pacman AI projects were developed at UC Berkeley.
# The core projects and autograders were primarily created by John DeNero
# (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# Student side autograding was added by Brad Miller, Nick Hay, and
# Pieter Abbeel (pabbeel@cs.berkeley.edu).


from pacman import Directions
from game import Agent
import api
import random
import game
import util
from copy import copy, deepcopy


class MDPAgent(Agent):
    
    # Constructor: this gets run when we first invoke pacman.py
    def __init__(self):
        print "Starting up MDPAgent!"
        name = "Pacman"
        self.map = None
        self.grassfireMap1 = None
        self.grassfireMap2 = None

    # Gets run after an MDPAgent object is created and once there is
    # game state to access.
    def registerInitialState(self, state):
        print "Running registerInitialState for MDPAgent!"
        print "I'm at:"
        print api.whereAmI(state)
        
    # This is what gets run in between multiple games
    def final(self, state):
        print "Looks like the game just ended!"
    
    
    def getAction(self, state):
        self.createMap(state) #Creates the intial map of values
        self.bellmanUpdate(state) # iterates over the map and preforms bellmans equation on every cell to calcuate its utility
        legal = api.legalActions(state)
        
        if Directions.STOP in legal:
            legal.remove(Directions.STOP)
            
        x = api.whereAmI(state)[0]
        y = api.whereAmI(state)[1]
        best = None
        bestUtil = -1000
        direction = [Directions.NORTH, Directions.EAST, Directions.SOUTH, Directions.WEST] 
        moves = [self.map[x][y+1],self.map[x+1][y], self.map[x][y-1], self.map[x-1][y]] #creates a list of all moves pacman can make
        
        for i in range(0,len(direction)): #For each possible move calculate the utility and pick the best one
            if direction[i] in legal:
                util = moves[i]*0.8
                if direction[i-1] in legal:
                    util += moves[i-1]*0.1
                else:
                    util += self.map[x][y]*0.1
                if direction[(i+1)%4] in legal:
                    util += moves[(i+1)%4]*0.1
                else:
                    util += self.map[x][y]*0.1
                if util> bestUtil:
                    best = direction[i]
                    bestUtil = deepcopy(util)
                    
        return api.makeMove(best, legal) #apply the best move
    
    def createMap(self, state): #initialises the 3 maps that will be used throughout the solver
        ghostList = api.ghosts(state)
        wallList = api.walls(state)
        foodList = api.food(state)
        capsuleList = api.capsules(state)
        
        #creates three maps, self.map will be the main map that holds utility, grassfireMap1 will be the distance between the first ghost and each food, grassfireMap2 does the samething but with the second ghost
        self.map = deepcopy(state.getFood())
        self.grassfireMap1 = deepcopy(self.map)
        self.grassfireMap2 = deepcopy(self.map)
        
        width = self.map.width
        height = self.map.height
        
        #initialises each map wall = None, every other cell is 0 for the main map and -5 for the ghost-food distance map
        for x in range(width):
            for y in range(height):
                if (x,y) in wallList:
                    self.map[x][y] = None
                    self.grassfireMap1[x][y] = None
                    self.grassfireMap2[x][y] = None 
                elif (x,y) in foodList:
                    self.map[x][y] = 0
                    self.grassfireMap1[x][y] = -5
                    self.grassfireMap2[x][y] = -5
                elif (x,y) in ghostList:
                    self.map[x][y] = 0
                    self.grassfireMap1[x][y] = -5
                    self.grassfireMap2[x][y] = -5
                elif (x,y) in capsuleList:
                     self.map[x][y] = 0
                     self.grassfireMap1[x][y] = -5
                     self.grassfireMap2[x][y] = -5
                else:
                    self.map[x][y] = 0
                    self.grassfireMap1[x][y] = -5
                    self.grassfireMap2[x][y] = -5
        
        #iterates over each ghost and updates each map accordingly using grass fire algorithm            
        i = 0
        for ghost in ghostList:
            self.grassfire(ghost[0], ghost[1], wallList, i)
            i += 1
    
    def grassfire(self, gx, gy, wallList, i): #grassfire algorithm that iterates over every cell increasing by one as it gets further from the ghost, gx = x coordinate of ghost and gy = y coordinate of ghost
        width = self.map.width
        height = self.map.height        
        nodesList = []
        visited = []
        #adds the ghost coords to the list of nodes and visited noded
        nodesList.append((gx, gy))
        visited.append((gx,gy))
        
        while(nodesList): #iterates until the all cells have been updated
            x = nodesList[0][0]
            y = nodesList[0][1]
            nodesList.remove((x, y))
            self.checkNodes(int(x), int(y), nodesList, visited, i) #adds all adjacent nodes
            
    def checkNodes(self, x, y, nodesList, visited, i):#adds all adjacent nodes and updates the ghost-food distance map (grassfireMap1 and grassfireMap2)
        mapList = [self.grassfireMap1, self.grassfireMap2]
        moves = [(x,y+1), (x+1, y), (x,y-1), (x-1,y)]
        
        for f in range(len(moves)): #looks at each adjacent cell thats not a wall and makes the value the same as the previous node + 1, and adds it to the node list and visited list
            tx = moves[f][0]
            ty = moves[f][1]
            if mapList[i][tx][ty] != None:
                if (tx, ty) not in visited:  
                    mapList[i][tx][ty] = mapList[i][x][y] + 1
                    visited.append((tx, ty))
                    nodesList.append((tx, ty))
                    
    def bellmanUpdate(self, state): #preforms bellmans over the entire map using bellmans equation on each cell
        ghostList = api.ghosts(state)
        foodList = api.food(state)
        wallList = api.walls(state)
        scaredTime = api.ghostStatesWithTimes(state)[0][1]
        capsuleList = api.capsules(state)     
        width = self.map.width
        height = self.map.height
        done = False
        
        while not done: #loops over map preforming bellmans until previous map from the last iteration is equal to the map at the end of the new iteration
            oldMap = deepcopy(self.map)
            
            for x in range(0,width):
                for y in range(0,height):
                    if oldMap[x][y] != None:
                        bestUtil = -1000          
                        moves = [oldMap[x][y+1], oldMap[x+1][y], oldMap[x][y-1], oldMap[x-1][y]] # list of all possible moves from the current cell
                        
                        for i in range(len(moves)):# finds the best util possible based on all legal moves to uses in value iteration
                            if moves[i] != None:
                                tutil = moves[i]*0.8                                
                                if moves[i-1] != None:
                                    tutil += moves[i-1]*0.1
                                else:
                                    tutil += oldMap[x][y]*0.1
                                if moves[(i+1)%4] != None:
                                    tutil += moves[(i+1)%4]*0.1
                                else:
                                    tutil += oldMap[x][y]*0.1
                                if tutil> bestUtil:
                                    bestUtil = deepcopy(tutil)
                                    
                        self.map[x][y] = (bestUtil*0.9) + self.reward(x, y, state, ghostList, foodList, capsuleList, scaredTime, wallList) #bellmans equation using rewards functon           
                          
            done =  self.checkSame(oldMap, self.map) #checks to see whether old map is the same as new map                   
    
    def reward(self, x, y, state, ghostList, foodList, capsuleList, scaredTime, wallList): #reward function decides how much a cell is worth depending on a few factors      
        
        if (x,y) in ghostList and scaredTime > 7: #if time the ghost are scared is more than 7 seconds
            return 3     
        
        elif (x,y) in ghostList:
            return -20
        
        elif (x,y) in foodList:            
            if len(ghostList) == 1:                  
                if len(foodList) == 1: #if its the last food its worth more
                    return 10
                return self.grassfireMap1[x][y] + 1
            
            else:
                return min(self.grassfireMap1[x][y], self.grassfireMap2[x][y]) #using the grassfire maps and the value that is least out of the two of them (using the ghost that is closest)
        
        elif (x,y) in capsuleList:
            return 1
        
        else:
            if len(ghostList) == 1: #Depending on how far the ghosts are the empty spaces are worth more but still negative
                v = self.grassfireMap1[x][y]
                if v> 0:
                    return -1*(1/v)
                else:
                    return 1*v
            else: #same thing as if there is one ghost but uses the closest ghost
                v = self.grassfireMap1[x][y]
                b = self.grassfireMap2[x][y]
                if v> 0 and b>0:
                    return -1*(1/min(v, b))
                else:
                    return 1*min(v, b)
    
    def checkSame(self, oldMap, newMap): #checks if the maps are the same, returns false if they arent and true if they are
        width = self.map.width
        height = self.map.height
        for x in range(0,width):
            for y in range(0,height):
                if oldMap[x][y] != None and round(oldMap[x][y]) != round(newMap[x][y]): #rounds the numbers so that it doesnt go on for too long
                    return False
        return True
    

                
