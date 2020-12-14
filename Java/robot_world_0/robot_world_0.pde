/**
 * robot_world_0.pde (sklar/18-oct-2019)
 *
 * This sketch contains the baseline code for a robot moving around in a grid
 * world.
 *
 */

//------------------------------------------------------------------------------
// Define the size of the robot's world, which we'll set to 20 X 20 grid cells.
final int MAX_X = 20; 
final int MAX_Y = 20;

//------------------------------------------------------------------------------
// Define the size of the display window for the robot's world, which we'll set
// to 500 X 500 pixels. This means that we have to compute the number of pixels r
// per cell, since they sizes are different. Since we want the cells to display
// as squares, we'll use the same pixel scaling factor for both X and Y directions.
// Note that this value is set to be equal to (500/MAX_X), 
// i.e., 500 pixels / MAX_X grid cells
final int PIXELS_PER_CELL = 25; 

//------------------------------------------------------------------------------
// Define a matrix containing the grid cells. We use this to store information 
// about what is contained in a grid cell (e.g., obstacle or empty).
// Note that the matrix is "y major", meaning that the y coordinate comes first.
int world[][] = new int[MAX_Y][MAX_X];
int waveWorld[][] = new int[MAX_Y][MAX_X];
int prev = 0;
int p = 0;
PrintWriter output;
ArrayList<PVector> direction = new ArrayList();
ArrayList<PVector> track = new ArrayList();
int lineof[][]=new int[MAX_Y][MAX_X];
final int CELL_EMPTY    = 0;  // an empty cell
final int CELL_OBSTACLE = -1; // a cell with an obstacle in it

//------------------------------------------------------------------------------
// We want to put some obstacles in the robot's world, so the values below are 
// used to define that feature. Here we define the number of obstacles, which 
// we do as a proportion of the size of the world. We set the proportion to 25%
// of the grid cells as obstacles.
int NUM_OBSTACLES = int(( MAX_X * MAX_Y ) * 0.25 );

//------------------------------------------------------------------------------
// Define variables for representing the robot.
// We use a vector to store the robot's location in grid cell coordinates.
// Note that this means that the robot's drawn location in pixels (drawing window
// coordinates) will be different.
PVector R = new PVector( 0, 0 ); // coordinates of robot's location in grid cells
int iniRx;
int iniRy;
// Define vectors that store changes in grid cell location relative to the robot 
// based on which direction the robot moves.
final PVector NORTH = new PVector( 0, -1 );
final PVector WEST  = new PVector( -1, 0 );
final PVector SOUTH = new PVector( 0, +1 );
final PVector EAST  = new PVector( +1, 0 );
final PVector NORTHEAST  = new PVector( +1, -1 );
final PVector SOUTHEAST  = new PVector( +1, +1 );
final PVector NORTHWEST  = new PVector( -1, -1 );
final PVector SOUTHWEST = new PVector( -1, +1 );
// The robot has 4 range sensors which detect things relative to the robot in 
// each compass direction.
int sensors[] = new int[8];

//------------------------------------------------------------------------------
// Define a target location for the robot to go to, in grid cell coordinates.
PVector T = new PVector( 0, 0 );
int iniTx;
int iniTy;
//------------------------------------------------------------------------------
// Define a set of colours for filling in cells in the robot's world when drawn.
final int COLOUR_EMPTY    = #ffffff;
final int COLOUR_GRID     = #999999;
final int COLOUR_OBSTACLE = #666666;
final int COLOUR_ROBOT    = #000099;
final int COLOUR_TARGET   = #990000;
final int COLOUR_DONE   = #1AD822;
//------------------------------------------------------------------------------
// Define a font size that will let us put labels in grid cells 
final int FONT_SIZE = 14;



//------------------------------------------------------------------------------

/**
 * setup()
 * This function is called automatically by Processing when a sketch starts to run.
 */
void setup() {
  // set size of robot's world in pixels, which translates to MAX_X x MAX_Y in cells
  // 500 x 500 => (MAX_X * PIXELS_PER_CELL) x (MAX_Y * PIXELS_PER_CELL)
  size( 500, 500 );
  // set font size for labelling cells
  textSize( FONT_SIZE );
  // initialise locations and robot's world
  reset();
   
  //sense();
} // end of setup()

//------------------------------------------------------------------------------

/**
 * initWorld()
 * This function initialises the robot's grid world.
 */
void initWorld() {
  // initialise the world to all empty cells
  for ( int y=0; y<MAX_Y; y++ ) {
    for ( int x=0; x<MAX_X; x++ ) {
      world[y][x] = CELL_EMPTY;
    }
  }
} // end of initWorld()

//------------------------------------------------------------------------------

/**
 * pickRandomCell()
 * This function picks a random cell within the robot's world and returns it as a vector.
 * Note that the value returned is in grid cell coordinates.
 */
PVector pickRandomCell() {
  PVector tmp = new PVector();
  tmp.x = int( random( MAX_X ));
  tmp.y = int( random( MAX_Y ));
  return( tmp );
} // end of pickRandomCell()

//------------------------------------------------------------------------------

/**
 * findEmptyCell()
 * This function returns a vector with the coordinates of a randomly chosen empty 
 * cell in the robot's world.
 * Note that the value returned is in grid cell coordinates.
 * Also note that this function is far from perfect (!) for the following reasons:
 * (1) It can fail if there are no empty cells left in the grid.
 * (2) It can take a long time to return if cells are not empty.
 */
PVector findEmptyCell() {
  PVector tmp = pickRandomCell();
  boolean found = false;
  while ( ! found ) {
    if ( world[int(tmp.y)][int(tmp.x)] == CELL_EMPTY ) {
      found = true;
    } else {
      tmp = pickRandomCell();
    }
  } // end while
  return( tmp );
} // end of findEmptyCell()

//------------------------------------------------------------------------------

/**
 * reset()
 * This function (re-)initialises the robot's world.
 */
void reset() {
  output = createWriter("dataA.csv");
  PVector tmp;
  // Initialise the robot's world
  initWorld();
  // Define locations for obstacles in randomly chosen empty cells
  for ( int num=0; num < NUM_OBSTACLES; num++ ) {
    tmp = findEmptyCell();
    world[int(tmp.y)][int(tmp.x)] = CELL_OBSTACLE;
  }
  // Define a location for the target in a randomly chosen empty cell
  T = findEmptyCell();
  iniTx = (int) T.x;
  iniTy = (int) T.y;
  // Define the starting location for robot in a randomly chosen empty cell
  R = findEmptyCell();
  iniRx = (int) R.x;
  iniRy = (int) R.y;
  // activate the robot's sonar sensors
  sense();
  prev = 0;
  for (int i = 0; i < MAX_Y; ++i) {
    // codes inside the body of outer loop
    for (int j = 0; j <MAX_X; ++j) {
      waveWorld[i][j] = 0;
      lineof[i][j] =0;
    }
    // codes inside the body of outer loop
  }
  direction.clear();
   track.clear();

} // end of reset()

void replay() {

  T.x =iniTx;
  T.y = iniTy;

  R.x =iniRx;
  R.y = iniRy;

  sense();
  prev = 0;
  for (int i = 0; i < MAX_Y; ++i) {
    // codes inside the body of outer loop
    for (int j = 0; j <MAX_X; ++j) {
      waveWorld[i][j] = 0;
      lineof[i][j] =0;
      if (world[i][j] == -2) {
        world[i][j] =0;
      }
    }
    // codes inside the body of outer loop
  }
  direction.clear();
  track.clear();
  
  if(p == 0){
    output.println("List of obastcles: ");
  for ( int x=0; x<MAX_X; x++ ) {
    for ( int y=0; y<MAX_Y; y++ ) {
      if(world[y][x] == -1){
  output.println("(" + x + "," + y+ ")");
      }
    if(x == (int) T.x && y == (int) T.y){
  output.println("Target: " + "(" + x + "," + y+ ")");
    }
    if(x == (int) R.x && y== (int) R.y){
  output.println("Robot: " + "(" + x + "," + y+ ")");
    }
    }
    
   }
  }
} // end of reset()


//------------------------------------------------------------------------------

/**
 * validCell()
 * This function returns true if the argument (x,y) coordinates are valid within 
 * the robot's grid world coordinate system.
 */
boolean validCell( int x, int y ) {
  if (( x >= 0 ) && ( x < MAX_X ) && ( y >= 0 ) && ( y < MAX_Y ) && world[y][x] != -1 && world[y][x] != -3) {

    return( true );
  } else {
    return( false );
  }
} // end of validCell()

//------------------------------------------------------------------------------

/**
 * sense()
 * This function emulates the operation of the robot's sensors.
 * Each sensor is set equal to the distance (in cells) to the closest obstacle, 
 * within the sensor range (1 cell), for each of the 4 compass directions:
 * 5 0 4
 * 1 R 3
 * 6 2 7
 */
void sense() {
  int cell_x, cell_y;
  // check the cell to the north of the robot
  cell_x = int( R.x + NORTH.x );
  cell_y = int( R.y + NORTH.y );
  boolean notFound = true;
  int b = 0;
  for (int i = cell_y; notFound; --i) { 
    if (( cell_x >= 0 ) && ( cell_x < MAX_X ) && ( i >= 0 ) && ( i < MAX_Y )) {
      if ( world[i][cell_x] != CELL_EMPTY || i == -1) {
        sensors[0] = b;
        notFound = false;
      } else {
        b++;
      }
    } else {
      notFound = false;
      sensors[0] = b;
    }
  }

  b = 0;
  notFound = true;
  // check the cell to the west of the robot
  cell_x = int( R.x + WEST.x );
  cell_y = int( R.y + WEST.y );
  for (int i = cell_x; notFound; --i) {
    if (( i >= 0 ) && ( i < MAX_X ) && ( cell_y >= 0 ) && ( cell_y < MAX_Y )) {
      if ( world[cell_y][i] != CELL_EMPTY || i == -1 ) {
        sensors[1] = b;
        notFound = false;
      } else {
        ++b;
      }
    } else {
      notFound = false;
      sensors[1] = b;
    }
  }


  b = 0;
  notFound = true;
  // check the cell to the south of the robot
  cell_x = int( R.x + SOUTH.x );
  cell_y = int( R.y + SOUTH.y );
  for (int i = cell_y; notFound; ++i) { 
    if (( cell_x >= 0 ) && ( cell_x < MAX_X ) && ( i >= 0 ) && ( i < MAX_Y )) {
      if ( world[i][cell_x] != CELL_EMPTY || i == MAX_Y + 1) {
        sensors[2] = b;
        notFound = false;
      } else {
        b++;
      }
    } else {
      notFound = false;
      sensors[2] = b;
    }
  }

  b = 0;
  notFound = true;
  // check the cell to the east of the robot
  cell_x = int( R.x + EAST.x );
  cell_y = int( R.y + EAST.y );
  for (int i = cell_x; notFound; ++i) {
    if (( i >= 0 ) && ( i < MAX_X ) && ( cell_y >= 0 ) && ( cell_y < MAX_Y )) {
      if ( world[cell_y][i] != CELL_EMPTY || i == MAX_X + 1 ) {
        sensors[3] = b;
        notFound = false;
      } else {
        ++b;
      }
    } else {
      notFound = false;
      sensors[3] = b;
    }
  }

  b = 0;
  notFound = true;
  // check the cell to the east of the robot
  cell_x = int( R.x + EAST.x );
  cell_y = int( R.y + NORTH.y );
  for (int i = cell_x, r = cell_y; notFound; ++i, --r ) {
    if (( i >= 0 ) && ( i < MAX_X ) && ( r >= 0 ) && ( r < MAX_Y )) {
      if ( world[r][i] != CELL_EMPTY || i == MAX_X + 1 || r == 0 - 1  ) {
        sensors[4] = b;
        notFound = false;
      } else {
        ++b;
      }
    } else {
      notFound = false;
      sensors[4] = b;
    }
  }

  b = 0;
  notFound = true;
  // check the cell to the north west of the robot
  cell_x = int( R.x + WEST.x );
  cell_y = int( R.y + NORTH.y );
  for (int i = cell_x, r = cell_y; notFound; --i, --r ) {
    if (( i >= 0 ) && ( i < MAX_X ) && ( r >= 0 ) && ( r < MAX_Y )) {
      if ( world[r][i] != CELL_EMPTY || i == 0 - 1 || r == 0 - 1  ) {
        sensors[5] = b;
        notFound = false;
      } else {
        ++b;
      }
    } else {
      notFound = false;
      sensors[5] = b;
    }
  }

  b = 0;
  notFound = true;
  // check the cell to the north west of the robot
  cell_x = int( R.x + WEST.x );
  cell_y = int( R.y + SOUTH.y );
  for (int i = cell_x, r = cell_y; notFound; --i, ++r ) {
    if (( i >= 0 ) && ( i < MAX_X ) && ( r >= 0 ) && ( r < MAX_Y )) {
      if ( world[r][i] != CELL_EMPTY || i == 0 - 1 || r == MAX_Y +1  ) {
        sensors[6] = b;
        notFound = false;
      } else {
        ++b;
      }
    } else {
      notFound = false;
      sensors[6] = b;
    }
  }


  b = 0;
  notFound = true;
  // check the cell to the north west of the robot
  cell_x = int( R.x + EAST.x );
  cell_y = int( R.y + SOUTH.y );
  for (int i = cell_x, r = cell_y; notFound; ++i, ++r ) {
    if (( i >= 0 ) && ( i < MAX_X ) && ( r >= 0 ) && ( r < MAX_Y )) {
      if ( world[r][i] != CELL_EMPTY || i == MAX_X + 1 || r == MAX_Y +1  ) {
        sensors[7] = b;
        notFound = false;
      } else {
        ++b;
      }
    } else {
      notFound = false;
      sensors[7] = b;
    }
  }

  // end of sense()
}
//------------------------------------------------------------------------------

/**
 * moveRobot()
 * This function moves the robot in the specified direction.
 * It updates the robot's world accordingly.
 */
void moveRobot( PVector dir ) {
  // Move the robot in the direction specified, as long as it will end up in a 
  // valid cell (i.e., doesn't run off the end of the world).
  world[(int)R.y][(int)R.x] = -2;
  int move_to_x = int( R.x + dir.x );
  int move_to_y = int( R.y + dir.y );

  if ( validCell( move_to_x, move_to_y )) {
    // Update the robot's location.
    R.x = move_to_x;
    R.y = move_to_y;
    // Update the robot's sensors from its new location.
    sense();
  }
  if (( R.x == T.x ) && ( R.y == T.y )) {
    println("yippee");
  }
  track.add(new PVector(R.x, R.y));
} // end of moveRobot()

//------------------------------------------------------------------------------

/**
 * keyPressed()
 * This function is called when any key is pressed and do the following:
 *  'q' or 'Q'  : sketch quits (exits)
 *  ' ' (space) : world resets
 *  up-arrow    : robot moves up (north)
 *  down-arrow  : robot moves down (south)
 *  left-arrow  : robot moves left (west)
 *  right-arrow : robot moves right (east)
 */
void keyPressed() {
  if (( key == 'q' ) || ( key == 'Q' )) { // q/Q pressed, meaning "quit"
    exit();
  } else if ( key == ' ' ) { // space pressed, meaning "reset"
    reset();
  } else if (( key == CODED ) && ( keyCode == UP )) { // up arrow pressed
    moveRobot( NORTH );
    //R.y = int(R.y) - 1;
  } else if (( key == CODED ) && ( keyCode == DOWN )) { // down arrow pressed
    moveRobot( SOUTH );
    //R.y = int(R.y) + 1;
  } else if (( key == CODED ) && ( keyCode == LEFT )) { // left arrow pressed
    moveRobot( WEST );
    //R.x = int(R.x) - 1;
  } else if (( key == CODED ) && ( keyCode == RIGHT )) { // right arrow pressed
    moveRobot( EAST );
    //R.x = int(R.x) + 1;
  } else if (( key == 'b' ) || ( key == 'B' )) { // q/Q pressed, meaning "quit"
    bugSearch();
  } else if (( key == 'l' ) || ( key == 'L' )) { // q/Q pressed, meaning "quit"
    lineof();
  } else if (( key == 'w' ) || ( key == 'W' )) { // q/Q pressed, meaning "quit"
    waveSearch();
  } else if (( key == 'r' ) || ( key == 'R' )) { 
    replay();
  }else if (( key == 'd' ) || ( key == 'D' )) { 
    runTests();
  }
} // end of keyPressed()


//------------------------------------------------------------------------------
void runTests(){
  for(int i =1; i<=10; ++i){
    replay();
    ++p;
    waveSearch();
        output.println("Distance travelled test " + i +":");
        output.println(track.size());
    output.println("Robot trajectory test " + i +":");
    for(int b = 0; b<track.size(); ++b){
    output.println("(" + (int) track.get(b).x+","+ (int) track.get(b).y +")");
    }
  }
   for(int i =1; i<=10; ++i){
     replay();
    lineof();
        output.println("Distance travelled test " + i +":");
        output.println(track.size());
    output.println("Robot trajectory test " + i +":");
    for(int b = 0; b<track.size(); ++b){
    output.println("(" + (int) track.get(b).x+","+ (int) track.get(b).y +")");
    }
  }
  for(int i =1; i<=10; ++i){
     replay();
    bugSearch();
        output.println("Distance travelled test " + i +":");
        output.println(track.size());
    output.println("Robot trajectory test " + i +":");
    for(int b = 0; b<track.size(); ++b){
    output.println("(" + (int) track.get(b).x+","+ (int) track.get(b).y +")");
    }
  }
  output.flush();
  output.close();
}


void obstaclebug(PVector before, int[] xs, int[] ys) {

    if (before == SOUTH) {
    boolean w = false;
    while (!w) { 
      if (validCell((int)R.x + (int)SOUTH.x, (int)R.y + (int)SOUTH.y)&& world[(int)R.y + (int)SOUTH.y][(int)R.x + (int)SOUTH.x] != -2) {
        moveRobot(SOUTH);
        direction.add(SOUTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      }
      else if (validCell((int)R.x + (int)EAST.x, (int)R.y + (int)WEST.y)&& world[(int)R.y + (int)EAST.y][(int)R.x + (int)EAST.x] != -2) {
        moveRobot(EAST);
        direction.add(EAST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } else if (validCell((int)R.x + (int)WEST.x, (int)R.y + (int)WEST.y)&& world[(int)R.y + (int)WEST.y][(int)R.x + (int)WEST.x] != -2) {
        moveRobot(WEST);
        direction.add(WEST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } else if (validCell((int)R.x + (int)NORTH.x, (int)R.y + (int)NORTH.y)&& world[(int)R.y + (int)NORTH.y][(int)R.x + (int)NORTH.x] != -2) {
        moveRobot(NORTH);
        direction.add(NORTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } 
      else{
        moveRobot(opposite(direction.get(direction.size()-1)));
        direction.remove(direction.size()-1);
         w = true;
      }
    }
  }
  
  if (before == NORTH) {
    boolean w = false;
    while (!w) { 
       if (validCell((int)R.x + (int)NORTH.x, (int)R.y + (int)NORTH.y)&& world[(int)R.y + (int)NORTH.y][(int)R.x + (int)NORTH.x] != -2) {
        moveRobot(NORTH);
        direction.add(NORTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } 
     else if (validCell((int)R.x + (int)WEST.x, (int)R.y + (int)WEST.y)&& world[(int)R.y + (int)WEST.y][(int)R.x + (int)WEST.x] != -2) {
        moveRobot(WEST);
        direction.add(WEST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      }else if (validCell((int)R.x + (int)SOUTH.x, (int)R.y + (int)SOUTH.y)&& world[(int)R.y + (int)SOUTH.y][(int)R.x + (int)SOUTH.x] != -2) {
        moveRobot(SOUTH);
        direction.add(SOUTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } 
      
      else if (validCell((int)R.x + (int)EAST.x, (int)R.y + (int)WEST.y)&& world[(int)R.y + (int)EAST.y][(int)R.x + (int)EAST.x] != -2) {
        moveRobot(EAST);
        direction.add(EAST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } 
      else{
        moveRobot(opposite(direction.get(direction.size()-1)));
        direction.remove(direction.size()-1);
         w = true;
      }
    }
  }
  
  
  
   if (before == WEST) {
    boolean w = false;
    while (!w) { 
     if (validCell((int)R.x + (int)WEST.x, (int)R.y + (int)WEST.y)&& world[(int)R.y + (int)WEST.y][(int)R.x + (int)WEST.x] != -2) {
        moveRobot(WEST);
        direction.add(WEST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } 
      else if (validCell((int)R.x + (int)SOUTH.x, (int)R.y + (int)SOUTH.y)&& world[(int)R.y + (int)SOUTH.y][(int)R.x + (int)SOUTH.x] != -2) {
        moveRobot(SOUTH);
        direction.add(SOUTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      }
        else if (validCell((int)R.x + (int)EAST.x, (int)R.y + (int)EAST.y)&& world[(int)R.y + (int)EAST.y][(int)R.x + (int)EAST.x] != -2) {
        moveRobot(EAST);
        direction.add(EAST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } 
      else if (validCell((int)R.x + (int)NORTH.x, (int)R.y + (int)NORTH.y)&& world[(int)R.y + (int)NORTH.y][(int)R.x + (int)NORTH.x] != -2) {
        moveRobot(NORTH);
        direction.add(NORTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      }
      else{
        moveRobot(opposite(direction.get(direction.size()-1)));
        direction.remove(direction.size()-1);
        w = true;
      }
    }
  }
  
    if (before == EAST) {
    boolean w = false;
    while (!w) { 
      if (validCell((int)R.x + (int)EAST.x, (int)R.y + (int)EAST.y)&& world[(int)R.y + (int)EAST.y][(int)R.x + (int)EAST.x] != -2) {
        moveRobot(EAST);
        direction.add(EAST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } 
     else if (validCell((int)R.x + (int)NORTH.x, (int)R.y + (int)NORTH.y)&& world[(int)R.y + (int)NORTH.y][(int)R.x + (int)NORTH.x] != -2) {
        moveRobot(NORTH);
        direction.add(NORTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      }
     else if (validCell((int)R.x + (int)WEST.x, (int)R.y + (int)WEST.y)&& world[(int)R.y + (int)WEST.y][(int)R.x + (int)WEST.x] != -2) {
        moveRobot(WEST);
        direction.add(WEST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } 
      else if (validCell((int)R.x + (int)SOUTH.x, (int)R.y + (int)SOUTH.y)&& world[(int)R.y + (int)SOUTH.y][(int)R.x + (int)SOUTH.x] != -2) {
        moveRobot(SOUTH);
        direction.add(SOUTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } 
      else{
        moveRobot(opposite(direction.get(direction.size()-1)));
        direction.remove(direction.size()-1);
        w = true;
      }
    }
  }
}
void bugSearch() {

  int visited[][] = new int[MAX_Y][MAX_X];
  ArrayList<PVector> temp = new ArrayList();
  PVector temp3 = new PVector(T.x, T.y);
  boolean reachedEnd = false;
  temp.add(temp3);
  waveWorld[(int) T.y][(int) T.x] = -5;
  while (temp.size() >0) {

    int x = (int) temp.get(0).x;
    int y = (int) temp.get(0).y;
    visited[(int) temp.get(0).y][(int) temp.get(0).x] = 1;
    // waveWorld[(int) temp.get(0).y][(int) temp.get(0).x] = prev;
    temp.remove(0);
    if (R.x == x && R.y == y) {
      reachedEnd = true;
      break;
    }
    explore(x, y, visited, temp);
  }

  if (reachedEnd) {
  } else {
    println("no way to reach goal");
  }
if(reachedEnd){
boolean t = true;
while(t){
  doline();
 
  int nex = int( R.x + EAST.x );
  int ney = int( R.y + NORTH.y );
  int nwx = int( R.x + WEST.x );
  int nwy = int( R.y + NORTH.y );
  int sex = int( R.x + EAST.x );
  int sey = int( R.y + SOUTH.y );
  int swx = int( R.x + WEST.x );
  int swy = int( R.y + SOUTH.y );
  int nx = int( R.x + NORTH.x );
  int ny = int( R.y + NORTH.y );
  int wx = int( R.x + WEST.x );
  int wy = int( R.y + WEST.y );
  int sx = int( R.x + SOUTH.x );
  int sy = int( R.y + SOUTH.y );
  int ex = int( R.x + EAST.x );
  int ey = int( R.y + EAST.y );
  int[] xs = {nex, nwx, sex, swx, nx, wx, ex, sx};



  int[] ys = {ney, nwy, sey, swy, ny, wy, ey, sy};
  PVector before = NORTH;
  int did =0;
  boolean w = false;
  for (int i = 0; i<8 && !w; ++i) {
    if (xs[i] >=0 &&xs[i] < MAX_X && ys[i] >=0 && ys[i] < MAX_Y && lineof[ys[i]][xs[i]]== 1) {
      println(i);    

      if (xs[i] ==nex && ys[i] == ney) {
         if(world[ys[i]][xs[i]] != 0){
         before = EAST;
         obstaclebug(before, xs, ys);
       w=true;}
        else if (validCell((int)R.x+1, (int)R.y)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(EAST);
          moveRobot(NORTH);
          direction.add(EAST);
          direction.add(NORTH);
          before = NORTH;
          ++ did;
          w=true;
        } else if (validCell((int)R.x, (int)R.y-1)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(NORTH);
          moveRobot(EAST);
          direction.add(NORTH);
          direction.add(EAST);
          before = EAST;
          ++ did;
          w=true;
        }else{before = EAST;
         obstaclebug(before, xs, ys);}
      } else if (xs[i] ==nwx && ys[i] == nwy) {
        if(world[ys[i]][xs[i]]!= 0){
         before = WEST;
       obstaclebug(before, xs, ys);
     w=true;}
        else if (validCell((int)R.x-1, (int)R.y)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(WEST);
          moveRobot(NORTH);
          direction.add(WEST);
          direction.add(NORTH);
          before = NORTH;
          ++ did;
          w=true;
        } else if (validCell((int)R.x, (int)R.y-1)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(NORTH);
          moveRobot(WEST);
          direction.add(NORTH);
          direction.add(WEST);
          before = WEST;
          ++ did;
          w=true;
        }else{before = WEST;
         obstaclebug(before, xs, ys);}
      } else if ( xs[i]==sex && ys[i] == sey) {
         if(world[ys[i]][xs[i]] != 0){
         before = EAST;
         obstaclebug(before, xs, ys);
       w=true;}
        else if (validCell((int)R.x+1, (int)R.y)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(EAST);
          moveRobot(SOUTH);
          direction.add(EAST);
          direction.add(SOUTH);
          before= SOUTH;
          ++ did;
          w=true;
        } else if (validCell((int)R.x, (int)R.y+1)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(SOUTH);
          moveRobot(EAST);
          direction.add(SOUTH);
          direction.add(EAST);
          before = EAST;
          ++ did;
          w=true;
        }else{before = EAST;
         obstaclebug(before, xs, ys);}
      } else if (xs[i] ==swx && ys[i] == swy) {
        if(world[ys[i]][xs[i]] != 0){
         before = WEST;
         obstaclebug(before, xs, ys);
       w=true;}
        else if (validCell((int)R.x-1, (int)R.y)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(WEST);
          moveRobot(SOUTH);
          direction.add(WEST);
          direction.add(SOUTH);
          before= SOUTH;
          ++ did;
          w=true;
        } else if (validCell((int)R.x, (int)R.y+1)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(SOUTH);
          moveRobot(WEST);
          direction.add(SOUTH);
          direction.add(WEST);
          before = WEST;
          ++ did;
          w=true;
        }else{before = WEST;
         obstaclebug(before, xs, ys);}
      } else if (xs[i] ==nx && ys[i] == ny) {                                                                        
        if(world[ys[i]][xs[i]] != 0){
         before = NORTH;
         obstaclebug(before, xs, ys);
       w=true;}
        else if (validCell((int)R.x, (int)R.y-1)) {
          moveRobot(NORTH);
          direction.add(NORTH);
          before = NORTH;
          ++ did;
          w=true;
        } 
      } else if (xs[i] ==ex && ys[i] == ey) {
       if(world[ys[i]][xs[i]] != 0){
         before = EAST;
         obstaclebug(before, xs, ys);
       w=true;}
        else  if (validCell((int)R.x+1, (int)R.y)) {
          moveRobot(EAST);
          direction.add(EAST);
          before = EAST;
          ++ did;
          w=true;
        }
      } else if (xs[i] ==wx && ys[i] == wy) {
       if(world[ys[i]][xs[i]]!= 0){
         before = WEST;
         obstaclebug(before, xs, ys);
       w=true;}
        else  if (validCell((int)R.x-1, (int)R.y)) {
          moveRobot(WEST);
          direction.add(WEST);
          before = WEST;
          ++ did;
          w=true;
        }
        
      } else if (xs[i] ==sx && ys[i] == sy) {
        if(world[ys[i]][xs[i]] != 0){
         before = SOUTH;
         obstaclebug(before, xs, ys);
       w=true;}
        else if (validCell((int)R.x, (int)R.y+1)) {
          moveRobot(SOUTH);
          direction.add(SOUTH);
          before= SOUTH;
          ++ did;
          w=true;
        }
      }
    }
    
    doline();
  }
   if (R.x == T.x && R.y == T.y) {
        println("yay");
        t = false;
      }
}
}
}

  
  


void doline() {

  for (int i = 0; i < MAX_Y; ++i) {
    // codes inside the body of outer loop
    for (int j = 0; j <MAX_X; ++j) {

      lineof[i][j] =0;
    }
    // codes inside the body of outer loop
  }

  for (float y = 0; y < MAX_Y; ++y) {   
    for (float x = 0; x <MAX_X; ++x) {

      if (R.y <= T.y) {
        if (y<=T.y && y>=R.y) {
          if (R.x <= T.x) {
            if (x<=T.x && x>=R.x) {
              if ((T.y - R.y)/(T.x - R.x) > -2  &&(T.y - R.y)/(T.x - R.x) < 2) {
                if (Math.round(y-R.y) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)+0.5) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)-0.5) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))) {
                  lineof[Math.round(y)][Math.round(x)] = 1;
                }
              } else if ((T.y - R.y)/(T.x - R.x) >= 2  &&(T.y - R.y)/(T.x - R.x) <= 15) { 
                if (Math.round(y-R.y) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)+0.7) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)-0.7) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))) {
                  lineof[Math.round(y)][Math.round(x)] = 1;
                }
              } else {
                if (Math.round(y-R.y) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)+0.8) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)-0.8) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))) {
                  lineof[Math.round(y)][Math.round(x)] = 1;
                }
              }
            }
          } else if (R.x>=T.x) { 
            if (x>=T.x && x<=R.x) {
              if ((T.y - R.y)/(T.x - R.x) > -2  &&(T.y - R.y)/(T.x - R.x) < 2) {
                if (Math.round(y-R.y) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)+0.5) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)-0.5) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))) {
                  lineof[Math.round(y)][Math.round(x)] = 1;
                }
              } else if ((T.y - R.y)/(T.x - R.x) >= 2  &&(T.y - R.y)/(T.x - R.x) <= 15) { 
                if (Math.round(y-R.y) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)+0.7) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)-0.7) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))) {
                  lineof[Math.round(y)][Math.round(x)] = 1;
                }
              } else {
                if (Math.round(y-R.y) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)+0.8) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)-0.8) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))) {
                  lineof[Math.round(y)][Math.round(x)] = 1;
                }
              }
            }
          }
        }
      } else if (R.y>=T.y) { 
        if (y>=T.y && y<=R.y) {    
          if (R.x <= T.x) {
            if (x<=T.x && x>=R.x) {
              if ((T.y - R.y)/(T.x - R.x) > -2  &&(T.y - R.y)/(T.x - R.x) < 2) {
                if (Math.round(y-R.y) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)+0.5) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)-0.5) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))) {
                  lineof[Math.round(y)][Math.round(x)] = 1;
                }
              } else if ((T.y - R.y)/(T.x - R.x) >= 2  &&(T.y - R.y)/(T.x - R.x) <= 15) { 
                if (Math.round(y-R.y) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)+0.7) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)-0.7) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))) {
                  lineof[Math.round(y)][Math.round(x)] = 1;
                }
              } else {
                if (Math.round(y-R.y) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)+0.8) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)-0.8) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))) {
                  lineof[Math.round(y)][Math.round(x)] = 1;
                }
              }
            }
          } else if (R.x>=T.x) { 
            if (x>=T.x && x<=R.x) {
              if ((T.y - R.y)/(T.x - R.x) > -2  &&(T.y - R.y)/(T.x - R.x) < 2) {
                if (Math.round(y-R.y) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)+0.5) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)-0.5) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))) {
                  lineof[Math.round(y)][Math.round(x)] = 1;
                }
              } else if ((T.y - R.y)/(T.x - R.x) >= 2  &&(T.y - R.y)/(T.x - R.x) <= 15) { 
                if (Math.round(y-R.y) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)+0.7) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)-0.7) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))) {
                  lineof[Math.round(y)][Math.round(x)] = 1;
                }
              } else {
                if (Math.round(y-R.y) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)+0.8) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))||Math.round((y-R.y)-0.8) == Math.round(((T.y - R.y)/(T.x - R.x))*(x-R.x))) {
                  lineof[Math.round(y)][Math.round(x)] = 1;
                }
              }
            }
          }
        }
      }
    }
  }

  if (R.x == T.x) {
    int x = (int) R.x;
    for (float y = 0; y < MAX_Y; ++y) {   

      if (R.y <= T.y) {
        if (y<=T.y && y>=R.y) {


          lineof[Math.round(y)][Math.round(x)] = 1;
        }
      } else if (R.y>=T.y) { 
        if (y>=T.y && y<=R.y) {
          lineof[Math.round(y)][Math.round(x)] = 1;
        }
      }
    }
  }
}

void obstacle(PVector before, int[] xs, int[] ys) {
  if (before == SOUTH) {
    boolean w = false;
    while (!w) { 
      if (validCell((int)R.x + (int)SOUTH.x, (int)R.y + (int)SOUTH.y)&& world[(int)R.y + (int)SOUTH.y][(int)R.x + (int)SOUTH.x] != -2) {
        moveRobot(SOUTH);
        direction.add(SOUTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      }
      else if (validCell((int)R.x + (int)EAST.x, (int)R.y + (int)WEST.y)&& world[(int)R.y + (int)EAST.y][(int)R.x + (int)EAST.x] != -2) {
        moveRobot(EAST);
        direction.add(EAST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      }  else if (validCell((int)R.x + (int)NORTH.x, (int)R.y + (int)NORTH.y)&& world[(int)R.y + (int)NORTH.y][(int)R.x + (int)NORTH.x] != -2) {
        moveRobot(NORTH);
        direction.add(NORTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } else if (validCell((int)R.x + (int)WEST.x, (int)R.y + (int)WEST.y)&& world[(int)R.y + (int)WEST.y][(int)R.x + (int)WEST.x] != -2) {
        moveRobot(WEST);
        direction.add(WEST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      }
      else{
        moveRobot(opposite(direction.get(direction.size()-1)));
        direction.remove(direction.size()-1);
         w = true;
      }
    }
  }
  
  if (before == NORTH) {
    boolean w = false;
    while (!w) { 
       if (validCell((int)R.x + (int)NORTH.x, (int)R.y + (int)NORTH.y)&& world[(int)R.y + (int)NORTH.y][(int)R.x + (int)NORTH.x] != -2) {
        moveRobot(NORTH);
        direction.add(NORTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } 
     else if (validCell((int)R.x + (int)WEST.x, (int)R.y + (int)WEST.y)&& world[(int)R.y + (int)WEST.y][(int)R.x + (int)WEST.x] != -2) {
        moveRobot(WEST);
        direction.add(WEST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      }
      
      else if (validCell((int)R.x + (int)EAST.x, (int)R.y + (int)WEST.y)&& world[(int)R.y + (int)EAST.y][(int)R.x + (int)EAST.x] != -2) {
        moveRobot(EAST);
        direction.add(EAST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } else if (validCell((int)R.x + (int)SOUTH.x, (int)R.y + (int)SOUTH.y)&& world[(int)R.y + (int)SOUTH.y][(int)R.x + (int)SOUTH.x] != -2) {
        moveRobot(SOUTH);
        direction.add(SOUTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } 
      else{
        moveRobot(opposite(direction.get(direction.size()-1)));
        direction.remove(direction.size()-1);
         w = true;
      }
    }
  }
  
  
  
   if (before == WEST) {
    boolean w = false;
    while (!w) { 
     if (validCell((int)R.x + (int)WEST.x, (int)R.y + (int)WEST.y)&& world[(int)R.y + (int)WEST.y][(int)R.x + (int)WEST.x] != -2) {
        moveRobot(WEST);
        direction.add(WEST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } 
      else if (validCell((int)R.x + (int)SOUTH.x, (int)R.y + (int)SOUTH.y)&& world[(int)R.y + (int)SOUTH.y][(int)R.x + (int)SOUTH.x] != -2) {
        moveRobot(SOUTH);
        direction.add(SOUTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      }
       
      else if (validCell((int)R.x + (int)NORTH.x, (int)R.y + (int)NORTH.y)&& world[(int)R.y + (int)NORTH.y][(int)R.x + (int)NORTH.x] != -2) {
        moveRobot(NORTH);
        direction.add(NORTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } else if (validCell((int)R.x + (int)EAST.x, (int)R.y + (int)EAST.y)&& world[(int)R.y + (int)EAST.y][(int)R.x + (int)EAST.x] != -2) {
        moveRobot(EAST);
        direction.add(EAST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } 
      else{
        moveRobot(opposite(direction.get(direction.size()-1)));
        direction.remove(direction.size()-1);
        w = true;
      }
    }
  }
  
    if (before == EAST) {
    boolean w = false;
    while (!w) { 
      if (validCell((int)R.x + (int)EAST.x, (int)R.y + (int)EAST.y)&& world[(int)R.y + (int)EAST.y][(int)R.x + (int)EAST.x] != -2) {
        moveRobot(EAST);
        direction.add(EAST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } 
     else if (validCell((int)R.x + (int)NORTH.x, (int)R.y + (int)NORTH.y)&& world[(int)R.y + (int)NORTH.y][(int)R.x + (int)NORTH.x] != -2) {
        moveRobot(NORTH);
        direction.add(NORTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      }
     
      else if (validCell((int)R.x + (int)SOUTH.x, (int)R.y + (int)SOUTH.y)&& world[(int)R.y + (int)SOUTH.y][(int)R.x + (int)SOUTH.x] != -2) {
        moveRobot(SOUTH);
        direction.add(SOUTH);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } else if (validCell((int)R.x + (int)WEST.x, (int)R.y + (int)WEST.y)&& world[(int)R.y + (int)WEST.y][(int)R.x + (int)WEST.x] != -2) {
        moveRobot(WEST);
        direction.add(WEST);
        doline();
        for (int i = 4; i<8; ++i) {
          if (validCell(xs[i], ys[i])&&lineof[ys[i]][xs[i]]== 1&&world[ys[i]][xs[i]] != -2) {
            w = true;
          }
        }
      } 
      else{
        moveRobot(opposite(direction.get(direction.size()-1)));
        direction.remove(direction.size()-1);
        w = true;
      }
    }
  }
  
  
  
  
  
}

PVector opposite(PVector old){
  if(old == NORTH){return SOUTH;}
  else if(old == SOUTH){return NORTH;}
    else if(old == WEST){return EAST;}
     else{return WEST;}
}

void lineof() {
  
  int visited[][] = new int[MAX_Y][MAX_X];
  ArrayList<PVector> temp = new ArrayList();
  PVector temp3 = new PVector(T.x, T.y);
  boolean reachedEnd = false;
  temp.add(temp3);
  waveWorld[(int) T.y][(int) T.x] = -5;
  while (temp.size() >0) {

    int x = (int) temp.get(0).x;
    int y = (int) temp.get(0).y;
    visited[(int) temp.get(0).y][(int) temp.get(0).x] = 1;
    // waveWorld[(int) temp.get(0).y][(int) temp.get(0).x] = prev;
    temp.remove(0);
    if (R.x == x && R.y == y) {
      reachedEnd = true;
      break;
    }
    explore(x, y, visited, temp);
  }

  if (reachedEnd) {
  } else {
    println("no way to reach goal");
  }
if(reachedEnd){
boolean t = true;
while(t){
  doline();
 
  int nex = int( R.x + EAST.x );
  int ney = int( R.y + NORTH.y );
  int nwx = int( R.x + WEST.x );
  int nwy = int( R.y + NORTH.y );
  int sex = int( R.x + EAST.x );
  int sey = int( R.y + SOUTH.y );
  int swx = int( R.x + WEST.x );
  int swy = int( R.y + SOUTH.y );
  int nx = int( R.x + NORTH.x );
  int ny = int( R.y + NORTH.y );
  int wx = int( R.x + WEST.x );
  int wy = int( R.y + WEST.y );
  int sx = int( R.x + SOUTH.x );
  int sy = int( R.y + SOUTH.y );
  int ex = int( R.x + EAST.x );
  int ey = int( R.y + EAST.y );
  int[] xs = {nex, nwx, sex, swx, nx, wx, ex, sx};



  int[] ys = {ney, nwy, sey, swy, ny, wy, ey, sy};
  PVector before = NORTH;
  int did =0;
  boolean w = false;
  for (int i = 0; i<8 && !w; ++i) {
    if (xs[i] >=0 &&xs[i] < MAX_X && ys[i] >=0 && ys[i] < MAX_Y && lineof[ys[i]][xs[i]]== 1) {
      println(i);    

      if (xs[i] ==nex && ys[i] == ney) {
         if(world[ys[i]][xs[i]] != 0){
         before = EAST;
         obstacle(before, xs, ys);
       w=true;}
        else if (validCell((int)R.x+1, (int)R.y)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(EAST);
          moveRobot(NORTH);
          direction.add(EAST);
          direction.add(NORTH);
          before = NORTH;
          ++ did;
          w=true;
        } else if (validCell((int)R.x, (int)R.y-1)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(NORTH);
          moveRobot(EAST);
          direction.add(NORTH);
          direction.add(EAST);
          before = EAST;
          ++ did;
          w=true;
        }else{before = EAST;
         obstacle(before, xs, ys);}
      } else if (xs[i] ==nwx && ys[i] == nwy) {
        if(world[ys[i]][xs[i]]!= 0){
         before = WEST;
       obstacle(before, xs, ys);
     w=true;}
        else if (validCell((int)R.x-1, (int)R.y)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(WEST);
          moveRobot(NORTH);
          direction.add(WEST);
          direction.add(NORTH);
          before = NORTH;
          ++ did;
          w=true;
        } else if (validCell((int)R.x, (int)R.y-1)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(NORTH);
          moveRobot(WEST);
          direction.add(NORTH);
          direction.add(WEST);
          before = WEST;
          ++ did;
          w=true;
        }else{before = WEST;
         obstacle(before, xs, ys);}
      } else if ( xs[i]==sex && ys[i] == sey) {
         if(world[ys[i]][xs[i]] != 0){
         before = EAST;
         obstacle(before, xs, ys);
       w=true;}
        else if (validCell((int)R.x+1, (int)R.y)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(EAST);
          moveRobot(SOUTH);
          direction.add(EAST);
          direction.add(SOUTH);
          before= SOUTH;
          ++ did;
          w=true;
        } else if (validCell((int)R.x, (int)R.y+1)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(SOUTH);
          moveRobot(EAST);
          direction.add(SOUTH);
          direction.add(EAST);
          before = EAST;
          ++ did;
          w=true;
        }else{before = EAST;
         obstacle(before, xs, ys);}
      } else if (xs[i] ==swx && ys[i] == swy) {
        if(world[ys[i]][xs[i]] != 0){
         before = WEST;
         obstacle(before, xs, ys);
       w=true;}
        else if (validCell((int)R.x-1, (int)R.y)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(WEST);
          moveRobot(SOUTH);
          direction.add(WEST);
          direction.add(SOUTH);
          before= SOUTH;
          ++ did;
          w=true;
        } else if (validCell((int)R.x, (int)R.y+1)&&world[ys[i]][xs[i]] !=-1) {
          moveRobot(SOUTH);
          moveRobot(WEST);
          direction.add(SOUTH);
          direction.add(WEST);
          before = WEST;
          ++ did;
          w=true;
        }else{before = WEST;
         obstacle(before, xs, ys);}
      } else if (xs[i] ==nx && ys[i] == ny) {                                                                        
        if(world[ys[i]][xs[i]] != 0){
         before = NORTH;
         obstacle(before, xs, ys);
       w=true;}
        else if (validCell((int)R.x, (int)R.y-1)) {
          moveRobot(NORTH);
          direction.add(NORTH);
          before = NORTH;
          ++ did;
          w=true;
        } 
      } else if (xs[i] ==ex && ys[i] == ey) {
       if(world[ys[i]][xs[i]] != 0){
         before = EAST;
         obstacle(before, xs, ys);
       w=true;}
        else  if (validCell((int)R.x+1, (int)R.y)) {
          moveRobot(EAST);
          direction.add(EAST);
          before = EAST;
          ++ did;
          w=true;
        }
      } else if (xs[i] ==wx && ys[i] == wy) {
       if(world[ys[i]][xs[i]]!= 0){
         before = WEST;
         obstacle(before, xs, ys);
       w=true;}
        else  if (validCell((int)R.x-1, (int)R.y)) {
          moveRobot(WEST);
          direction.add(WEST);
          before = WEST;
          ++ did;
          w=true;
        }
        
      } else if (xs[i] ==sx && ys[i] == sy) {
        if(world[ys[i]][xs[i]] != 0){
         before = SOUTH;
         obstacle(before, xs, ys);
       w=true;}
        else if (validCell((int)R.x, (int)R.y+1)) {
          moveRobot(SOUTH);
          direction.add(SOUTH);
          before= SOUTH;
          ++ did;
          w=true;
        }
      }
    }
    
    doline();
  }
   if (R.x == T.x && R.y == T.y) {
        println("yay");
        t = false;
      }
}
}
}



void explore(int x, int y, int [][] visited, ArrayList temp) {
  int newY = y + 1;
  int newX = x+1;
  int newYm = y - 1;
  int newXm = x-1;
  prev++;
  if (validCell(newX, y) && visited[y][newX] != 1) {

    temp.add(new PVector(newX, y));
    visited[y][newX] = 1;
    waveWorld[y][newX] = prev;
  }
  if (validCell(newXm, y) && visited[y][newXm] != 1) {

    temp.add(new PVector(newXm, y));
    visited[y][newXm] =1; 
    waveWorld[y][newXm] =prev;
  }
  if (validCell(x, newY) && visited[newY][x] != 1) {

    temp.add(new PVector(x, newY));
    visited[newY][x] = 1; 
    waveWorld[newY][x] = prev;
  }
  if (validCell(x, newYm) && visited[newYm][x] != 1) {

    temp.add(new PVector(x, newYm));
    visited[newYm][x] = 1;
    waveWorld[newYm][x] = prev;
  }
}
void waveSearch() { 



  int visited[][] = new int[MAX_Y][MAX_X];
  ArrayList<PVector> temp = new ArrayList();
  int nodesLeft = 1;
  int nodesNext = 0;

  PVector temp3 = new PVector(T.x, T.y);
  boolean reachedEnd = false;
  temp.add(temp3);
  waveWorld[(int) T.y][(int) T.x] = -5;
  while (temp.size() >0) {

    int x = (int) temp.get(0).x;
    int y = (int) temp.get(0).y;
    visited[(int) temp.get(0).y][(int) temp.get(0).x] = 1;
    // waveWorld[(int) temp.get(0).y][(int) temp.get(0).x] = prev;
    temp.remove(0);
    if (R.x == x && R.y == y) {
      reachedEnd = true;
      break;
    }
    explore(x, y, visited, temp);
  }

  if (reachedEnd) {
  } else {
    println("no way to reach goal");
  }


  if (reachedEnd) {
    boolean t = true;
    while (t) {

      int Nx = int( R.x + NORTH.x );
      int Ny = int( R.y + NORTH.y );
      int Sx = int( R.x + SOUTH.x );
      int Sy = int( R.y + SOUTH.y );
      int Ex = int( R.x + EAST.x );
      int Ey = int( R.y + EAST.y );
      int Wx = int( R.x + WEST.x );
      int Wy = int( R.y + WEST.y );
      int smallest = 99999;
      if (Ny >=0 && waveWorld[Ny][Nx]!= 0) {
        smallest = waveWorld[Ny][Nx];
      }
      if (Sy<MAX_Y && waveWorld[Sy][Sx]<smallest && waveWorld[Sy][Sx]!= 0) {
        smallest = waveWorld[Sy][Sx];
      }
      if (Ex <MAX_X&&waveWorld[Ey][Ex]<smallest&& waveWorld[Ey][Ex]!= 0) {
        smallest = waveWorld[Ey][Ex];
      }
      if (Wx >=0&&waveWorld[Wy][Wx]<smallest&&waveWorld[Wy][Wx]!= 0) {
        smallest = waveWorld[Wy][Wx];
      }
      if (Ny == T.y && Nx==T.x) {
        smallest = -5;
      }
      if (Sy == T.y && Sx==T.x) {
        smallest = -5;
      }
      if (Ey == T.y && Ex==T.x) {
        smallest = -5;
      }
      if (Wy == T.y && Wx==T.x) {
        smallest = -5;
      }

      if (Sy<MAX_Y && waveWorld[Sy][Sx]==smallest) {
        moveRobot(SOUTH);
      } else  if (Ex <MAX_X&&waveWorld[Ey][Ex]==smallest) {
        moveRobot(EAST);
      } else if (Wx >=0&&waveWorld[Wy][Wx]==smallest) {
        moveRobot(WEST);
      } else if (Ny >=0 &&waveWorld[Ny][Nx]==smallest) {
        moveRobot(NORTH);
      }
      if (R.x == T.x && R.y == T.y) {
        println("yay");
        t = false;
      }
    }
  }
}

/**
 * drawGrid()
 * This function draws the robot's world as a 2D grid.
 * Note that the grid is drawn with all cells empty.
 */
void drawGrid() {
  int pixel_x, pixel_y;
  int pixel_x_max = MAX_X * PIXELS_PER_CELL;
  int pixel_y_max = MAX_Y * PIXELS_PER_CELL;
  background( COLOUR_EMPTY );
  stroke( COLOUR_GRID );
  for ( int x=0; x<MAX_X; x++ ) {
    pixel_x = x * PIXELS_PER_CELL;
    line( pixel_x, 0, pixel_x, pixel_x_max );
  }
  for ( int y=0; y<MAX_Y; y++ ) {
    pixel_y = y * PIXELS_PER_CELL;
    line( 0, pixel_y, pixel_x_max, pixel_y );
  }
} // end of drawGrid()

//------------------------------------------------------------------------------

/**
 * fillCell()
 * This function fills the cell located at (x,y) in the grid cell coordinate system.
 */
void fillCell( int x, int y, int colour ) {
  fill( colour );
  int pixel_x = x * PIXELS_PER_CELL;
  int pixel_y = y * PIXELS_PER_CELL;
  rect( pixel_x, pixel_y, PIXELS_PER_CELL, PIXELS_PER_CELL );
} // end of fillCell()

//------------------------------------------------------------------------------

/**
 * drawSensors()
 * This function draws labels in the cells that are sensed by the robot's sensors.
 */
void drawSensors() {
  int cell_x, cell_y, pixel_x, pixel_y;
  String label;
  float labelWidth, labelHeight = FONT_SIZE/2;
  fill( COLOUR_ROBOT );
  // NORTH sensor
  label = "^";
  labelWidth = textWidth( label );
  cell_x = int( R.x + NORTH.x );
  cell_y = int( R.y + NORTH.y );
  pixel_x = int( cell_x * PIXELS_PER_CELL + ( PIXELS_PER_CELL - labelWidth ) / 2 );
  pixel_y = int( cell_y * PIXELS_PER_CELL + ( PIXELS_PER_CELL + labelHeight ) / 2 );
  text( label, pixel_x, pixel_y ); 
  // SOUTH sensor
  label = "v";
  labelWidth = textWidth( label );
  cell_x = int( R.x + SOUTH.x );
  cell_y = int( R.y + SOUTH.y );
  pixel_x = int( cell_x * PIXELS_PER_CELL + ( PIXELS_PER_CELL - labelWidth ) / 2 );
  pixel_y = int( cell_y * PIXELS_PER_CELL + ( PIXELS_PER_CELL + labelHeight ) / 2 );
  text( label, pixel_x, pixel_y ); 
  // EAST sensor
  label = ">";
  labelWidth = textWidth( label );
  cell_x = int( R.x + EAST.x );
  cell_y = int( R.y + EAST.y );
  pixel_x = int( cell_x * PIXELS_PER_CELL + ( PIXELS_PER_CELL - labelWidth ) / 2 );
  pixel_y = int( cell_y * PIXELS_PER_CELL + ( PIXELS_PER_CELL + labelHeight ) / 2 );
  text( label, pixel_x, pixel_y ); 
  // WEST sensor
  label = "<";
  labelWidth = textWidth( label );
  cell_x = int( R.x + WEST.x );
  cell_y = int( R.y + WEST.y );
  pixel_x = int( cell_x * PIXELS_PER_CELL + ( PIXELS_PER_CELL - labelWidth ) / 2 );
  pixel_y = int( cell_y * PIXELS_PER_CELL + ( PIXELS_PER_CELL + labelHeight ) / 2 );
  text( label, pixel_x, pixel_y );
} // end of drawSensors()

//------------------------------------------------------------------------------

/**
 * draw()
 * This function is called repeatedly by the Processing draw loop and is used to 
 * display the robot's world and everything in it, including the robot.
 */
void draw() {
  // Draw robot's world as a grid
  drawGrid();
  // Fill in the cells in the robot's world, according to what is in each cell.
  // Note that we don't need to bother to fill the "empty" cells. 
  for ( int y=0; y<MAX_Y; y++ ) {
    for ( int x=0; x<MAX_X; x++ ) {
      if (( x == R.x ) && ( y == R.y )) {
        fillCell( x, y, COLOUR_ROBOT );
        String label = "O";
        float labelWidth = textWidth( label );
        float labelHeight = FONT_SIZE/2;
        int pixel_x = int( R.x * PIXELS_PER_CELL + ( PIXELS_PER_CELL - labelWidth ) / 2 );
        int pixel_y = int( R.y * PIXELS_PER_CELL + ( PIXELS_PER_CELL + labelHeight ) / 2 );
        fill( #ffffff );
        text( label, pixel_x, pixel_y );
      } else if (( x == T.x ) && ( y == T.y )) {
        fillCell( x, y, COLOUR_TARGET );
      } else if ( world[y][x] == CELL_OBSTACLE && lineof[y][x] == 1) {
        fillCell( x, y, #20867D);
      } else if ( world[y][x] == CELL_OBSTACLE ) {
        fillCell( x, y, COLOUR_OBSTACLE );
      } else if ( world[y][x] == -2 ) {
        fillCell( x, y, #D32222);
      } else if ( lineof[y][x] == 1 ) {
        fillCell( x, y, #D0E8D8);
      }
    } // end for x
  } // end for y
  // Draw the robot's sensors
  drawSensors();
} // end of draw()
