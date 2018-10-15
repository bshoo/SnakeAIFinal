//To do list:
//Make sure it can form a nand, nor, and not gate

generation g;
int radarDistance = 2; //Change this to change how far the snake can see (Certain terms and conditions apply)
boolean useBiggerRadar = false; //Control what the snake sees (don't change this, pretty sure this no longer works)
boolean useFullScreenVector = false; //Also control what the snake sees (also don't change this, this definitely doesn't work)
int currentGen = 0;
boolean warpSpeed = false;
int[] layerStructure = {!useFullScreenVector ? (useBiggerRadar ? (2 * radarDistance + 1)*(radarDistance+1) + 21 : radarDistance * 4 + 21) : 4625, 32, 16, 3}; //32 and 6 worked
int population = 1000;
int mutated = 200;
ArrayList<Integer> recordSnakeLength = new ArrayList<Integer>();
ArrayList<Float> pastLengths = new ArrayList<Float>();
game gam = new game(4, 5);
int focus = 0;
boolean foodInRadar = false; //Don't change this either
int largestSnake = 0;

void setup() {
  size(1280, 720);
  colorMode(RGB);
  noStroke();
  frameRate(17);
  frameRate(5000000);
  ArrayList<float[]> InitDNASet = new ArrayList<float[]>();
  for (int i = 0; i < population; i++) {
    float[] DNA = new float[totalConnections(layerStructure.length - 1)];
        for (int j = 0; j < DNA.length; j++) {
            DNA[j] = randomGaussian();
        }
    InitDNASet.add(DNA);
    println("[*] Initializing: " + i);
  }
  println("[+] Initialization complete");
  g = new generation(InitDNASet);
  println("[+] Generation 0 created");
  recordSnakeLength.add(0);
  focus = 0;
}

void draw() {
  background(51);
  for (int i = 0; i < pastLengths.size(); i++) {
    textSize(13);
    fill(255 - (7 * i));
    textAlign(RIGHT, BOTTOM);
    String displayFitness = String.valueOf(pastLengths.get(i));
    text(displayFitness, 1275, 720 - (i*15 + 5));
  }
  if (warpSpeed == false) {
    g.playAllGames();
  } else if (warpSpeed == true) {
    g.finishAllGames();
  }
  if (g.genomes.get(focus).g.lost == true && warpSpeed == false) {
    focus = g.idOfBiggestestSnake();
  }
  if (warpSpeed ==false) {
    g.genomes.get(focus).g.showPixels();
  }
  if (g.everythingDead() == true) {
    recordSnakeLength.add(g.getLargestLength());
    if (g.getLargestLength() > largestSnake) {
      largestSnake = g.getLargestLength();
      PrintWriter out = createWriter("DNA.txt");
      out.println(layerStructure.length);
      for (int i = 0; i < layerStructure.length; i++) {
        out.println(layerStructure[i]);
      }
      for (int i = 0; i < g.genomes.get(g.idOfLongestSnake()).DNA.length; i++) {
        out.println(g.genomes.get(g.idOfLongestSnake()).DNA[i]);
      }
      out.flush();
      out.close();
    }
    if (recordSnakeLength.size() > 1150) {
      recordSnakeLength.remove(0);
    }
    pastLengths.add(0, (float)g.getLargestLength());
    if (pastLengths.size() > 30) {
      pastLengths.remove(pastLengths.size() - 1);
    }

    if (g.getLargestLength() > 30 || currentGen < 20) {
      g = g.crossover();
      currentGen++;
    } else {
      ArrayList<float[]> InitDNASet = new ArrayList<float[]>();
      for (int i = 0; i < population; i++) {
        float[] DNA = new float[totalConnections(layerStructure.length - 1)];
        for (int j = 0; j < DNA.length; j++) {
            DNA[j] = randomGaussian();
        }
        InitDNASet.add(DNA);
        println("[*] Initializing: " + i);
      }
      println("[+] Initialization complete");
      g = new generation(InitDNASet);
      println("[+] Generation 0 created");
      currentGen = 0;
    }
    focus = 0;
  }
  for (int i = 1; i < recordSnakeLength.size(); i++) {
    stroke(255);
    if (i >= 946) {
      stroke(255-(i-946), 255-(i-946), 255-(i-946));
    }
    line(i - 1, 720 - recordSnakeLength.get(i - 1), i, 720 - recordSnakeLength.get(i));
    noStroke();
  }

  //gam.playGame();
  //gam.showPixels();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      //frameRate(5894302);
      gam.testDir(0);
    } else if (keyCode == RIGHT) {
      gam.testDir(1);
    } else if (keyCode == DOWN) {
      //frameRate(25);
      gam.testDir(2);
    } else if (keyCode == LEFT) {
      gam.testDir(3);
    }
  }
  if (key == 'w') {
    noLoop();
  }
  if (key == 's') {
    loop();
  }
  if (key == 'd') {
    warpSpeed = true;
  }
  if (key == 'a') {
    warpSpeed = false;
  }
  redraw();
}

int totalConnections(int x) { //Connections prior to this layer (including connections to this layer)
  int out = 0;
  for (int i = 0; i < x; i++) {
    out += layerStructure[i] * layerStructure[i+1];
  }
  return out;
}

int arraySum(int[] x, int index) {
  int out = 0;
  for (int i = 0; i < index + 1; i++) {
    out+= x[i];
  }
  return out;
}
