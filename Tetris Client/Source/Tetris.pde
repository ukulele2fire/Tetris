import processing.sound.*;
import processing.net.*;

boolean inputtingIp;
boolean inputtingId;
Client myClient;
String ip;
String userId;

String target;
String id;
String attacker;

Moves moves;

int BLOCK_WIDTH;
final int BUFFER_MAX = 60;
int buffer_offset;

int drop_buffer;
int softDrop_buffer;
int garbage_buffer;
int speed_buffer;

boolean gravity;
boolean blockedOut;
boolean paused;

Square[][] bufferZone;
Square[][] grid;

Piece currentPiece;
Piece heldPiece;
boolean canHold;
boolean canRotate;

Piece[] bag;
Piece[] nextBag;

int bagNum;

//music stuff
SoundFile music;
SoundFile dropEffect;
SoundFile tetrisEffect;
SoundFile gameOverEffect;

boolean loud;

int pieceNum = 0;

int linesCleared;
int tetrises;
int tss;
int tsd;
int tst;
int perfectClear;
int highestCombo;

int combo;
boolean backToBack;

int garbageLines;
ArrayList<Garbage> garbage;

boolean started;
boolean won;

int loading = 0;

//initialize them in setup().
void setup()
{
  size(600,600); //some buffer height
  imageMode(CENTER);
  frameRate(60);
  surface.setResizable(false);
  
  BLOCK_WIDTH = (int)(width/850.0*40);
  
  myClient = null;
  inputtingId = true;
  inputtingIp = false;
  userId = "";
  ip = "";
  id = null;
  
  started = false;
  
  music = new SoundFile(this, "Tetris.mp3");
  dropEffect = new SoundFile(this, "hit.mp3");
  tetrisEffect = new SoundFile(this, "tetris_clear.mp3");
  gameOverEffect = new SoundFile(this, "game_over.wav");
  
  moves = new Moves();
  loadData();
}

void setupGame() 
{
  drop_buffer = 0;
  garbage_buffer = 0;
  buffer_offset = 0;
  speed_buffer = 0;
  
  grid = new Square[10][20];
  bufferZone = new Square[10][20];
  
  bagNum = 0;
  bag = new Piece[7];
  nextBag = new Piece[7];
  generateNewBag();
  generateNewBag();
  currentPiece = bag[0];
  inbound(currentPiece);
  bagNum++;
  
  canHold = true;
  heldPiece = null;
  blockedOut = false;
  paused = false;
  gravity = true;
  
  combo = -1;
  backToBack = false;
  
  garbageLines = 0;
  garbage = new ArrayList<Garbage>();
  
  if (music != null)
    music.stop();
  
  music.loop();
  music.amp(0);
  loud = false;
  
  won = false;
  
  linesCleared = 0;
  tetrises = 0;
  tss = 0;
  tsd = 0;
  tst = 0;
  perfectClear = 0;
  highestCombo = 0;
}

// modify and update them in draw().
void draw(){
  
  if (inputtingId)
  {
    background(0);
    fill(255);
    textSize(BLOCK_WIDTH);
    text("USER ID:   ", width/4, width/2);
    fill(255,0,0);
    text("                          " + userId, width/4, width/2);
    return;
  }
  
  if (inputtingIp)
  {
    background(0);
    fill(255);
    textSize(BLOCK_WIDTH);
    text("SERVER IP:   ", width/4, width/2);
    fill(255,0,0);
    text("                          " + ip, width/4, width/2);
    return;
  }
  
  //check for start signal
  readServer();
  
  windowResize(width, width);
  BLOCK_WIDTH = (int)(width/860.0*40);
  
  readServer();
    
  background(0);
  
  if (started != true)
  {
    fill(255);
    textSize(BLOCK_WIDTH);
    text("Loading game", width/3, width/3);
    
    T_Piece t = new T_Piece();
    for (int i = 0; i < (loading/30)%4; i++)
      t.rotate();
    t.draw(130,215);
    loading++;
    
    return;
  }
  
  drawHeldPiece();
  drawPiecePreview();
  
  //combo stuff
  fill(255);
  textSize(BLOCK_WIDTH);
  text("COMBO: " + combo, BLOCK_WIDTH*0.9, BLOCK_WIDTH*20);
  
  if (id == null)
    ip = "start";
  
  if (!ip.equals("start"))
  {
    //target stuff
    fill(255);
    textSize(BLOCK_WIDTH*0.7);
    if (target != null)
      text("FIGHTING: " + target, BLOCK_WIDTH*0.7, BLOCK_WIDTH*17);
    else
      text("FIGHTING: none", BLOCK_WIDTH*0.7, BLOCK_WIDTH*17);
      
    text("YOUR_ID: " + id, BLOCK_WIDTH*0.7, BLOCK_WIDTH*16);
  }
  else
  {
    fill(255);
    textSize(BLOCK_WIDTH);
    text("PLAYER", BLOCK_WIDTH*0.7, BLOCK_WIDTH*17);
    text("SINGLE", BLOCK_WIDTH*0.7, BLOCK_WIDTH*16);
  }

   //target stuff
   fill(255);
   textSize(BLOCK_WIDTH*0.7);
   text("Lines cleared: " + linesCleared, BLOCK_WIDTH*0.7, BLOCK_WIDTH*8);
   text("Tetrises: " + tetrises, BLOCK_WIDTH*0.7, BLOCK_WIDTH*9);
   text("TSS: " + tss, BLOCK_WIDTH*0.7, BLOCK_WIDTH*10);
   text("TSD: " + tsd, BLOCK_WIDTH*0.7, BLOCK_WIDTH*11);
   text("TST: " + tst, BLOCK_WIDTH*0.7, BLOCK_WIDTH*12);
   text("Perfect clears: " + perfectClear, BLOCK_WIDTH*0.7, BLOCK_WIDTH*13);
   text("Highest combo: " + highestCombo, BLOCK_WIDTH*0.7, BLOCK_WIDTH*14);
  
  translate(BLOCK_WIDTH*5.5,0);
  drawGarbageIndicator();
  translate(BLOCK_WIDTH*0.5,0);
  drawGrid();
  
  currentPiece.draw();
  
  if (blockedOut)
  {
    music.stop();
    
    if (!ip.equals("start"))
    {
      fill(0);
      rect(-10*BLOCK_WIDTH, width/2-BLOCK_WIDTH*3, BLOCK_WIDTH*40, BLOCK_WIDTH*4);
      fill(255);
      textSize(BLOCK_WIDTH*3);
      if (attacker == null)
        attacker = "YOU :(";
      text("Killed by: " + attacker, -5*BLOCK_WIDTH, width/2);
    }
    
    return;
  }
  
  if (won)
  {
    fill(0);
    rect(-2*BLOCK_WIDTH, width/2-BLOCK_WIDTH*3, BLOCK_WIDTH*16, BLOCK_WIDTH*3);
    fill(255);
    textSize(BLOCK_WIDTH*4);
    text("YOU WON", -2*BLOCK_WIDTH, width/2);
  }
  
  //input delay
  if (keyPressed)
  {
    if (softDrop_buffer < BUFFER_MAX)
      softDrop_buffer += 40;
    else
    {
      softDropHandler();
      softDrop_buffer = 0;
    }
  }
  
  
  //dropping
  currentPiece.drawProjection();
  
  if (drop_buffer >= BUFFER_MAX-buffer_offset)
  {
    if (gravity)
      currentPiece.moveDown();
    drop_buffer = 0;
    
    int extra_downs = (BUFFER_MAX-buffer_offset/60)*-1;
    for (int i = 0; i < extra_downs; i++)
      currentPiece.moveDown();
  }
  drop_buffer++;
  
  
  //garbage
  if (garbage.size() > 0)
  {
    if (garbage_buffer >= 3*BUFFER_MAX-buffer_offset)
    {
      garbage.get(garbage.size()-1).age++;
      garbage_buffer = 0;
    }    
    garbage_buffer++;
  }
  else
    garbage_buffer = 0;
  
  //speed up
  if (speed_buffer >= 5*BUFFER_MAX)
  {
    buffer_offset += 1;
    speed_buffer = 0;
  }
  
  speed_buffer++;
  
  if (currentPiece.lockDelayOn == true && !currentPiece.moveDown())
  {
    currentPiece.decrementLockDelay();
    if (currentPiece.lockDelay <= 0)
      currentPiece.landed = true;
  }
    
  if (currentPiece.landed == true)
  {
    drop_buffer = 0;
    canHold = true;
    dropEffect.play();
    addToGrid();
    boolean clearedALine = clearLines();
    
    //garbage stuff
    if (!clearedALine)
    {
      if (garbage.size() > 0)
      {
        if (garbage.get(garbage.size()-1).age >= 3)
        {
          addGarbageLines(garbage.get(garbage.size()-1).lines);
          garbageLines -= garbage.get(garbage.size()-1).lines;
          garbage.remove(garbage.size()-1);
        }
      }
    }
      
    if (bagNum == 7)
    {
       generateNewBag();
       bagNum = 0;
    }
    currentPiece = bag[bagNum];
    inbound(currentPiece);
    bagNum++;
  }
} 

void drawGrid()
{
  //border
  stroke(127);
  strokeWeight(15);
  line(BLOCK_WIDTH, BLOCK_WIDTH, BLOCK_WIDTH, (grid[0].length+1)*BLOCK_WIDTH);         //left
  line((grid.length+1)*BLOCK_WIDTH, BLOCK_WIDTH, (grid.length+1)*BLOCK_WIDTH,  (grid[0].length+1)*BLOCK_WIDTH);   //right
  line(BLOCK_WIDTH, BLOCK_WIDTH, (grid.length+1)*BLOCK_WIDTH, BLOCK_WIDTH);
  line(BLOCK_WIDTH, (grid[0].length+1)*BLOCK_WIDTH, (grid.length+1)*BLOCK_WIDTH, (grid[0].length+1)*BLOCK_WIDTH);
   
  //grid
  strokeWeight(1);
  stroke(127);
  fill(0,0,0);
  
  for (int x = 0; x < grid.length; x++)
  {
    for (int y = 0; y < grid[0].length; y++)
    {
      if (grid[x][y] == null)
        rect(x*BLOCK_WIDTH+BLOCK_WIDTH,(y+1)*BLOCK_WIDTH,BLOCK_WIDTH,BLOCK_WIDTH);
    }
  }
  
  //blocks
  strokeWeight(1);
  stroke(0);
  
  for (int x = 0; x < grid.length; x++)
  {
    for (int y = 0; y < grid[0].length; y++)
    {
      if (grid[x][y] != null)
      {
        grid[x][y].draw();
      }
    }
  }
}



public Piece randomPiece()
{
  int rand = (int)(random(7));
  Piece[] possible = {new I_Piece(), new J_Piece(), new L_Piece(), new O_Piece(), new S_Piece(), new T_Piece(), new Z_Piece()};
  return possible[rand];
}

public Piece cyclePiece()
{
  Piece[] possible = {new I_Piece(), new J_Piece(), new L_Piece(), new O_Piece(), new S_Piece(), new T_Piece(), new Z_Piece()};
  return possible[pieceNum];
}

public void addToGrid()
{
  if (blockedOut)
    return;
    
  ArrayList<Square> squares = currentPiece.squares;
  for (Square s : squares)
  {
    int x = s.centerX;
    int y = s.centerY;
    if (y < 0)
      bufferZone[x][y+20] = s;
    else
      grid[x][y] = s;
  }
}

public boolean clearLines()
{
  int count = 0;
  for (int c = grid[0].length-1; c >= 0 ; c--)
  {
    if (isFullLine(c))
    {
      moveAllDown(c);
      c++;
      count++;
    }
  }
  
  if (count == 0)
  {
    combo = -1;
    return false;
  }
  
  combo++;
  
  boolean tSpin = false;
  if (currentPiece.pieceId == 5 && ((T_Piece)currentPiece).overhang())
    tSpin = true;
  
  int rowsToSend = 0;
  
  linesCleared += count;

  switch (count)
  {
    case 4:
      tetrisEffect.play();
      System.out.println("TETRIS");
      rowsToSend = 4;
      tetrises++;
      if (backToBack == true)
        rowsToSend += 1;
      else
        backToBack = true;
      break;
    case 3:
      if (currentPiece.pieceId == 5)
      {
        rowsToSend = 6;
        System.out.println("TSPIN TRIPLE");
        tst++;
        if (backToBack == true)
          rowsToSend += 1;
        else
          backToBack = true;
      }
      else
      {
        rowsToSend = 2;
        System.out.println("TRIPLE");
        backToBack = false;
      }
      break;
    case 2:
      if (tSpin)
      {
        rowsToSend = 4;
        System.out.println("TSPIN DOUBLE");
        tsd++;
        if (backToBack == true)
          rowsToSend += 1;
        else
          backToBack = true;
      }
      else
      {
        rowsToSend = 1;
        System.out.println("DOUBLE");
        backToBack = false;
      }
      break;
    case 1:
      if (tSpin)
      {
        rowsToSend = 2;
        System.out.println("TSPIN SINGLE");
        tss++;
        if (backToBack == true)
          rowsToSend += 1;
        else
          backToBack = true;
        
      }
      else
      {
        rowsToSend = 0;
        System.out.println("SINGLE");
        backToBack = false;
      }
      break;
  }
  
  if (combo >= 10)
    rowsToSend += 5;
  else if (combo >= 7)
    rowsToSend += 4;
  else
    rowsToSend += (combo+1)/2;
    
  highestCombo = max(combo, highestCombo);
    
  if (isPerfectClear())
  {
    rowsToSend += 4;
    perfectClear++;
  }
  
  removeGarbageQueue(rowsToSend);
  garbageLines -= rowsToSend;
  if (garbageLines < 0)
  {
    writeToServer(-1*garbageLines);
    garbageLines = 0;
  }
  
  return true;
  
}

public boolean isFullLine(int c)
{
  for (int r = 0; r < grid.length; r++)
  {
    if (grid[r][c] == null)
      return false;
  }
  //myClient.write("line cleared\n");
  return true;
}

public boolean isPerfectClear()
{
  for (int r = 0; r < grid.length; r++)
  {
    if (grid[r][19] != null)
      return false;
  }
  return true;
}

public void moveAllDown(int bottom)
{
  //for all squares on grid
  for (int c = bottom; c >= 1; c--)
  {
    for (int r = 0; r < grid.length; r++)
    {
      grid[r][c] = grid[r][c-1];
      if (grid[r][c] != null)
        grid[r][c].centerY++;
    }
  }
  
  //for squares in buffer zone
  for (int r = 0; r < grid.length; r++)
  {
    grid[r][0] = bufferZone[r][19];
    if (grid[r][0] != null)
        grid[r][0].centerY++;
  }
  
  for (int c = 19; c >= 1; c--)
  {
    for (int r = 0; r < grid.length; r++)
    {
      bufferZone[r][c] = bufferZone[r][c-1];
      if (bufferZone[r][c] != null)
        bufferZone[r][c].centerY++;
    }
  }
}

public void moveAllUp()
{
  //for squares in buffer zone
  for (int c = 0; c < 19; c++)
  {
    for (int r = 0; r < grid.length; r++)
    {
      bufferZone[r][c] = bufferZone[r][c+1];
      if (bufferZone[r][c] != null)
        bufferZone[r][c].centerY--;
    }
  }
  
  for (int r = 0; r < grid.length; r++)
  {
    bufferZone[r][19] = grid[r][0];
    if (bufferZone[r][19] != null)
        bufferZone[r][19].centerY--;
  }
  
  //for all squares on grid
  for (int c = 0; c < 19; c++)
  {
    for (int r = 0; r < grid.length; r++)
    {
      grid[r][c] = grid[r][c+1];
      if (grid[r][c] != null)
        grid[r][c].centerY--;
    }
  } 
}

public void addGarbageLines(int lines)
{
  for (int i = 0; i < lines; i++)
    addGarbageLine();
}

public void addGarbageLine()
{
  moveAllUp();
  int clear = (int)(random(10));
  for (int r = 0; r < 10; r++)
  {
    if (r != clear)
    {
      Square garbage = new Square(r, 19, 0);
      garbage.setGreyed(true);
      grid[r][19] = garbage;
    }
    else
      grid[r][19] = null;
  }
}

public void addGarbageQueue(int lines)
{
  if (garbageLines + lines > 20)
    lines = 20-garbageLines;
    
  for (Garbage g : garbage)
    g.y -= lines;
    
  if (lines > 0)
    garbage.add(0, new Garbage(19, lines));
    
  garbageLines += lines;
    
}

public void removeGarbageQueue(int lines)
{
  for (int i = 0; i < lines; i++)
  {
    if (garbage.size() == 0)
      return;
    garbage.get(garbage.size()-1).lines--;
    
    if (garbage.get(garbage.size()-1).lines == 0)
      garbage.remove(garbage.size()-1);
  }
}

public void generateNewBag()
{
  Piece[] array = {new I_Piece(), new J_Piece(), new L_Piece(), new O_Piece(), new S_Piece(), new T_Piece(), new Z_Piece()};
    
   for (int i = 0; i < array.length; i++) {
     int randomIndexToSwap = (int)(random(array.length));
     Piece temp = array[randomIndexToSwap];
     array[randomIndexToSwap] = array[i];
     array[i] = temp;
   }
   
   for (Piece p : array)
   {
     if (p.standardized == false)
       p.standardize();
   }
   
   bag = nextBag;
   nextBag = array;
}

public void holdPiece()
{
  if (heldPiece == null)
  {
    heldPiece = currentPiece;
    if (bagNum == 7)
    {
      generateNewBag();
      bagNum = 0;
    }
    currentPiece = bag[bagNum];
    bagNum++;
  }
  else
  {
    Piece temp = currentPiece;
    currentPiece = heldPiece;
    heldPiece = temp;
  }
  inbound(currentPiece);
  drop_buffer = 0;
}

public void drawHeldPiece()
{
  fill(0,0,0);
  stroke(10);
  textSize(50);
  if (heldPiece != null)
  {
    heldPiece.setGreyed(!canHold);
    if (heldPiece.standardized == false)
      heldPiece.standardize();
     heldPiece.draw((int)(BLOCK_WIDTH*38.0/40),BLOCK_WIDTH*3);
  }
}

public void drawPiecePreview()
{
  for (int i = bagNum; i < bagNum+5; i++)
  {
    Piece p;
    if (i >= 7)
    {
      int j = i - 7;
      p = nextBag[j];
    }
    else
      p = bag[i];
    
    p.draw((int)(720.0/40*BLOCK_WIDTH), (int)(BLOCK_WIDTH*3+(i-bagNum)*(BLOCK_WIDTH*3)));
  }
}

public void drawGarbageIndicator()
{
  for (Garbage g : garbage)
    g.draw();
}

public void inbound(Piece p)
{
  p.setGreyed(false);
  p.standardized = false;
  p.translatePiece(4,2);
  if (p.outOfBounds())
  {
    p.translatePiece(0,-1);                //row 1
    if (p.outOfBounds())
    {
      p.translatePiece(0,-1); 
      if (p.outOfBounds()) {
        //game over
        p.translatePiece(-18,-18);
        gameOverEffect.play();
        greyOutGrid();
        currentPiece.setGreyed(true);
        blockedOut = true;
        
        if (myClient != null)
          myClient.write("DEAD" + " " + id);
      }
    }
  }
}

public void greyOutGrid()
{
  for (Square[] row : grid)
  {
    for (Square s : row)
    {
      if (s != null)
        s.setGreyed(true);
    }
  }
}

//inputs

// called whenever a key is pressed.
void keyPressed(){
  
  /////////////////////////////////////////////////////////////////////
  
  if (inputtingId == true)
  {
    if (key == '\n') 
    {
      inputtingId = false;
      inputtingIp = true;
      
      if (userId.equals("start"))
      {
        inputtingIp = false;
        setupGame();
        started = true;
        return;
      }
    } 
    else 
    {
      if (keyCode == BACKSPACE && userId.length() > 0)
          userId = userId.substring(0, userId.length()-1);
      else if (keyCode != BACKSPACE && key != ' ' && userId.length() < 7)
        userId = userId + key; 
    }
    return;
  }
  
  ////////////////////////////////////////////////////////////////
  
  if (inputtingIp == true)
  {
    if (key == '\n') 
    {
      inputtingIp = false;
      
      if (ip.equals("start"))
      {
        setupGame();
        started = true;
        return;
      }
      
      myClient = new Client(this, ip, 1234);
      joinServer();
      
      if (id == null)
      {
        System.out.println("Connection failed!");
        setupGame();
        started = true;
      }
    } 
    else 
    {
      if (keyCode == BACKSPACE && ip.length() > 0)
          ip = ip.substring(0, ip.length()-1);
      else
        ip = ip + key; 
    }
    return;
  }
  
  ////////////////////////////////////////////////////////////////////////////
  
  if (keyCode == ENTER && ip.equals("start"))
    setupGame();
  if (!started)
    return;
  if (key == 'p' && ip.equals("start"))
  {
    paused = !paused;
    gravity = !gravity;
    if (paused)
      music.pause();
    else
       music.play();
  }
  if (key == ']')
  {
    if (id != null && id != "start")
      myClient.write("DISCONNECT" + " " + id);
    setup();
  }
  
  if (blockedOut || paused || won)
    return;
    
  //controls
  System.out.println(keyCode);
  int result = moves.processMove(currentPiece, keyCode);
  
  if (result == -1 && canHold)
  {
    holdPiece();
    canHold = false;
  }
  
  //debug controls
  else if (key == 'g' && ip.equals("start"))
  {
    gravity = !gravity;
    buffer_offset = 0;
  }
  else if (key == 'r' && ip.equals("start")) {
    currentPiece = cyclePiece();
    pieceNum = (pieceNum+1)%7;
  }
  else if (key == 'm') {
    if (loud)
      music.amp(0);
    else
      music.amp(1);
      
    loud = !loud;
  }
  else if (key == 't')
    addGarbageQueue(4);
}

void softDropHandler()
{
  if(keyCode == DOWN || key == 's'){
    currentPiece.moveDown();
  }
}

//server stuff

void joinServer()
{
  String joinMessage = myClient.readString();
  if (joinMessage == null)
    return;
  
  id = userId;
  myClient.write("JOIN" + " " + id);
  
  if (id == null)
    ip = "start";
}



void readServer()
{
  if (id == null)
    return;
    
  String inString = myClient.readString();
  if (inString == null)
    return;
    
  System.out.println(inString);
  if (inString.equals("start"))
  {
    setupGame();
    started = true;
    return;
  }
  
  
  //assigning targets
  if (inString.charAt(0) == 'a')
  {
    String[] messages = split(inString, '/');
    for (String m : messages)
    {
      String[] message = split(m, ' ');
      if (message.length > 1 && message[0].equals(id))
        target = message[1];
    }
  }
  
  //read other messages
  String[] message = split(inString, ' ');
    
  if (!message[0].equals("" + id))
    return;
    
  //interpret message
  if (message[1].equals("GARBAGE"))
  {
    System.out.println("garbage received");
    int lines = Integer.parseInt(message[2]);
    attacker = message[3];
    addGarbageQueue(lines);
  }
  if (message[1].equals("WINNER"))
  {
    won = true;
    gravity = false;
  }
}

void writeToServer(int lines)
{
  if (id == null)
    return;
    
  System.out.println("garbage sent");
  myClient.write("ATTACK" + " " + target + " " + lines + " " + id + " ");
}

void exit() {
  if (id != null)
    myClient.write("DISCONNECT" + " " + id);
  delay(1000);
}

void loadData() {
  // Load JSON file
  // Temporary full path until path problem resolved.
  JSONObject json = loadJSONObject("settings.json");

  String[] options = {"moveRight", "moveLeft", "rotateRight", "rotateLeft", 
                      "rotate180", "softDrop", "hardDrop", "hold"};

  JSONObject moveData = json.getJSONObject("moves");
  
  for (int i = 0; i < 8; i++)
  {
    String s = options[i];
    JSONArray move = moveData.getJSONArray(s);
    for (int j = 0; j < move.size(); j++)
      moves.addMove(i, move.getString(j));
  }
}
