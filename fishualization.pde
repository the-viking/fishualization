Flock flock;
boolean trails = false;
PImage fish;
PImage dollar;
PImage backgroundImg;
PImage img;
float fishSizeNum;
int maxFish = 40;
int maxWeight = 0;
int maxValue = 0;
ArrayList<Year> years;
Table data;
int firstYear = 1993;
int selYear = firstYear;
float oneFish;
float oneDollar;
int curr_weight;
int curr_value;
// odd levels are fish, even dollars
int level = 1;
int[][] pointsCovered;

void setup() {
  fishSizeNum = -10;
  size(1040, 1060);
  pointsCovered = new int[width][height];
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
  dollar = loadImage("DollarBilimage.png");
  backgroundImg = loadImage("rubber-duck.jpg");
  img = createImage(backgroundImg.width, backgroundImg.height, RGB);
  for (int i = 0; i < backgroundImg.pixels.length; i++) {
    color c = color(red(backgroundImg.pixels[i]), green(backgroundImg.pixels[i]), blue(backgroundImg.pixels[i]), 50);
    img.pixels[i] = c;
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
  //image (img, 50, 50);
}

void draw() {
  //if (frameCount % 10 == 0) {
    // if trails is set, draw a translucent rectangle instead of an opaque background
    if(trails) {
      fill(255, 255, 255, 10);
      rect(0, 0, width, height);
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
  if (level % 2 == 1) {
    text(curr_weight + "", 30, height/2 - 95);
    text("tons", 320, height/2 + 65);
  }
  else {
    text("$" + curr_value, 30, height/2 - 95);
  }
  flock.run();
  
  ///Everything below this comment will be rendered infront of the swimming fish
  
  fill(0);
  if ( level % 2 == 1 ) {
    // display key to how many tons of fish each fish on-screen represents
    image (fish, 10, 10);
    textSize(15);
    text(" = " + oneFish + " tons of fish", 40, 25);
  }
  else {  
    image (dollar, 10, 10);
    textSize(15);
    text(" = " + curr_value / flock.getSize() + " Icelandic króna", 40, 25);
  }
  // display the year on screen
  textSize(25);
  text(selYear + "", width - 80, 35);
}

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
    if (keyCode == RIGHT && selYear < 2012) {
      selYear++;
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
}

// Add a new boid when mouse is pressed
void mousePressed() {
  flock.addBoid(new Boid(mouseX, mouseY, fish));
}



// The Boid class

class Boid {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  float SimSpeed;
  PImage icon;  // Image to represent the boid

  Boid(float x, float y, PImage display) {
    acceleration = new PVector(0, 0);
  icon = display;
    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));


    SimSpeed = 2.0;

    location = new PVector(x, y);
    r = 35.0;
    maxspeed = (SimSpeed*2);
    maxforce = (SimSpeed/30.3);
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
    // Arbitrarily weight these forces
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
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
    if ((location.x > 0 && location.x < width ) && (location.y > 0 && location.y < height)) {
      if(pointsCovered[int(location.x)][int(location.y)] <= 255) {
        pointsCovered[int(location.x)][int(location.y)] ++;
      }
    }
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up

    pushMatrix();
    translate(location.x, location.y);
    rotate(theta);

    //shape( fish, fishSizeNum, fishSizeNum, 30, 30);
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
}




// The Flock (a list of Boid objects)

class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids

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
  
  void replace() {
    Boid last = boids.get(boids.size() - 1);
    if (level % 2 == 0) {
      boids.add(0, new Boid(last.location.x + 4, last.location.y, dollar));
      boids.add(0, new Boid(last.location.x - 4, last.location.y, dollar));
    }
    else {
      boids.add(0, new Boid(last.location.x, last.location.y, fish));
    }
    boids.remove(last);
  }
  
  void breakUp() {
    int numBoids = boids.size();
    for( int i = 0; i < numBoids; i++) {
      if (level % 2 == 1) {
        if (i % 2 == 0) {
          replace();
        }
      }
      else {
        replace();
      }
    }
  }
  int getSize() {
    return boids.size();
  }
  /*
  void breakUp() {
    ArrayList<Boid> boidsCopy = boids;
    for( int i = 0; i < boidsCopy.size(); i++) {
      boids.remove(boids.get(i));
    }
    println(boidsCopy.size());
    
    for( int i = 0; i < boidsCopy.size(); i++) {
      int x = int(boidsCopy.get(i).location.x);
      int y = int(boidsCopy.get(i).location.y);
      boids.add(new Boid(0,0));
      //boids.add(new Boid(x, y-5));
      //boids.add(new Boid(x+5, y+5, dollar));
      //boids.add(new Boid(x-5, y+5, dollar));
    }
    
  }*/
}

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
}

