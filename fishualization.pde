/*FISHUALIZATION
  URL: https://github.com/the-viking/fishualization

  Created by: Erik Bonadonna, Benjamin Potts and Luna Zhang
  In association with: Professor Pheobe Sengers and The Cornell University Culturally Embeded Computing Lab
  
  


*/






/*CITATIONS 

  The basis for this implementation of comes from "Flocking" by Daniel Shiffman 
  an implentation of Craig Reynold's Boids program.
  URL:  https://code.google.com/p/processing/source/browse/trunk/processing/java/examples/Topics/Simulate/Flocking/Flocking.pde?r=9025
  
  Assistance on the attraction of boids to a clicked mouse came from "TfGuy44" on the processing formus
  URL:  http://forum.processing.org/two/discussion/2366/flocking-with-ai-for-2d-games/p1
  
  Fishing Datasets sourced from Statistics Iceland
  URL:http://www.statice.is
  
*/



Flock flock;  // Flock value primary method of reffering to the simulation
PImage fish;  // Image "fish" boids are rendered with
PImage dollar; // Image "dollar" boids are rendered with
PImage img;
int maxFish = 40;  // Maximum Number of fish or Boids alowed in the simulation
int maxWeight = 0;   
int maxValue = 0;
ArrayList<Year> years;  // Array of years which the simulations data spans 
Table data;  // Data used for info like fish weights and $ values
int firstYear = 1993;  // First year referenced by the Sim  
int selYear = firstYear;  // Initalizing the starting year of the sim 
float oneFish;
float oneDollar;
int curr_weight;
int curr_value;
int level = 1;  // odd levels are fish, even dollars
int[][] pointsCovered;
int imgY = 50;
int imgX = 50;
float zoom = 1;  // Modulates the zoom level of the simulation
PImage displayShape;
float Spar = 1.5;  // Tendancy of fish in the sim to separate (This value is  temporaraly changed on swap from fish to Krona)   
int timer;  // Controls the duration of the increased Spar value after swap

// EXPERIMENTAL
// These vars only come into use as experimental features when the "a" key is pressed

boolean trails = false;     // When set to true creates temp. trails behined fish 
PImage backgroundImg;       // An image to be renedered in the background in experimental mode


// SETUP
// Handles the layout of the sim before it starts running 
void setup() {
  size(1040, 1060);  // Controls the size of the window with which the simulation runs
  smooth();
  // load in data from csv, add it to Year array
  years = new ArrayList<Year>();
  data = loadTable("value_weight_year.csv", "header");
  for (TableRow row : data.rows()) {
    int year_weight = row.getInt("weight");
    String year = row.getString("year");
    int year_value = row.getInt("value");
    Year nYear = new Year(year, year_weight, year_value);
    years.add(nYear);
    // record maximum total weight
    if (year_weight > maxWeight) {
      maxWeight = year_weight;
    }
    // record maximum value
    if (year_value > maxValue) {
      maxValue = year_value;
    }
  }
  flock = new Flock();
  fish = loadImage("SmallBlueTopFish.png");
  dollar = loadImage("IcelandKron.png");
  backgroundImg = loadImage("rubber-duck.jpg");
  img = createImage(backgroundImg.width, backgroundImg.height, RGB);
  pointsCovered = new int[img.width][img.height];
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      pointsCovered[x][y] = 1;
    }
  }

  Year selected_year = years.get(selYear - firstYear);
  curr_weight = selected_year.total_weight;
  curr_value = selected_year.value;
  // calculate the number of fish in the flock, scaled to the maximum weight
  int num_fish = int(maxFish * selected_year.total_weight / maxWeight);
  // calculate the weight that one fish represents
  oneFish = maxWeight / maxFish;
  // Add an initial set of boids into the system
  for (int i = 0; i < num_fish; i++) {
    flock.addBoid(new Boid(width/2, height/2, fish));
  }
  fill(0);
}  /////////// END SETUP //////////////////





// DRAW

void draw() {
scale (zoom);
  //(fish, -140, -140);

  if ((mouseX > imgX && mouseX < imgX + img.width ) && (mouseY > imgY && mouseY < imgY + img.height)) {
      if(pointsCovered[mouseX - imgX][mouseY - imgY] <= 255) {
        pointsCovered[mouseX - imgX][mouseY - imgY] += 10;
        println(pointsCovered[mouseX - imgX][mouseY - imgY]);
      }
    }
    if ( frameCount % 10 == 0 ) {
      img.loadPixels();
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      int transparency = pointsCovered[x][y];
      int index = y * img.width + x;
      color c = color(red(backgroundImg.pixels[index]), green(backgroundImg.pixels[index]), blue(backgroundImg.pixels[index]), transparency);
      img.pixels[index] = c;
    }
  }
  img.updatePixels();
    }
  image (img, imgX, imgY);
  //if (frameCount % 10 == 0) {
    // if trails is set, draw a translucent rectangle instead of an opaque background
    if(trails) {
      fill(255, 255, 255, 10);
      if ( frameCount % 10 == 0) {
        rect(0, 0, width, height);
      }
    }
    else {
    background(255,255,255);
    }
  fill(0);
  // display the year on screen
  textSize(25);
  text(selYear + "", width - 80, 35);
  
  
  // display total weight or value as large transparent text in background
  fill(0, 0, 255, 30);
  textSize(200);
  if ( frameCount % 10 == 0 || !trails ) {
  if (level % 2 == 1) {
    text(curr_weight / 1000 + "", width/2 - 300, height/2 - 95);
    textSize(75);
    text("kilotonnes", 290, height/2);
  }
  else {
    text(curr_value / 1000, 200, height/2 - 95);
    textSize(75);
    text(" million Icelandic krona", 90, height/2);
  }
  }
  flock.run();
  
  ///Everything below this comment will be rendered infront of the swimming fish
  
  fill(0);
  if ( level % 2 == 1 ) {
    // display key to how many tons of fish each fish on-screen represents
    image (fish, 15, 10);
    textSize(15);
    text(" = " + oneFish / 1000 + " kilotonnes of fish caught", 40, 35);
  }
  else {  
    image (dollar, 15, 10);
    textSize(15);
    text(" = " + curr_value / (flock.getSize() * 1000) + " million ISK", 40, 35);
  }
  // display the year on screen
  textSize(25);
  text(selYear + "", width - 80, 35);
}  /////////// END DRAW //////////////////




// KEYPRESSED
void keyPressed() {
  // when space bar is pressed, switch flock from dollars to fish or vice verse
  if (key==' ') {
    level ++;
    flock.breakUp();
  }
  // change trails setting when a key is pressed
  if (key=='a') {
    trails = !trails;
  }
  if (key == CODED) {
    // navigate year with arrow keys
    if (keyCode == LEFT && selYear > firstYear) {
      selYear--;
    }
    else if (keyCode == RIGHT && selYear < 2012) {
      selYear++;
    }
    else if (keyCode == UP) 
    {
      zoom += .03;
    }
    else if (keyCode == DOWN) 
    {
      zoom -= .03;
    }
    // recallibrate flock for selected year
    Year selected_year = years.get(selYear - firstYear);
    curr_weight = selected_year.total_weight;
    curr_value = selected_year.value;
    int num_fish = int(maxFish * selected_year.total_weight / maxWeight);
    // add fish if there should be more this year than the one previously selected
    if (flock.getSize() < num_fish) {
      for (int i = 0; i < num_fish - flock.getSize(); i++) {
        flock.addBoid(new Boid(width/2, height/2, fish));
      }
    }
    // remove fish if there should be less this year than the one previously selected
    else if (flock.getSize() > num_fish) {
      for (int i = 0; i < flock.getSize() - num_fish; i++) {
        flock.removeLast();
      }
    }
  }
}  /////////// END KEYPRESSED //////////////////





// The Boid class
// Boids are the flocking body's in the simulation i.e. Fish or Krona 
class Boid {

  PVector location;     
  PVector velocity;
  PVector acceleration;
  float r;           // Effective radius of reach Boid
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  float SimSpeed;    // Merges Max Speed and Force in order to alow for contol the speed at which things occur while maintianing the dynamics
  PImage icon;  // Image to represent the boid

  Boid(float x, float y, PImage display) {
    acceleration = new PVector(0, 0);
  icon = display;
    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));
    
    SimSpeed = 2.0; //The larger the SimSpeed value, the "faster" the simulation will proceed

    location = new PVector(x, y);
    r = 35.0;
    maxspeed = (SimSpeed*2);
    maxforce = (SimSpeed/33.3);
  }

  void run(ArrayList<Boid> boids) {
    flock(boids);
    update();
    borders();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    PVector mou = mouseAttraction();  //Atraction of Boids to Coursor 
    // Arbitrarily weight these forces
    sep.mult(Spar); // The Separtation value may be modulated in siuations like break-up of fish into dollars, by changing the Spar Var
    ali.mult(1.0);
    coh.mult(1.0);
    mou.mult(1.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    applyForce(mou);
  }

  // Method to update location
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
    
    //Loop creates momentary separation of fish on change in separation value from origional 1.5
    // The Separtation value may be modulated in siuations like break-up of fish into dollars, by changing the Spar Var
    if(Spar != 1.5){
      timer = timer +1;
      if(timer == 6000){ 
       Spar = 1.5;
       timer = 0;
      }
    }
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, location);  // A vector pointing from the location to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render() {
    if ((int(location.x) > imgX && int(location.x) < imgX + img.width ) && (int(location.y) > imgY && int(location.y) < imgY + img.height)) {
      if(pointsCovered[int(location.x) - imgX][int(location.y) - imgY] <= 255) {
        pointsCovered[int(location.x) - imgX][int(location.y) - imgY] += 10;
      }
    }
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up

    pushMatrix();
    translate(location.x, location.y);
    rotate(theta);
    image (icon, 0, -7);
    popMatrix();
  }

  // Wraparound
  void borders() {
    if (location.x < -r) location.x = width+r;
    if (location.y < -r) location.y = height+r;
    if (location.x > width+r) location.x = -r;
    if (location.y > height+r) location.y = -r;
  }
  //Creates the attraction of boids to the cursor when the mouse is clicked
  PVector mouseAttraction(){
    PVector steer = new PVector(0,0,0);
    if(mousePressed){
      steer = new PVector(mouseX - location.x, mouseY - location.y, 0);    
    }
    if (steer.mag() > 0) {
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return( steer );
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 25.5f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(location, other.location);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(location, other.location);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.location); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the location
    } 
    else {
      return new PVector(0, 0);
    }
  }
}  /////////// END BOID CLASS //////////////////




// The Flock (a list of Boid objects)

class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids
  String mode = "fish";

    Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run() {
    for (Boid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

  void removeLast() {
    boids.remove(boids.get(boids.size() - 1));
  }
  
  void replace(boolean even) {
    Boid last = boids.get(boids.size() - 1);
    if (level % 2 == 0) {
      boids.add(0, new Boid(last.location.x + 4, last.location.y, dollar));
      boids.add(0, new Boid(last.location.x - 4, last.location.y, dollar));
    }
    else {
      if (even) {
        boids.add(0, new Boid(last.location.x, last.location.y, fish));
      }
    }
    boids.remove(last);
  }
  
  void breakUp() {
    int numBoids = boids.size();
    for( int i = 0; i < numBoids; i++) {
      if ( i % 2 == 0 ) {
        displayShape = fish;
        Spar = 3.1;
        replace(true);
      }
      else {
        replace(false);
        }
    }
  }
  int getSize() {
    return boids.size();
  }
}   /////////// END FLOCK CLASS //////////////////



// YEAR
class Year {
  String year;
  // weight of the catch, in tonnes
  int total_weight;
  // value of the catch, in 1000 ISK
  int value;

  Year(String the_year, int weight, int the_value) {
    year = the_year;
    total_weight = weight;
    value = the_value;
  }
}  /////////// END YEAR CLASS //////////////////
