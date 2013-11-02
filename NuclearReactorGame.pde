int windowWidth = 800;
int windowHeight = 800;
int framerate = 30;

int tankWidth = 400, tankHeight = 600;
int tankCornerRadius = 50;
int tankBorderColor = 0;
int tankXpos = windowWidth/8, tankYpos = windowHeight/8;

int nukeWidth = 50, nukeHeight = 250;
int nukeXpos = tankXpos + 50, nukeYpos = (tankHeight - nukeHeight) - 150;
int nukeColor = 150;

int rodWidth = 20, rodHeight = 250;
int rodXpos1 = 225, rodStartYPos = 300;
int rodMaxYPos = tankYpos + tankHeight - rodHeight - 10;
int rodMinYPos = tankYpos + 10;
int rodSpeed = 10;

int textXpos = 550, textYpos = 200;
int temperatureUpdateSpeed = 10;

int scientistMaxXpos = rodWidth/2 - 16 + rodXpos1 + 130, scientistMinXpos = rodXpos1 + rodWidth/2 - 16;
int scientistYpos = tankYpos + tankHeight;
int scientistWalkSpeed = 8;

class Tank {
  void display() {
    fill(2,128,222, 50);
    stroke(color(tankBorderColor));
    strokeWeight(8);
    rect(tankXpos, tankYpos, tankWidth, tankHeight, tankCornerRadius);
  }
}

class NukeCores {
  void display() {
    fill(color(nukeColor));
    stroke(color(nukeColor));
    for(int i = 0; i < 300; i += 125) {
      rect(nukeXpos + i, nukeYpos, nukeWidth, nukeHeight, 5);
    }
  }
}

class ControlRods {
  int rod1Y = rodStartYPos, rod2Y = rodStartYPos;
  int selectedRod = 0;
  Scientist scientistRef;
  
  ControlRods(Scientist scientistReference) {
    super();
    scientistRef = scientistReference;
  }
  
  void update() {
    if(keyPressed && key == CODED) {
      switch(keyCode) {
        case LEFT:
        selectedRod = 0;
        break;
        case RIGHT:
        selectedRod = 1;
        break;
        case UP:
        if(scientistRef.isWalking()) break;
        switch(selectedRod) {
          case 0:
          if(rod1Y > rodMinYPos ) rod1Y-=rodSpeed;
          break;
          case 1:
          if(rod2Y > rodMinYPos ) rod2Y-=rodSpeed;
          break;
        }
        break;
        case DOWN:
        if(scientistRef.isWalking()) break;
        switch(selectedRod) {
          case 0:
          if(rod1Y < rodMaxYPos ) rod1Y+=rodSpeed;
          break;
          case 1:
          if(rod2Y < rodMaxYPos ) rod2Y+=rodSpeed;
          break;
        }
        break;
      }
    }
    
    // sinking effect:
    if( rod1Y < rodMaxYPos ) rod1Y++;
    if( rod2Y < rodMaxYPos ) rod2Y++;
  }
  
  int getY() { return (rod1Y + rod2Y)/2; }
  
  void display() {
    fill(0);
    noStroke();
    rect(rodXpos1, rod1Y, rodWidth, rodHeight);
    rect(rodXpos1 + 130, rod2Y, rodWidth, rodHeight);
  }
}

class Temperature {
  PFont tempText, tempNumber;
  color tempColor;
  int temperature;
  int updateCount;
  
  Temperature() {
    tempNumber = createFont("Arial",50,true);
    tempColor = color(255,0,0);
    temperature = 200;
  }
  
  // returns value between 0 and 100. 0 is no shielding, 100 is full shielding (shielding of cores by rods)
  int getShielding(int rodsY) {
     int diff = (int)100*(rodsY - nukeYpos)/nukeHeight;
     if(diff > 0) return 100 - diff;
     else return 100 + diff;
  }
  
  void update(int rodsY) {
    int temperatureSpeed;
    
    if(updateCount >= temperatureUpdateSpeed) {
      temperatureSpeed = -(int)(getShielding(rodsY)/5 - 15 + Math.random()*5);
      temperature += temperatureSpeed;
      updateCount = 0;
    } else updateCount++;
  }
    
  void display() {
    textFont(tempNumber, 50);
    fill(tempColor);
    text(((Integer)temperature).toString(), textXpos, textYpos);
  }
}

class Scientist {
  PImage sprite;
  int spriteWidth = 32, spriteHeight = 48; // image is 128x192, composite of animation frames
  int frameCoords[] = {0,144}; // coordinates of current frame to draw
  int currentX = scientistMinXpos;
  // should use enum for state, but processing.js might not support enums
  int state = 0;  // 0 standing at left rod
                  // 1 for walking right
                  // 2 for standing at right rod
                  // 3 for walking left
  int animationCount, animationSpeed = 3;
  
  Scientist() {
    super();
    sprite = loadImage("scientist.png");
  }
  
  boolean isWalking() { return state == 1 || state == 3; }
  
  void standLeft() {
    state = 0;
    frameCoords[0] = 0;
    frameCoords[1] = 144;
    currentX = scientistMinXpos;
  }
  
  void standRight() {
    state = 2;
    frameCoords[0] = 0;
    frameCoords[1] = 144;
    currentX = scientistMaxXpos;
  }
  
  void walkLeft() {
    state = 3;
    animationCount++;
    if(animationCount >= animationSpeed) {
      animationCount = 0;
      frameCoords[0]+=spriteWidth;
      if(frameCoords[0] >= 128)
        frameCoords[0] = 0;
    }
    else animationCount++;
    frameCoords[1] = 48;
    currentX-=scientistWalkSpeed;
    checkLimits();
  }
  
  void walkRight() {
    state = 1;
    animationCount++;
    if(animationCount >= animationSpeed) {
      animationCount = 0;
      frameCoords[0]+=spriteWidth;
      if(frameCoords[0] >= 128)
        frameCoords[0] = 0;
    }
    else animationCount++;
    frameCoords[1] = 96;
    currentX+=scientistWalkSpeed;
    checkLimits();
  }
  
  // stops walking if reached destination
  void checkLimits() {
    if(currentX >= scientistMaxXpos) {
      standRight();
    }
    else if(currentX <= scientistMinXpos) {
      standLeft();
    }
  }
  
  void update() {
    // check for keys pressed and update state accordingly
    if(keyPressed && key == CODED) {
      switch(keyCode) {
        case LEFT:
        state = 3;
        break;
        case RIGHT:
        state = 1;
        break;
      }
    }
    // update position/sprite according to state
    switch(state) {
      case 0:
      standLeft();
      break;
      case 2:
      standRight();
      break;
      case 1:
      walkRight();
      break;
      case 3:
      walkLeft();
      break;
    }
  }
  
  void display() {
    image(sprite.get(frameCoords[0],frameCoords[1],spriteWidth,spriteHeight),currentX,scientistYpos);
  }
}

Tank tank;
NukeCores cores;
ControlRods rods;
Temperature temp;
Scientist madScientist;

void setup() {
  frameRate(framerate);
  size(windowWidth, windowHeight, P2D);
  tank = new Tank();
  cores = new NukeCores();
  madScientist = new Scientist();
  rods = new ControlRods(madScientist);
  temp = new Temperature();
}

void update() {
  rods.update();
  temp.update(rods.getY());
  madScientist.update();
}

void draw() {
  update();
  background(255);
  cores.display();
  tank.display();
  rods.display();
  temp.display();
  madScientist.display();
  //println(temp.getShielding(rods.getY()));
}
