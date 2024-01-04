public class T_Piece extends Piece{
  
  public T_Piece()
  {
    super(color(147,112,219), 5);
    
    //top square
    squares.add(new Square(centerX, centerY-1, colour));
    //left square
    squares.add(new Square(centerX-1, centerY, colour));
    //right square
    squares.add(new Square(centerX+1, centerY, colour));
  }
  
  public boolean overhang()
  {
    for (Square s : squares)
    {
      Square above = grid[s.centerX][s.centerY-1];
      if (above != null && !squares.contains(above))
        return true;
    }
    return false;
  }
}
