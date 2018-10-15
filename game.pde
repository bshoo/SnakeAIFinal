class game {
  ArrayList<ArrayList<pixel>> pixels = new ArrayList<ArrayList<pixel>>();
  ArrayList<int[]> tail = new ArrayList<int[]>();
  ArrayList<Float> speeds = new ArrayList<Float>();
  String head, body, food, empty;
  boolean lost = false;
  int snakeLength = 1;
  int[] headLoc = {1, 1};
  int[] foodLoc = {1, 1};
  float fitness;
  float fit = 1;
  int lifetime = 0;
  int inLoops = 100;
  int timeSinceLastFood = 0;
  float pastDistance;

  int dir = 2;
  int turn = 0;
  int[] past = {0, 0, 0};

  game(int x, int y) {
    for (int i = 0; i < 1280/20; i++) {
      pixels.add(new ArrayList<pixel>());
      for (int j = 0; j < 720/20; j++) {
        pixels.get(i).add(new pixel(i, j));
      }
    }

    head = "head";
    body = "body";
    food = "food";
    empty = "empty";

    foodLoc[0] = x;
    foodLoc[1] = y;
    pixels.get(foodLoc[0]).get(foodLoc[1]).changeStatus(food);
    pixels.get(1).get(1).changeStatus(head);

    pastDistance = sqrt(sq(foodLoc[0] - headLoc[0]) + sq(foodLoc[1] - headLoc[1]));
  }

  void showPixels() {
    for (int i = 0; i < pixels.size(); i++) {
      for (int j = 0; j < pixels.get(i).size(); j++) {
        pixels.get(i).get(j).show();
      }
    }
  }

  void changeDir(int d) { //-1,0,1 (L,S,R)
    past[2] = past[1];
    past[1] = past[0];
    past[0] = turn;
    turn = d;
    dir += d;
    if (dir <= -1) {
      dir = 3;
    } else if (dir >= 4) {
      dir = 0;
    }
  }

  void testDir(int d) {
    dir = d;
  }

  void playGame() {
    if (lost != true) {
      if (tail.size() >= 1) {
        int[] temp = new int[2];
        temp[0] = headLoc[0];
        temp[1] = headLoc[1];
        tail.add(0, temp);
      }

      //-----------------------------------------------------------------

      if (dir == 0) { //Up
        pixels.get(headLoc[0]).get(headLoc[1]).changeStatus(empty);
        headLoc[1]--;
        if (headLoc[1] < 0) {
          headLoc[1]++;
          pixels.get(headLoc[0]).get(headLoc[1]).changeStatus(head);
          lost = true;
          calcFit();
          return;
        }
        pixels.get(headLoc[0]).get(headLoc[1]).changeStatus(head);
      } else if (dir == 1) { //Right
        pixels.get(headLoc[0]).get(headLoc[1]).changeStatus(empty);
        headLoc[0]++;
        if (headLoc[0] >= 1280/20) {
          headLoc[0]--;
          pixels.get(headLoc[0]).get(headLoc[1]).changeStatus(head);
          lost = true;
          calcFit();
          return;
        }
        pixels.get(headLoc[0]).get(headLoc[1]).changeStatus(head);
      } else if (dir == 2) { //Down
        pixels.get(headLoc[0]).get(headLoc[1]).changeStatus(empty);
        headLoc[1]++;
        if (headLoc[1] >= 720/20) {
          headLoc[1]--;
          pixels.get(headLoc[0]).get(headLoc[1]).changeStatus(head);
          lost = true;
          calcFit();
          return;
        }
        pixels.get(headLoc[0]).get(headLoc[1]).changeStatus(head);
      } else if (dir == 3) { //Left
        pixels.get(headLoc[0]).get(headLoc[1]).changeStatus(empty);
        headLoc[0]--;
        if (headLoc[0] < 0) {
          headLoc[0]++;
          pixels.get(headLoc[0]).get(headLoc[1]).changeStatus(head);
          lost = true;
          calcFit();
          return;
        }
        pixels.get(headLoc[0]).get(headLoc[1]).changeStatus(head);
      }      

      //-----------------------------------------------------------------

      if (tail.size() >= 1) {
        for (int i = 0; i < tail.size(); i++) {
          if (pixels.get(tail.get(i)[0]).get(tail.get(i)[1]).status[0] != 1) {
            pixels.get(tail.get(i)[0]).get(tail.get(i)[1]).changeStatus(empty);
          }
        }

        tail.remove(tail.size() - 1);

        for (int i = 0; i < tail.size(); i++) {
          pixels.get(tail.get(i)[0]).get(tail.get(i)[1]).changeStatus(body);
        }

        for (int i = 0; i < tail.size(); i++) {
          if (headLoc[0] == tail.get(i)[0] && headLoc[1] == tail.get(i)[1]) {
            pixels.get(headLoc[0]).get(headLoc[1]).changeStatus(head);
            lost = true;
            calcFit();
            return;
          }
        }
      }

      //-----------------------------------------------------------------

      if (headLoc[0] == foodLoc[0] && headLoc[1] == foodLoc[1]) {
        snakeLength++;
        pixels.get(foodLoc[0]).get(foodLoc[1]).changeStatus(head);
        boolean flag = false;
        while (true) {
          foodLoc[0] = int(random(1280/20));
          foodLoc[1] = int(random(720/20));
          if (foodLoc[0] == headLoc[0] && foodLoc[1] == headLoc[1]) {
            flag = true;
          }
          for (int i = 0; i < tail.size(); i++) {
            if (foodLoc[0] == tail.get(i)[0] && foodLoc[1] == tail.get(i)[1]) {
              flag = true;
            }
          }
          if (!flag) {
            break;
          }
          flag = false;
        }
        pixels.get(foodLoc[0]).get(foodLoc[1]).changeStatus(food);
        tail.add(headLoc);
        speeds.add(float(timeSinceLastFood));
        inLoops += 75 * ceil((float)snakeLength/25);
        timeSinceLastFood = 0;
      }

      //-----------------------------------------------------------------

      inLoops--;
      lifetime++;
      timeSinceLastFood++;

      if (inLoops <= 0) {
        lost = true;
        speeds.add((float)timeSinceLastFood);
        calcFit();
      }

      float distance = sqrt(sq(foodLoc[0] - headLoc[0]) + sq(foodLoc[1] - headLoc[1]));

      if (distance < pastDistance) {
        fit *= 1.2;
      } else {
        fit /= 1.25;
      }

      pastDistance = distance;

      return;
    }
  }

  void calcFit() { //THIS IS JUST TO HELP ME NOTICE THAT THIS IS THE FITNESS FUNCTION WHEN I'M PLAYING AROUND WITH IT
    float f;
    if (snakeLength > 25) {
      f = pow(lifetime, 2.5);
    } else if (snakeLength > 1) {
      f = pow(1.4, snakeLength) * pow(lifetime, 1.6) / average(speeds);
    } else {
      f = pow(fit, 2) * pow(inLoops, -1/4);
    }
    fitness = f;
  }

  float average(ArrayList<Float> x) {
    float sum = 0;
    for (int i = 0; i < x.size(); i++) {
      sum += x.get(i);
    }
    sum /= x.size();
    return sum;
  }

  float[] getData() { //current size = 3721 + 14
    float[] data = new float[layerStructure[0]];
    int count = 0;

    if (!useFullScreenVector) {
      float[] radar = useBiggerRadar ? biggerRadar(radarDistance) : radar(radarDistance); 
      //0 n, 1 ne, 2 e, 3 se, 4 s, 5 sw, 6 w, 7 nw


      if (dir == 1) {
        radar = rotateRadar(radar);
      } else if (dir == 2) {
        radar = rotateRadar(radar);
        radar = rotateRadar(radar);
      } else if (dir == 3) {
        radar = rotateRadar(radar);
        radar = rotateRadar(radar);
        radar = rotateRadar(radar);
      }

      for (int i = 0; i < radar.length; i++, count++) {
        data[count] = radar[i];
      }

      float[] foodData = foodData();
      for (int i = 0; i < foodData.length; i++, count++) {
        data[count] = foodData[i];
      }
    } else {
      float[] radar = fullScreenRadar();
      for (int i = 0; i < radar.length; i++, count++) {
        data[count] = radar[i];
      }
    } 
    //println();

    //for (int i = 0; i < 8; i++) {
    //  print("Direction: " + i + "... ");
    //  for (int j = 0; j < 3; j++) {
    //    print(data[i*3+j] + " ");
    //  }
    //  println();
    //}

    //print("Food Data... ");

    //for (int i = 0; i < 4; i++) {
    //  print(data[24+i] + " ");
    //}

    //println();

    //Probably could have easily compressed this into a single function, but couldn't be bothered

    //println("Dir Data... ");

    float[] dirData = dirVector();
    for (int i = 0; i < dirData.length; i++, count++) {
      data[count] = dirData[i];
      //print(data[count] + " ");
    }

    ////println();

    float[] pastDirData = pastDirVector();
    for (int i = 0; i < pastDirData.length; i++, count++) {
      data[count] = pastDirData[i];
      //print(data[count] + " ");
    }

    ////println();

    float[] pastPastDirData = pastPastDirVector();
    for (int i = 0; i < pastPastDirData.length; i++, count++) {
      data[count] = pastPastDirData[i];
      //print(data[count] + " ");
    }

    ////println();

    float[] pastPastPastDirData = pastPastPastDirVector();
    for (int i = 0; i < pastPastPastDirData.length; i++, count++) {
      data[count] = pastPastPastDirData[i];
      //print(data[count] + " ");
    }

    ////println();

    float[] currentDir = currentDir();
    for (int i = 0; i < currentDir.length; i++, count++) {
      data[count] = currentDir[i];
      //print(data[count] + " ");
    }

    data[count] = 1;
    return data;
  }

  float[] radar(int radarDistance) {
    float[] data = new float[radarDistance * 4];
    int count = 0;

    for (int j = 1; j <= radarDistance; j++, count++) {
      if (headLoc[1] - j < 0) {
        data[count] = 1;
      } else {
        if (pixels.get(headLoc[0]).get(headLoc[1] - j).status[1] == 1) {
          data[count] = 1;
        } else {
          data[count] = pixels.get(headLoc[0]).get(headLoc[1] - j).status[2] * -1;
          if (!foodInRadar) data[count] = 0;
        }
      }
      //if (headLoc[1] - j < 0 || headLoc[0] + j > 63) {
      //  data[count + radarDistance] = 1;
      //} else {
      //  if (pixels.get(headLoc[0] + j).get(headLoc[1] - j).status[1] == 1) {
      //    data[count + radarDistance] = 1;
      //  } else {
      //    data[count + radarDistance] = pixels.get(headLoc[0] + j).get(headLoc[1] - j).status[2] * -1;
      //    if (!foodInRadar) data[count + radarDistance] = 0;
      //  }
      //}
      if (headLoc[0] + j > 63) {
        data[count + radarDistance] = 1;
      } else {
        if (pixels.get(headLoc[0] + j).get(headLoc[1]).status[1] == 1) {
          data[count + radarDistance] = 1;
        } else {
          data[count + radarDistance] = pixels.get(headLoc[0] + j).get(headLoc[1]).status[2] * -1;
          if (!foodInRadar) data[count + radarDistance] = 0;
        }
      }
      //if (headLoc[0] + j > 63 || headLoc[1] + j > 35) {
      //  data[count + 3 * radarDistance] = 1;
      //} else {
      //  if (pixels.get(headLoc[0] + j).get(headLoc[1] + j).status[1] == 1) {
      //    data[count + 3 * radarDistance] = 1;
      //  } else {
      //    data[count + 3 * radarDistance] = pixels.get(headLoc[0] + j).get(headLoc[1] + j).status[2] * -1;
      //    if (!foodInRadar) data[count + 3 * radarDistance] = 0;
      //  }
      //}
      if (headLoc[1] + j > 35) {
        data[count + 2 * radarDistance] = 1;
      } else {
        if (pixels.get(headLoc[0]).get(headLoc[1] + j).status[1] == 1) {
          data[count + 2 * radarDistance] = 1;
        } else {
          data[count + 2 * radarDistance] = pixels.get(headLoc[0]).get(headLoc[1] + j).status[2] * -1;
          if (!foodInRadar) data[count + 2 * radarDistance] = 0;
        }
      }
      //if (headLoc[1] + j > 35 || headLoc[0] - j < 0) {
      //  data[count + 5 * radarDistance] = 1;
      //} else {
      //  if (pixels.get(headLoc[0] - j).get(headLoc[1] + j).status[1] == 1) {
      //    data[count + 5 * radarDistance] = 1;
      //  } else {
      //    data[count + 5 * radarDistance] = pixels.get(headLoc[0] - j).get(headLoc[1] + j).status[2] * -1;
      //    if (!foodInRadar) data[count + 5 * radarDistance] = 0;
      //  }
      //}
      if (headLoc[0] - j < 0) {
        data[count + 3 * radarDistance] = 1;
      } else {
        if (pixels.get(headLoc[0] - j).get(headLoc[1]).status[1] == 1) {
          data[count + 3 * radarDistance] = 1;
        } else {
          data[count + 3 * radarDistance] = pixels.get(headLoc[0] - j).get(headLoc[1]).status[2] * -1;
          if (!foodInRadar) data[count + 3 * radarDistance] = 0;
        }
      }
      //if (headLoc[0] - j < 0 || headLoc[1] - j < 0) {
      //  data[count + 7 * radarDistance] = 1;
      //} else {
      //  if (pixels.get(headLoc[0] - j).get(headLoc[1] - j).status[1] == 1) {
      //    data[count + 7 * radarDistance] = 1;
      //  } else {
      //    data[count + 7 * radarDistance] = pixels.get(headLoc[0] - j).get(headLoc[1] - j).status[2] * -1;
      //    if (!foodInRadar) data[count + 7 * radarDistance] = 0;
      //  }
      //}
    }
    return data;
  }

  float[] biggerRadar(int distance) {
    float[] out = new float[(2 * distance + 1)*(distance+1)];
    for (int i = 0; i < out.length; i++) {
      out[i] = -1;
    }
    int count = 0;
    for (int i = -distance; i <= distance; i++) {
      for (int j = 0; j <= distance; j++, count++) {
        out[count] = (headLoc[0] + i < 0|| headLoc[0] + i > 63 || headLoc[1] + i < 0 || headLoc[1] + i > 35) ? 1 : pixels.get(headLoc[0] + i).get(headLoc[1] + i).status[1];
      }
    }
    return out;
  }

  float[] fullScreenRadar() {
    float[] out = new float[4608];
    int count = 0;
    for (int i = 0; i < pixels.size(); i++) {
      for (int j = 0; j < pixels.get(i).size(); j++) {
        for (int k = 1; k < 3; k++, count++) {
          out[count] = pixels.get(i).get(j).status[k];
          if (pixels.get(i).get(j).status[0] != 0) {
            out[count] = -1;
          }
        }
      }
    }
    return out;
  }

  float[] foodData() { //{Front, Back, Left, Right}
    float[] data = new float[4];
    for (int i = 0; i < data.length; i++) {
      data[i] = -1;
    }
    if ((dir == 0 && foodLoc[1] <= headLoc[1]) || (dir == 2 && foodLoc[1] >= headLoc[1]) || (dir == 1 && foodLoc[0] >= headLoc[0]) || (dir == 3 && foodLoc[0] <= headLoc[0])) {
      data[0] = 1;
    } 
    if ((dir == 0 && foodLoc[1] >= headLoc[1]) || (dir == 2 && foodLoc[1] <= headLoc[1]) || (dir == 1 && foodLoc[0] <= headLoc[0]) || (dir == 3 && foodLoc[0] >= headLoc[0])) {
      data[1] = 1;
    } 
    if ((dir == 0 && foodLoc[0] < headLoc[0]) || (dir == 2 && foodLoc[0] > headLoc[0]) || (dir == 1 && foodLoc[1] < headLoc[1]) || (dir == 3 && foodLoc[1] > headLoc[1])) {
      data[2] = 1;
    } 
    if ((dir == 0 && foodLoc[0] > headLoc[0]) || (dir == 2 && foodLoc[0] < headLoc[0]) || (dir == 1 && foodLoc[1] > headLoc[1]) || (dir == 3 && foodLoc[1] < headLoc[1])) {
      data[3] = 1;
    }
    return data;
  }

  float[] dirVector() {
    float[] out = new float[3];
    for (int i = 0; i < out.length; i++) {
      out[i] = -1;
    }
    out[turn + 1] = 1;
    return out;
  }

  float[] pastDirVector() {
    float[] out = new float[3];
    for (int i = 0; i < out.length; i++) {
      out[i] = -1;
    }
    out[past[0] + 1] = 1;
    return out;
  }

  float[] pastPastDirVector() {
    float[] out = new float[3];
    for (int i = 0; i < out.length; i++) {
      out[i] = -1;
    }
    out[past[1] + 1] = 1;
    return out;
  }

  float[] pastPastPastDirVector() {
    float[] out = new float[3];
    for (int i = 0; i < out.length; i++) {
      out[i] = -1;
    }
    out[past[2] + 1] = 1;
    return out;
  }

  float[] currentDir() {
    float[] out = new float[4];
    for (int i = 0; i < out.length; i++) {
      out[i] = 0;
    }
    out[dir] = 1;
    return out;
  }

  float[] rotateRadar(float[] x) { //Rotate Right
    int y = x.length / 4;
    float[] z = new float[x.length];
    for (int i = 0; i < x.length; i++) {
      int pos = i+y;
      if (pos >= z.length) {
        pos -= z.length;
      }
      z[pos] = x[i];
    }
    return z;
  }
}
