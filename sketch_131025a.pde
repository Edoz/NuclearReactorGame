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
  int updateSpeed, updateCount;
  
  Temperature() {
    tempNumber = createFont("Arial",50,true);
    tempColor = color(255,0,0);
    temperature = 200;
    updateSpeed = 10;
  }
  
  // returns value between 0 and 100. 0 is no shielding, 100 is full shielding (shielding of cores by rods)
  int getShielding(int rodsY) {
     int diff = (int)100*(rodsY - nukeYpos)/nukeHeight;
     if(diff > 0) return 100 - diff;
     else return 100 + diff;
  }
  
  void update(int rodsY) {
    int temperatureSpeed;
    
    if(updateCount >= updateSpeed) {
      temperatureSpeed = -(int)(getShielding(rodsY)/5 - 16 + Math.random()*5);
      temperature += temperatureSpeed;
      updateCount = 0;
    } else updateCount++;
    
    /*if(temperatureSpeed < 40) temperatureSpeed = (40 - temperatureSpeed)/4;
    else if(temperatureSpeed > 60) temperatureSpeed = (60 - temperatureSpeed)/4;
    else temperatureSpeed = 0;*/
    
  }
    
  void display() {
    textFont(tempNumber, 50);
    fill(tempColor);
    text(((Integer)temperature).toString(), textXpos, textYpos);
  }
}

Tank tank;
NukeCores cores;
ControlRods rods;
Temperature temp;

void setup() {
  frameRate(framerate);
  size(windowWidth, windowHeight, P2D);
  tank = new Tank();
  cores = new NukeCores();
  rods = new ControlRods();
  temp = new Temperature();
}

void update() {
  rods.update();
  temp.update(rods.getY());
}

void draw() {
  update();
  background(255);
  cores.display();
  tank.display();
  rods.display();
  temp.display();
  println(temp.getShielding(rods.getY()));
}
