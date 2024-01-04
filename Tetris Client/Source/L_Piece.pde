public class J_Piece extends Piece{
  
  public J_Piece()
  {
    super(color(0, 50, 255), 2);
    
    //top square
    squares.add(new Square(centerX-1, centerY, colour));
    //2nd bottom square
    squares.add(new Square(centerX+1, centerY, colour));
    //bottom square
    squares.add(new Square(centerX-1, centerY-1, colour));
  }
}
