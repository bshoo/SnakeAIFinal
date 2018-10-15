class genome {
  game g;
  float[] DNA;

  genome(int x, int y) {
    g = new game(x, y);
  }

  void initialize(float[] x) {
    DNA = x;
  }

  void updateGame() {
    if (g.lost == false) {
      g.changeDir(chooseDirection(g.getData()));
      g.playGame();
    }
  }

  int chooseDirection(float[] inputs) {
    float[] out = output(inputs, layerStructure.length - 1);
    int dir = 0;
    float record = -1;
    for (int i = 0; i < out.length; i++) {
      if (out[i] > record) {
        record = out[i];
        dir = i-1;
      }
    }
    return dir;
  }

  float[] output(float[] inputs, int layerNum) { //Layer by layer (don't think this works)
    if (layerNum == 0) { //Input layer
      return inputs;
    }
    int DNAToSkip = totalConnections(layerNum - 1); //Outputs 0 on layer 1
    float[] outputs = new float[layerStructure[layerNum]];
    float[] in = output(inputs, layerNum - 1);

    int iCap = 0;

    if (layerNum == layerStructure.length - 1) {
      iCap = outputs.length;
    } else {
      iCap = outputs.length - 1;
    }

    if (layerNum != layerStructure.length - 1) { //SUPER HIGH CHANCE I BROKE SOMETHING BY ADDING A THRESHOLD - LOOK OVER THAT
      for (int i = 0; i < iCap; i++) {
        for (int j = 0; j < in.length; j++) {
          outputs[i] += in[j] * DNA[DNAToSkip + i * in.length + j];
        }
        outputs[i] = activation(outputs[i], outputs.length);
      }
    } else {
      for (int i = 0; i < iCap; i++) {
        for (int j = 0; j < in.length; j++) {
          outputs[i] += in[j] * DNA[DNAToSkip + i * in.length + j];
        }
      }
    }

    if (layerNum != layerStructure.length - 1) {
      outputs[outputs.length - 1] = 1; //Bias
    }

    return outputs;
  }

  float[] cloneMyDNA() {
    float[] temp = new float[DNA.length];
    for(int i = 0; i < DNA.length; i++){
      temp[i] = DNA[i];
    }
    return temp;
  }

  float activation(float x, float y) { //tanh
    float partOne = 1 - pow((float)Math.E, float(-4)/y * x);
    float partTwo = 1 + pow((float)Math.E, float(-4)/y * x);
    return partOne/partTwo;
  }

  float sigmoidActivation(float x, float y) {
    return float(1)/(pow((float)Math.E, (-5/y) * x));
  }

  boolean amIDead() {
    return g.lost;
  }

  float fitness() {
    return g.fitness;
  }
}
