public class Piece {
  int centerX;
  int centerY;
  color colour;
  int pieceId;
  public boolean landed;
  public boolean standardized;
  
  public ArrayList<Square> squares;
  int rotationAmount = 0;
  
  Point[][] srs = {
                    {new Point(0,0), new Point(-1,0), new Point(-1,-1), new Point(0,2), new Point(-1,2)},  //0 -> R
                    {new Point(0,0), new Point(1,0), new Point(1,1), new Point(0,-2), new Point(1,-2)},      //R -> 2
                    {new Point(0,0), new Point(1,0), new Point(1,-1), new Point(0,2), new Point(1,2)},     //2 -> L
                    {new Point(0,0), new Point(-1,0), new Point(-1,1), new Point(0,-2), new Point(-1,-2)}   //L -> 0
                  };
                  
  int rotationState;   //0 - base, 1 - R, 2 - double, 3 - L
  
  //lock delay stuff
  int lockResets = 0;
  int lockDelay = 0;
  boolean lockDelayOn;
  
  public Piece(color c, int id)
  {
    centerX = 4;
    centerY = 1;
    colour = c;
    pieceId = id;
    squares = new ArrayList<Square>();
    squares.add(new Square(centerX, centerY, colour));  //center square
    //each indvidiual piece subclass will have the code for adding the other squares
    landed = false;   //set true once it reaches the ground
    rotationState = 0;
    standardized = false;
  }
  
  public Piece(color c, int id, Point[][] srs)
  {
    centerX = 4;
    centerY = 1;
    colour = c;
    pieceId = id;
    squares = new ArrayList<Square>();
    squares.add(new Square(centerX, centerY, colour));  //center square
    //each indvidiual piece subclass will have the code for adding the other squares
    landed = false;   //set true once it reaches the ground
    rotationState = 0;
    standardized = false;
    this.srs = srs;
  }
  
  public Piece(int x, int y, color c, int id, Point[][] srs)
  {
    centerX = x;
    centerY = y;
    colour = c;
    pieceId = id;
    squares = new ArrayList<Square>();
    squares.add(new Square(centerX, centerY, colour));  //center square
    //each indvidiual piece subclass will have the code for adding the other squares
    landed = false;   //set true once it reaches the ground
    rotationState = 0;
    standardized = false;
    this.srs = srs;
  }
  
  public void draw()
  {
    for (Square s : squares)
      s.draw();
    //squares.get(0).drawCircleOn();
  }
  
  //draw with specified center
  public void draw(int x, int y)  //x and y as in actual pixel coordinates
  {
    int translate_x = x%BLOCK_WIDTH;
    int translate_y = y%BLOCK_WIDTH;
    
    x /= BLOCK_WIDTH;
    y /= BLOCK_WIDTH;
    
    translatePiece(x,y);
    translate(translate_x, translate_y);
    draw();
    translate(-1*translate_x, -1*translate_y);
    translatePiece(-x,-y);
  }
  
  //translatePiece whole piece to new center of (0,0) and unrotated;
  public void standardize()
  {
    lockDelayOff();
    
    int translatePiece_x = -1*centerX;
    int translatePiece_y = -1*centerY;
    
    translatePiece(translatePiece_x, translatePiece_y);
    
    //add in code to rotate back to normal
    while (rotationState != 0)
    {
      for (Square s : squares)
      {
        //mathematical rotation
        int xShifted = s.centerX - centerX;
        int yShifted = s.centerY - centerY;
      
        int newX = -1*yShifted + centerX;
        int newY = xShifted + centerY;
        
        s.centerX = newX;
        s.centerY = newY;
      }
      
      rotationState = (rotationState+1)%4;
    }
    
    standardized = true;
  }
  
  public void translatePiece(int x, int y)
  {
    centerX += x;
    centerY += y;
    
    for (Square s : squares)
    {
      s.centerX += x;
      s.centerY += y;
    }
  }
  
  //for drawing purposes
  public void rotate()
  {
    for (Square s : squares)
    {
      //mathematical rotation
      int xShifted = s.centerX - centerX;
      int yShifted = s.centerY - centerY;
      
      int newX = -1*yShifted + centerX;
      int newY = xShifted + centerY;
      
      s.centerX = newX;
      s.centerY = newY;
    }
  }
  
  public void rotate180()
  {
    if (rotationAmount > 30)
      return;
      
    rotationAmount++;
    rotationState++;
    rotationState = rotationState%4;
    
    for (Square s : squares)
    {
      //mathematical rotation
      int xShifted = s.centerX - centerX;
      int yShifted = s.centerY - centerY;
      
      int newX = -1*yShifted + centerX;
      int newY = xShifted + centerY;
      
      s.centerX = newX;
      s.centerY = newY;
    }
    
    rotateRight();
  }
  
  public void rotateRight()
  {
    if (rotationAmount > 30)
      return;
      
    rotationAmount++;
    
    if (landed)
      return;
      
     resetLockDelay();
      
     Point[] tests = srs[rotationState];
     int temp = rotationState;
     rotationState = (rotationState+1)%4;
     
     //store old points in case of failure
     Point[] oldPoints = new Point[4];
     
     System.out.println(temp);
      
    
    int i = 0;
    for (Square s : squares)
    {
      oldPoints[i] = new Point(s.centerX, s.centerY);
      i++;
      
      //mathematical rotation
      int xShifted = s.centerX - centerX;
      int yShifted = s.centerY - centerY;
      
      int newX = -1*yShifted + centerX;
      int newY = xShifted + centerY;
      
      s.centerX = newX;
      s.centerY = newY;
    }
    centerX = squares.get(0).centerX;
    centerY = squares.get(0).centerY;
    
    //check if rotation is valid
    for (Point p : tests)
    {
      translatePiece(p.x,p.y);
      
      //valid --> move
      if (!outOfBounds())
        return;
      
      translatePiece(-1*p.x, -1*p.y);
    }
    
    //failed -- revert back to old points
    int j = 0;
    rotationState = temp;
    for (Square s : squares)
    {
      s.centerX = oldPoints[j].x;
      s.centerY = oldPoints[j].y;
      j++;
    }
    centerX = squares.get(0).centerX;
    centerY = squares.get(0).centerY;
    
    System.out.println("failed!" + " " + temp);
  }
  
  public void rotateLeft()
  {
    if (rotationAmount > 30)
      return;
      
    rotationAmount++;
    
    if (landed)
      return;
      
     resetLockDelay();
      
     int temp = rotationState;
     rotationState = (rotationState-1)%4;
     if (rotationState == -1)
       rotationState = 3;
     Point[] tests = srs[rotationState];
     
     //store old points in case of failure
     Point[] oldPoints = new Point[4];
      
    
    int i = 0;
    for (Square s : squares)
    {
      oldPoints[i] = new Point(s.centerX, s.centerY);
      i++;
      
      //mathematical rotation
      int xShifted = s.centerX - centerX;
      int yShifted = s.centerY - centerY;
      
      int newX = yShifted + centerX;
      int newY = -1*xShifted + centerY;
      
      s.centerX = newX;
      s.centerY = newY;
    }
    centerX = squares.get(0).centerX;
    centerY = squares.get(0).centerY;
    
    //check if rotation is valid
    for (Point p : tests)
    {
      translatePiece(-1*p.x, -1*p.y);
      
      //valid --> move
      if (!outOfBounds())
        return;

      translatePiece(p.x, p.y);
    }
    
    //failed -- revert back to old points
    int j = 0;
    rotationState = temp;
    for (Square s : squares)
    {
      s.centerX = oldPoints[j].x;
      s.centerY = oldPoints[j].y;
      j++;
    }
    System.out.println("failed!" + " " + rotationState);
    centerX = squares.get(0).centerX;
    centerY = squares.get(0).centerY;
  }
  
  public void moveLeft()
  {
    translatePiece(-1,0);
    
    if (outOfBounds())
      translatePiece(1,0);
    else
      resetLockDelay();
  }
  
  public void moveRight()
  {   
    translatePiece(1,0);
    
    if (outOfBounds())
      translatePiece(-1,0);
    else
      resetLockDelay();
  }
  
  public boolean moveDown()
  {
    if (landed)
      return false;
      
    translatePiece(0,1);
    //add lock buffer protocol later
    if (outOfBounds() == true)
    {
      translatePiece(0,-1);
      if (lockDelayOn != true)
        lockDelayOn();
        
       return false;
    }
    else if (lockDelayOn == true)
    {
      lockDelayOff();
    }
    return true;
  }
  
  public void hardDrop()
  {
    while (!lockDelayOn)
      moveDown();
    lockDelayOff();
    landed = true;
  }
  
  private boolean isValid(int x, int y)
  {
    if (x < 0 || x >= grid.length)
      return false;
    if (y >= grid[0].length)
      return false;
    if (y >= 0 && grid[x][y] != null)
      return false;
       
     return true;
  }
  
  protected boolean outOfBounds()
  {
    for (Square s : squares)
    {
      if (!isValid(s.centerX, s.centerY))
        return true;
    }
    return false;
  }
  
  public void setGreyed(boolean b)
  {
    for (Square s : squares)
      s.setGreyed(b);
  }
  
  public void setTinted(boolean b)
  {
    for (Square s : squares)
      s.setTinted(b);
  }
  
  public void drawProjection()
  {
    //make clone of piece with translucent color
    Piece projection = new Piece(centerX, centerY, colour, pieceId, srs);
    projection.squares = new ArrayList<Square>();
    for (Square s : squares)
       projection.squares.add(s.clone());
    projection.setTinted(true);
    projection.hardDrop();
    projection.draw();
  }
  
  public void lockDelayOn()
  {
    lockDelayOn = true;
    lockResets = 15;
    lockDelay = 30;
  }
  
  public void lockDelayOff()
  {
    lockDelayOn = false;
    lockResets = 0;
    lockDelay = 0;
  }
  
  protected void resetLockDelay()
  {
    if (lockResets > 0)
    {
      lockResets--;
      lockDelay = 30;
    }
     
  }
  
  public void decrementLockDelay()
  {
    lockDelay--;
  }
}
