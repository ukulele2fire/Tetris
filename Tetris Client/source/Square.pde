public class Square {
  
   color c;
   int centerX;
   int centerY;
   boolean isGreyed;
   boolean isTinted;
   
   public Square(int x, int y, color c)
   {
     centerX = x;
     centerY = y;
     this.c = c;
     isGreyed = false;
     isTinted = false;
   }
   
   public void draw()
   {   
     color colour = c;
     
     if (isTinted)
       colour = color(colour, 100);
       
     strokeWeight(0);
     stroke(colour);
     fill(colour);
     if (isGreyed)
     {
       fill(127);
       stroke(127);
     }
       
     rect((centerX+1)*BLOCK_WIDTH,(centerY+1)*BLOCK_WIDTH,BLOCK_WIDTH,BLOCK_WIDTH);
   }
   
   public void drawCircleOn()
   {
     fill(255,255,255);
     circle((centerX+1)*BLOCK_WIDTH+0.5*BLOCK_WIDTH, (centerY)*BLOCK_WIDTH+0.5*BLOCK_WIDTH, BLOCK_WIDTH);
   }
   
   public void setGreyed(boolean b)
   {
     isGreyed = b;
   }
   
   public void setTinted(boolean b)
   {
     isTinted = b;
   }
   
   public Square clone()
   {
     return new Square(centerX,centerY,c);
   }
   
   
}
