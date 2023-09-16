public class Moves {
  
  public ArrayList<Integer> moveRight;
  public ArrayList<Integer> moveLeft;
  public ArrayList<Integer> rotateRight;
  public ArrayList<Integer> rotateLeft;
  public ArrayList<Integer> rotate180;
  public ArrayList<Integer> softDrop;
  public ArrayList<Integer> hardDrop;
  public ArrayList<Integer> hold;
  
  public Moves()
  {
    hardDrop = new ArrayList<Integer>();
    hold = new ArrayList<Integer>();
    moveLeft = new ArrayList<Integer>();
    moveRight = new ArrayList<Integer>();
    rotate180 = new ArrayList<Integer>();
    rotateLeft = new ArrayList<Integer>();
    rotateRight = new ArrayList<Integer>();
    softDrop = new ArrayList<Integer>();
  }
  
  public void addMove(int i, String s)
  {
    int code = convertToKeycode(s);
    switch (i)
    {
      case 0:
        moveRight.add(code);
        break;
      case 1:
        moveLeft.add(code);
        break;
      case 2:
        rotateRight.add(code);
        break;
      case 3:
        rotateLeft.add(code);
        break;
      case 4:
        rotate180.add(code);
        break;
      case 5:
        softDrop.add(code);
        break;
      case 6:
        hardDrop.add(code);
        break;
      case 7:
        hold.add(code);
        break;  
    }
  }
  
  public int convertToKeycode(String s)
  {
    s = s.toLowerCase();
    
    if (s.equals("shift"))
      return SHIFT;
    if (s.equals("down"))
      return DOWN;
    if (s.equals("right"))
      return RIGHT;
    if (s.equals("left"))
      return LEFT;
    if (s.equals("space"))
      return 32;
    if (s.equals("up"))
      return UP;
      
    else if (s.length() == 1)
      return s.charAt(0)-32;
      
    //something wrong
    return -1;
  }
  
  public int processMove(Piece p, int keyCode)
  {
    if (moveRight.contains(keyCode))
      p.moveRight();
    else if (moveLeft.contains(keyCode))
      p.moveLeft();
    else if (rotateRight.contains(keyCode))
      p.rotateRight();
    else if (rotateLeft.contains(keyCode))
      p.rotateLeft();
    else if (rotate180.contains(keyCode))
      p.rotate180();
    else if (softDrop.contains(keyCode))
      p.moveDown();
    else if (hardDrop.contains(keyCode))
      p.hardDrop();
    else if (hold.contains(keyCode))
      return -1; //hold message
      
    return 0;
  }
  
}
