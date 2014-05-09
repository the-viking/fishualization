
float xo;
float yo;
float zoom = 1;
PShape fish;

void setup () 
{
  size (600, 600);
  xo = width/2;
  yo = height/2;
  smooth();
  noStroke();
}
 
void draw() 
{
  background(255, 255, 255);
  translate (xo, yo);
  scale (zoom);
  fish = loadShape("Fish.svg");
  shape(fish, -140, -140);
}
 
void keyPressed() 
{
  if (key == CODED) 
  {
    if (keyCode == UP) 
    {
      zoom += .03;
    }
    else if (keyCode == DOWN) 
    {
      zoom -= .03;
    }
  }
}

