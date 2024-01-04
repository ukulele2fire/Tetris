public class L_Piece extends Piece{
  
  public L_Piece()
  {
    super(color(255, 165, 0), 1);
    
    //top square
    squares.add(new Square(centerX-1, centerY, colour));
    //2nd bottom square
    squares.add(new Square(centerX+1, centerY-1, colour));
    //bottom square
    squares.add(new Square(centerX+1, centerY, colour));
  }
}
