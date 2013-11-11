int windowWidth = 800;
int windowHeight = 800;
int framerate = 30;

int tankWidth = 400, tankHeight = 600;
int tankCornerRadius = 50;
int tankBorderColor = 0;
int tankXpos = (int)windowWidth/8, tankYpos = (int)windowHeight/8;

int nukeWidth = 50, nukeHeight = 250;
int nukeXpos = tankXpos + 50, nukeYpos = (tankHeight - nukeHeight) - 150;
int nukeColor = 150;

int rodWidth = 20, rodHeight = 250;
int rodXpos1 = 225, rodStartYPos = 300;
int rodMaxYPos = tankYpos + tankHeight - rodHeight - 10;
int rodMinYPos = tankYpos + 10;
int rodSpeed = 10;

int textXpos = 550, textYpos = 200;
int temperatureUpdateSpeed = 20;

int scientistMaxXpos = (int)rodWidth/2 - 16 + rodXpos1 + 130, scientistMinXpos = rodXpos1 + (int)rodWidth/2 - 16;
int scientistYpos = tankYpos + tankHeight;
int scientistWalkSpeed = 8;
int scientistSpeechPos = 500;
int welcomeSpeechDuration = 80;

int smallExplosionDuration = 60;
int bigExplosionDuration = 160;

class Tank {
  void display() {
    fill(2,128,222, 50);
    stroke(color(tankBorderColor));
    strokeWeight(8);
    rect(tankXpos, tankYpos, tankWidth, tankHeight, tankCornerRadius);
  }
}

class NukeCores {
  PImage symbol;
  
  NukeCores() {
    symbol = loadImage("radioactivitysymbol.png");
  }
  
  void display() {
    stroke(nukeColor);
    for(int i = 0; i < 300; i += 125) {
      fill(nukeColor);
      rect(nukeXpos + i, nukeYpos, nukeWidth, nukeHeight, 5);
      image(symbol, nukeXpos + i, nukeYpos + 5);
      textFont(createFont("Arial",35,true), 35);
      fill(0, 102, 153);
      text("C", nukeXpos + i + 12, nukeYpos + 90);
      text("O", nukeXpos + i + 12, nukeYpos + 140);
      text("R", nukeXpos + i + 12, nukeYpos + 190);
      text("E", nukeXpos + i + 12, nukeYpos + 240);
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
  
  int getY() { return (int)(rod1Y + rod2Y)/2; }
  
  void display() {
    fill(0);
    noStroke();
    rect(rodXpos1, rod1Y, rodWidth, rodHeight);
    rect(rodXpos1 + 130, rod2Y, rodWidth, rodHeight);
    // add gray lines from rods to bottom of tank
    strokeWeight(2);
    stroke(150);
    line(rodXpos1 + (int)rodWidth/2, rod1Y+rodHeight, rodXpos1 + (int)rodWidth/2, tankYpos + tankHeight);
    line(rodXpos1 + (int)rodWidth/2 + 130, rod2Y+rodHeight, rodXpos1 + (int)rodWidth/2 + 130, tankYpos + tankHeight);
  }
}

class StatusBar {
  PFont txtFont, tempNumber, statusText;
  color red, green, orange, blue;
  int temperature;
  int updateCount;
  int powerStatus; // 0 down, 1 up, -1 up-orange
  boolean heatingUp = false;
  boolean startingUp = true;
  
  StatusBar() {
    super();
    txtFont = createFont("Arial",20,true);
    tempNumber = createFont("Arial",50,true);
    statusText = createFont("Arial", 25,true);
    red = color(255,0,0);
    green = color(0, 255, 0);
    orange = color(255, 125, 0);
    blue = color(0,0,255);
    temperature = 200;
    powerStatus = 0;
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
      temperatureSpeed = -(int)(getShielding(rodsY)/5 - 13 + Math.random()*5);
      if(temperatureSpeed > 0) heatingUp = true;
      else heatingUp = false;
      temperature += temperatureSpeed;
      updateCount = 0;
    } else updateCount++;
  }
  
  void setStartingUpFalse() { startingUp = false; }
  
  void drawGrid() {
    stroke(0);
    line(0, 90, windowWidth, 90);
    line(200, 0, 200, 90);
    line(400, 0, 400, 90);
  }

  void display() {
    drawGrid();
    // texts
    fill(0);
    textFont(txtFont, 20);
    text("Temperature:", 5, 20);
    text("Energy production:", 210, 20);
    text("Nuclear core state:", 410, 20);
    // numbers/statuses
    // temperature
    textFont(tempNumber, 50);
    fill(red);
    text(((Integer)temperature).toString()+ " °C", 20, 74);
    // power  
    if(powerStatus == 0) {
      text("DOWN", 220, 74);
    } else if(powerStatus == -1) {
      fill(orange);
      text("UP", 220, 74);
    } else {
      fill(green);
      text("UP", 220, 74);
    }
    // status
    textFont(statusText, 25);
    if(startingUp) {
      fill(orange);
      text("starting up", 410, 76);
    } else if(temperature > 400) {
      // 0 down, 1 up, -1 up-orange
      powerStatus = -1;
      fill(red);
      text("MELTDOWN APPROACHING!", 410, 76);
    } else if(temperature > 200) {
      powerStatus = 1;
      fill(green);
      text("happily producing energy!", 410, 76);
    } else if(temperature > 100) {
      powerStatus = -1;
      fill(orange);
      text("shutdown approaching!", 410, 76);
    } else {
      powerStatus = 0;
      fill(red);
      text("reaction shut down!", 410, 76);
    }
    
    if(heatingUp) {
      fill(orange);
      text("heating up", 410, 50);
    } else {
      fill(blue);
      text("cooling down", 410, 50);
    }
      
  }
}

class Scientist {
  PImage sprite;
  PImage[] comics;
  int spriteWidth = 32, spriteHeight = 48; // image is 128x192, composite of animation frames
  int frameCoords[] = {0,144}; // coordinates of current frame to draw
  int currentX = windowWidth;  // start outside window, waiting to walk in
  // should use enum for state, but processing.js might not support enums
  int state = -1; // 0 standing at left rod
                  // 1 for walking right
                  // 2 for standing at right rod
                  // 3 for walking left
                  // -1 is enter scene
                  // -2 is stand to give welcome message
                  // -3 is walk to left rod
                  // -4 is for booking it
  int animationCount, animationSpeed = 3;
  int comicToDisplay = -1;
  
  Scientist() {
    super();
    sprite = loadImage("scientist.png");
    comics = new PImage[6];
    comics[0] = loadImage("welcome.png");
    comics[1] = loadImage("got300.png");
    comics[2] = loadImage("warninglow.png");
    //comics[3] = loadImage("frozen.png");
    comics[4] = loadImage("warninghigh.png");
    comics[5] = loadImage("help.png");
  }
  
  boolean doneEntering() { return state>=0; }  // thumbs-up for other game controls to begin
  
  boolean isWalking() { return state == 1 || state == 3; }  // used to prevent control of rods when walking
  
  // walk to speech pos
  void enterScene() {
    state = -1;
    frameCoords[1] = 48;
    animateLeft();
    walkTo(scientistSpeechPos);
    checkSpeechLimits();
  }
  
  // show welcome speech and pause for a few seconds
  void standSpeech() {
    state = -2;
    frameCoords[0] = frameCoords[1] = 0;
    animateSpeech();
  }
  
  void animateSpeech() {
    animationCount++;
    if(animationCount >= welcomeSpeechDuration) {
      animationCount = 0;
      state = -3;
    }
  }
  
  void walkToRod() {
    state = -3;
    frameCoords[1] = 48;
    animateLeft();
    walkTo(scientistMinXpos);
    checkLeftLimit();
  }
  
  void bookIt() {
    state = -4;
    animationSpeed=2;
    scientistWalkSpeed=12;
    frameCoords[1] = 96;
    animateRight();
    walkTo(900);
  }
  
  void walkTo(int xPosition) {
    if(currentX == xPosition) return;
    
    if(currentX > xPosition) {
      currentX-=scientistWalkSpeed;
    } else if(currentX < xPosition) {
      currentX+=scientistWalkSpeed;
    }
  }
  
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
  
  void animateLeft() {
    animationCount++;
    if(animationCount >= animationSpeed) {
      animationCount = 0;
      frameCoords[0]+=spriteWidth;
      if(frameCoords[0] >= 128)
        frameCoords[0] = 0;
    }
    else animationCount++;
  }
  
  void animateRight() {
    animationCount++;
    if(animationCount >= animationSpeed) {
      animationCount = 0;
      frameCoords[0]+=spriteWidth;
      if(frameCoords[0] >= 128)
        frameCoords[0] = 0;
    }
    else animationCount++;
  }
  
  void walkLeft() {
    state = 3;
    animateLeft();
    frameCoords[1] = 48;
    walkTo(scientistMinXpos);
    checkWalkLimits();
  }
  
  void walkRight() {
    state = 1;
    animateRight();
    frameCoords[1] = 96;
    walkTo(scientistMaxXpos);
    checkWalkLimits();
  }
  
  // stops walking if reached destination
  void checkWalkLimits() {
    if(currentX >= scientistMaxXpos) {
      standRight();
    }
    else {
      checkLeftLimit();
    }
  }
  
  // stops walking left if reached speech position during entering scene
  void checkSpeechLimits() {
    if(currentX <= scientistSpeechPos) {
      currentX = scientistSpeechPos;
      animationCount = 0;
      comicToDisplay = 0;
      standSpeech();
    }
  }
  
  void checkLeftLimit() {
    if(currentX <= scientistMinXpos) {
      standLeft();
    }
  }
  
  void update() {
    // check for keys pressed and update state accordingly. Negative states are passive, entering scene
    if(doneEntering() && keyPressed && key == CODED) {
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
      case -1:
      enterScene();
      break;
      case -2:
      standSpeech();
      break;
      case -3:
      walkToRod();
      break;
      case -4:
      bookIt();
      break;
    }
  }
  
  void display() {
    PImage toDraw = sprite.get(frameCoords[0],frameCoords[1],spriteWidth,spriteHeight);
    toDraw.resize(0,96);
    image(toDraw,currentX,scientistYpos);
    drawComic();
  }
  
  void drawComic() {
    switch(comicToDisplay) {
     case -1:
     break;
     case 5:
     image(comics[5], currentX, scientistYpos-40);
     break;
     default:
     image(comics[comicToDisplay], scientistSpeechPos+8, 300);
     break;
    }
  }
}

class GameControl {
  Tank tank;
  NukeCores cores;
  ControlRods rods;
  StatusBar bar;
  Scientist madScientist;
  Explosions explosions;
  PImage startScreen;
  
  int waitCount, waitTime = 0;
  
  int phase;  // 0 is start screen
              // 1 is scientist entering
              // 2 is game bring T to 300 phase
              // 3 is wait a bit to let player read text
              // 4 is general game phase
              // 5 is meltdown
              // 6 is shutdown (freeze)
              // 7 is scientist booking it before meltdown
  
  GameControl() {
    super();
    resetGame();
  }
  
  void resetGame() {
    phase = 0;
    tank = new Tank();
    cores = new NukeCores();
    madScientist = new Scientist();
    rods = new ControlRods(madScientist);
    bar = new StatusBar();
    explosions = new Explosions();
    startScreen = loadImage("startScreen.png");
  }
  
  void update() {
    rods.update();
    bar.update(rods.getY());
    madScientist.update();
  }

  void displayAll() {
    background(255);
    cores.display();
    tank.display();
    rods.display();
    bar.display();
    madScientist.display();
  }

  void phase0() {
    if(mousePressed && mouseButton == LEFT) {
      phase = 1;
    }
    displayStartScreen();
  }

  void phase1() {
    if(madScientist.doneEntering()) {
      phase = 2;
    }
    madScientist.update();
    displayAll();
  }
  
  void phase2() {
    update();
    displayAll();
    if(bar.temperature > 290) {
      //temperatureUpdateSpeed = 10; 20 works better
      madScientist.comicToDisplay = 1;
      phase = 3;
    } else if(bar.temperature < 120) {
      phase = 4;
    }
  }
  
  void phase3() {
    rods.update();
    madScientist.update();
    displayAll();
    if(waited()) { phase = 4; bar.setStartingUpFalse(); }
  }
  
  boolean waited() {
    waitCount++;
    return waitCount > waitTime;
  }
  
  void phase4() {
    update();
    displayAll();
    if(bar.temperature < 100) {
      madScientist.comicToDisplay = 3;
      phase = 6;
    } else if(bar.temperature < 200) {
      madScientist.comicToDisplay = 2;
    } else if(bar.temperature > 500) {
      madScientist.comicToDisplay = 5;
      phase = 7;
      waitCount = 0;
      waitTime = 50;
    } else if(bar.temperature > 400) {
      madScientist.comicToDisplay = 4;
    }
  }
  
  void phase5() {
    displayAll();
    explosions.update();
    explosions.display();
  }
  
  void phase6() {
    background(color(173,253,255));
    textFont(createFont("Arial",50,true), 50);
    fill(color(0,0,255));
    text("Temperature got too low\nand the reaction shut down!\nrefresh page to try again", 40, 300);
  }
  
  void phase7() {
    madScientist.state = -4;
    update();
    displayAll();
    if(waited()) phase = 5;
  }
  
  void updateAndDisplay() {
    switch(phase) {
      case 0:
      phase0();
      break;
      case 1:
      phase1();
      break;
      case 2:
      phase2();
      break;
      case 3:
      phase3();
      break;
      case 4:
      phase4();
      break;
      case 5:
      phase5();
      break;
      case 6:
      phase6();
      break;
      case 7:
      phase7();
      break;
    }
  }

  void displayStartScreen() {
    background(255);
    image(startScreen,1,1);
    textFont(createFont("Calibri",50,true), 50);
    fill(0);
    text("  Welcome to the reactor", 255, 200);
    text("           control room!", 255, 250);
    textFont(createFont("Calibri",25,true), 25);
    text(" left mouse click to start at any time", 300, 340);
    textFont(createFont("Calibri",39,true), 39);
    text("You will control the reactor temperature", 10, 450);
    text(" through the moving rods.", 10, 490);
    text("To produce energy, the temperature", 10, 540);
    text(" should stay around 300 °C.", 10, 580);
    text("If you let the temperature reach 500 °C,", 10, 630);
    text(" the reactor will incur in a meltdown.", 10, 670);
    text("If you let the temperature drop below 100 °C,",10,720);
    text(" the reaction will shutdown, producing no power.", 10, 760);
  }
}

class Explosions {
  PImage[] smallExplosionGif;
  PImage[] bigExplosionGif;
  int smallExplCounter = 0, bigExplCounter = 0;
  
  boolean switchGif = false;
  
  SmallExplosion[] smallExplosions;
  BigExplosion bigExplosion;
  
  Explosions() {
    super();
    // load gif frames for small and big explosion
    smallExplosionGif = new PImage[12];
    bigExplosionGif = new PImage[16];
    for(int i=0; i < 12; i++) {
      smallExplosionGif[i] = loadImage("expl"+(i+1)+".png");
    }
    for(int i=0; i < 16; i++) {
      bigExplosionGif[i] = loadImage("eb"+i+".png");
    }
    smallExplosions = new SmallExplosion[3];
    for(int i=0; i < 3; i++) {
      smallExplosions[i] = new SmallExplosion(nukeXpos + 125*i - 50, nukeYpos - 40);
    }
    bigExplosion = new BigExplosion();
  }
  
  void update() {
    if(!switchGif) {
      smallExplCounter++;
      if(smallExplCounter > smallExplosionDuration) switchGif = true;
      for(SmallExplosion i : smallExplosions) i.update();
    } else {
      //bigExplosionCounter++;
      bigExplosion.update();
    }
  }
  
  void display() {
    if(!switchGif) {
      for(SmallExplosion i : smallExplosions) i.display();
    } else {
      background(0);
      bigExplosion.display();
    }
  }

  
  class SmallExplosion {
    int xPos,yPos;
    int counter = 0;
    int gifIndex = 0;
    boolean finished = false;
    
    SmallExplosion(int x, int y) {
      super();
      xPos = x;
      yPos = y;
    }
    
    void update() {
      if(finished) return;
      
      counter++;
      
      if(counter > 2) {
        counter = 0;
        gifIndex++;
        if(gifIndex > 11) finished = true;
      }
    }
    
    void display() {
      if(finished) return;
      smallExplosionGif[gifIndex].resize(149,340);
      image(smallExplosionGif[gifIndex],xPos,yPos);
    }
  }
  
  class BigExplosion {
    int counter = 0;
    int gifIndex = 0;
    boolean finished = false;
    
    void update() {
      if(finished) return;
      
      counter++;
      
      if(counter > 2) {
        counter = 0;
        gifIndex++;
        if(gifIndex > 15) finished = true;
      }
    }
    
    void display() {
      if(finished) {
        background(0);
        textFont(createFont("Arial",45,true), 45);
        fill(color(255,0,0));
        text("Temperature got too high,\ncausing a meltdown and\nexplosions thoroughout the\npower plant!\nrefresh page to try again", 50, 300);
        return;
      }
      bigExplosionGif[gifIndex].resize(windowWidth,windowHeight);
      image(bigExplosionGif[gifIndex],0,0);
    }
  } 
}

GameControl game;

void setup() {
  frameRate(framerate);
  size(windowWidth, windowHeight, P2D);
  game = new GameControl();
}

void draw() {
  game.updateAndDisplay();  
}
