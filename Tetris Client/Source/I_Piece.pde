public class I_Piece extends Piece{
  
  public I_Piece()
  {
    super(color(0,210,255), 0, new Point[][]{{new Point(0,0), new Point(-2,0), new Point(1,0), new Point(-2,-1), new Point(1,2)},  //0 -> R
                                         {new Point(0,0), new Point(-1,0), new Point(2,0), new Point(-1,2), new Point(2,-1)},      //R -> 2
                                         {new Point(0,0), new Point(2,0), new Point(-1,0), new Point(2,1), new Point(-1,-2)},     //2 -> L
                                         {new Point(0,0), new Point(1,0), new Point(-2,0), new Point(1,-2), new Point(-2,1)}});    //L --> 0
    
    //top square
    squares.add(new Square(centerX-1, centerY, colour));
    //2nd bottom square
    squares.add(new Square(centerX+1, centerY, colour));
    //bottom square
    squares.add(new Square(centerX+2, centerY, colour));

  }
  
  public void rotateRight()
  {
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
    
    //i piece weirdness
    switch (rotationState)
    {
      case 1:
        translatePiece(1,0);
        break;
      case 2:
        translatePiece(0,1);
        break;
      case 3:
        translatePiece(-1,0);
        break;
      case 0:
        translatePiece(0,-1);
        break;
    }
    
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
    
    //i piece weirdness
    switch (rotationState)
    {
      case 1:
        translatePiece(1,0);
        break;
      case 2:
        translatePiece(0,1);
        break;
      case 3:
        translatePiece(-1,0);
        break;
      case 0:
        translatePiece(0,-1);
        break;
    }
    
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
}
