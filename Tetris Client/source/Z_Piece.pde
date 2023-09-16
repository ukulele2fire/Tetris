public class Z_Piece extends Piece{
  
  public Z_Piece()
  {
    super(color(255, 0, 0), 6);
    
    //top square
    squares.add(new Square(centerX+1, centerY, colour));
    //2nd bottom square
    squares.add(new Square(centerX, centerY-1, colour));
    //bottom square
    squares.add(new Square(centerX-1, centerY-1, colour));
  }
}
