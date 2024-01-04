public class Garbage
{
  int age;
  int y;
  int lines;
  
  public Garbage(int y, int lines)
  {
    age = 0;
    this.y = y;
    this.lines = lines;
  }
  
  public void draw()
  {
    color c;
    
    switch (age)
    {
      case 0:
        c = color(127);
        break;
      case 1:
        c = color(255,255,0);
        break;
      case 2:
        c = color(255,127,0);
        break;
      case 3:
        c = color(255,0,0);
        break;
      default:
        c = color(255,0,0);
        break;
    }
    
    for (int i = 0; i < lines; i++)
    {
      Square s = new Square(-1, y-i, c);
      s.draw();
    }
  }
}
