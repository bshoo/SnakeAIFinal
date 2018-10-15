class generation { //Maybe add tournament selection?
  ArrayList<genome> genomes = new ArrayList<genome>();
  ArrayList<float[]> DNAList = new ArrayList<float[]>();

  generation(ArrayList<float[]> x) {
    DNAList = x;
    //int randX = int(random(2, 1280/20));
    //int randY = int(random(2, 720/20));
    for (int i = 0; i < population; i++) {
      genomes.add(new genome(23, 20));
      genomes.get(i).initialize(x.get(i));
    }
  }

  void playAllGames() {
    for (int i = 0; i < genomes.size(); i++) {
      genomes.get(i).updateGame();
    }
  }

  float getHighestFitness() {
    float record = 0;
    float[] fitnesses = getAllFitnesses();
    for (int i = 0; i < fitnesses.length; i++) {
      if (fitnesses[i] > 0) {
        record = fitnesses[i];
      }
    }
    return record;
  }

  float avgFitness() {
    float fitnessSum = arraySummation(getAllFitnesses());
    return fitnessSum/getAllFitnesses().length;
  }

  float[] getAllFitnesses() {
    float[] fitnesses = new float[genomes.size()];
    for (int i = 0; i < genomes.size(); i++) {
      fitnesses[i] = genomes.get(i).fitness();
    }
    return fitnesses;
  }

  int selectID(float[] x) {
    int[] ids = new int[population/5];
    for (int i = 0; i < ids.length; i++) {
      ids[i] = int(random(x.length));
    }
    float sum = 0;
    for (int i = 0; i < ids.length; i++) {
      sum += x[ids[i]];
    }
    while (true) {
      int randID = int(random(ids.length));
      float randFit = random(sum);
      if (x[ids[randID]] > randFit) {
        return ids[randID];
      }
      println("[-] In the while loop. Debug info - Random ID: " + randID + " Random Fitness: " + randFit + " Fitness of ID: " + x[ids[randID]]);
    }
  }

  generation crossover() { //Save the best of the best
    int itsAKeeper = idOfHighestFitness();
    //println("Highest Fitness: " + itsAKeeper + " " + genomes.get(itsAKeeper).g.fitness + " " + genomes.get(itsAKeeper).g.snakeLength);
    //println("Largest Snake: " + idOfLongestSnake() + " " + genomes.get(idOfLongestSnake()).g.fitness + " " + genomes.get(idOfLongestSnake()).g.snakeLength);
    println("[*] Creating generation " + (currentGen+1));
    ArrayList<float[]> newDNAList = new ArrayList<float[]>();

    newDNAList.add(genomes.get(itsAKeeper).cloneMyDNA());
    println("[*] Created: " + "0");

    float[] tempDNA = genomes.get(itsAKeeper).cloneMyDNA();
    for (int i = 0; i < tempDNA.length; i++) {
      float randomNum = random(1);
      if (randomNum < 0.02) {
        tempDNA[i] = randomGaussian();
      }
    }

    newDNAList.add(tempDNA);
    println("[*] Created: " + "1");

    float[] allFitnesses = getAllFitnesses();

    //float fitnessSum = arraySummation(getAllFitnesses());
    //float cutoff = fitnessSum/float(allFitnesses.length);
    //if (fitnessSum > 0) {
    //  for (int i = 0; i < genomes.size(); i++) { //Kill off the weaklings
    //    if (genomes.get(i).fitness() < cutoff) {
    //      genomes.remove(i);
    //      i--;
    //    }
    //  }
    //}

    //allFitnesses = getAllFitnesses();

    //fitnessSum = arraySummation(getAllFitnesses());

    for (int i = 2; i < population - mutated; i++) {
      println("[*] Creating: " + i);
      int DNAOne = 0;
      int DNATwo = 0;
      float[] newDNA = new float[genomes.get(0).DNA.length];
      println("[*] Empty genome created");

      int swapPoint = (int)random(newDNA.length);

      //float randomFitnessOne = random(fitnessSum);
      //float randomFitnessTwo = random(fitnessSum);

      //float runningSum = 0;

      //outerOne:
      //  for (int j = 0; j < allFitnesses.length; j++) {
      //    runningSum += allFitnesses[j];
      //    if (randomFitnessOne < runningSum) {
      //      DNAOne = j;
      //      break outerOne;
      //    }
      //  }

      //  runningSum = 0;

      //outerTwo:
      //  for (int j = 0; j < allFitnesses.length; j++) {
      //    runningSum += allFitnesses[j];
      //    if (randomFitnessTwo < runningSum) {
      //      DNATwo = j;
      //      break outerTwo;
      //    }
      //  }

      DNAOne = selectID(allFitnesses);
      println("[*] ID selected: " + DNAOne);
      DNATwo = selectID(allFitnesses);
      println("[*] ID selected: " + DNATwo);

      for (int j = 0; j < newDNA.length; j++) {
        if (j < swapPoint) {
          newDNA[j] = genomes.get(DNAOne).DNA[j];
        } else {
          newDNA[j] = genomes.get(DNATwo).DNA[j];
        }

        float mutation = random(1);
        if (mutation < 0.02) {
          newDNA[j] = randomGaussian();
        }
      }

      newDNAList.add(newDNA);
      println("[*] Created: " + i);
    }

    for (int i = 0; i < mutated; i++) {
      float[] newDNA = new float[genomes.get(0).DNA.length];
      for (int j = 0; j < newDNA.length; j++) {
          newDNA[j] = randomGaussian();
      }
      newDNAList.add(newDNA);
      println("[*] Created: " + (population-mutated+i));
    }
    println("[+] Generation " + (currentGen+1) + " created");
    return new generation(newDNAList);
  }

  float arraySummation(float[] x) {
    float sum = 0;
    for (int i = 0; i < x.length; i++) {
      sum += x[i];
    }
    return sum;
  }

  boolean everythingDead() {
    boolean lost = true;
    for (int i = 0; i < genomes.size(); i++) {
      if (genomes.get(i).g.lost == false) {
        lost = false;
      }
    }
    return lost;
  }

  void finishAllGames() {
    for (int i = 0; i < genomes.size(); i++) {
      while (genomes.get(i).g.lost == false) {
        genomes.get(i).updateGame();
      }
    }
  }

  int idOfLongestSnake() {
    int record = 0;
    int id = 0;
    for (int i = 0; i < genomes.size(); i++) {
      if (genomes.get(i).g.snakeLength > record) {
        record = genomes.get(i).g.snakeLength;
        id = i;
      }
    }
    return id;
  }

  int idOfHighestFitness() {
    float record = 0;
    int id = 0;
    for (int i = 0; i < genomes.size(); i++) {
      if (genomes.get(i).g.fitness > record) {
        record = genomes.get(i).g.fitness;
        id = i;
      }
    }
    return id;
  }

  int getLargestLength() {
    int largestLength = 0;
    for (int i = 0; i < genomes.size(); i++) {
      if (genomes.get(i).g.snakeLength > largestLength) {
        largestLength = genomes.get(i).g.snakeLength;
      }
    }
    return largestLength;
  }

  int idOfBiggestestSnake() {
    int largestLength = 0;
    int id = 0;

    for (int i = 0; i < genomes.size(); i++) {
      if (genomes.get(i).g.snakeLength > largestLength) {
        largestLength = genomes.get(i).g.snakeLength;
        id = i;
      }
    }

    return id;
  }
}
