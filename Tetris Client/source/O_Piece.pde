public class O_Piece extends Piece{
  
  public O_Piece()
  {
    super(color(255,215,0), 3);
    
    //top square
    squares.add(new Square(centerX, centerY-1, colour));
    //2nd bottom square
    squares.add(new Square(centerX+1, centerY-1, colour));
    //bottom square
    squares.add(new Square(centerX+1, centerY, colour));
  }
  
  @Override
  public void rotateRight()
  {
    //nothing
  }
  
  @Override
  public void rotateLeft()
  {
    //nothing
  }
}
