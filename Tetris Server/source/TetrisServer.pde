import processing.net.*;

Server myServer;
int val;

ArrayList<String> players;
ArrayList<String> deadPlayers;

void setup() {
  size(200, 230);
  myServer = new Server(this, 1234); 
  players = new ArrayList<String>();
  deadPlayers = new ArrayList<String>();
  val = 0;
}

void revive() {
  for (String s : deadPlayers)
    players.add(s);
  deadPlayers = new ArrayList<String>();
}

void reset() {
  players = new ArrayList<String>();
  deadPlayers = new ArrayList<String>();
  val = 0;
}

void draw() 
{
  background(255);
  fill(0);
  textSize(30);
  text("Tetris Server", 25, 40);
  textSize(20);
  fill(127);
  text("-----------------------------------", 0, 65);
  fill(0);
  text("Alive: " + players.size(), 25, 90);
  text("Dead: " + deadPlayers.size(), 110, 90);
  fill(127);
  text("-----------------------------------", 0, 115);
  fill(0);
  text("s - start the game", 30, 140);
  text("a - assign targets", 30, 170);
  text("r - restart game", 30, 200);
  
  readClientMessage();
}

void serverEvent(Server someServer, Client someClient)
{
  System.out.println("client joined");
  myServer.write(val + "");
  val++;
  
}

void readClientMessage()
{
  Client thisClient = myServer.available();

  if (thisClient == null)
    return;
   
  String whatClientSaid = thisClient.readString();
  if (whatClientSaid == null)
    return;
    
  String[] message = split(whatClientSaid, ' ');
  
  if (message[0].equals("DEAD"))
  {
    String dead = message[1];
    players.remove(dead);
    deadPlayers.add(dead);
    
    if (players.size() == 1)
      myServer.write(players.get(0) + " " + "WINNER" + " ");
    else
      assignTargets();
  }
  
  if (message[0].equals("ATTACK"))
  {
    sendGarbage(message[1], message[2], message[3]);
  }
  
  if (message[0].equals("DISCONNECT"))
  {
    players.remove(message[1]);
    deadPlayers.remove(message[1]);
  }
  
  if (message[0].equals("JOIN"))
  {
    players.add(message[1]);
  }
  
}

void assignTargets()
{
  //shuffle
  for (int i = 0; i < players.size(); i++) {
     int randomIndexToSwap = (int)(random(players.size()));
     String temp = players.get(randomIndexToSwap);
     players.set(randomIndexToSwap, players.get(i));
     players.set(i, temp);
  }
  
  String message = "";
  
  message += "a/";
  for (int j = 0; j < players.size(); j += 2)
  {
    String p1 = players.get(j);
    String p2;
    
    if (j+1 < players.size())
      p2 = players.get(j+1);
    else
      p2 = "-1";
      
    message += (p1 + " " + p2 + " " + "/");
    message += (p2 + " " + p1 + " " + "/");
  }
  myServer.write(message);
}

void sendGarbage(String id, String lines, String attacker)
{
   myServer.write(id + " " + "GARBAGE" + " " + lines + " " + attacker + " ");
}

void keyPressed()
{
  if (key == 'a' || key == 'A')
    assignTargets();
  if (key == 's' || key == 'S')
  {
    revive();
    myServer.write("start");
  }
  if (key == 'w' || key == 'W')
    myServer.write(players.get(0) + " " + "WINNER" + " ");
  if (key == 'r' || key == 'R')
    reset();
}
