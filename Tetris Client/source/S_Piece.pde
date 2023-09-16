public class S_Piece extends Piece{
  
  public S_Piece()
  {
    super(color(72, 203, 59), 4);
    
    //top square
    squares.add(new Square(centerX+1, centerY-1, colour));
    //2nd bottom square
    squares.add(new Square(centerX, centerY-1, colour));
    //bottom square
    squares.add(new Square(centerX-1, centerY, colour));
  }
}
