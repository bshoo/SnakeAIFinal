class pixel {
  int xLoc;
  int yLoc;
  int[] status = new int[3];
  int obstacle = 0;
  HashMap<String, Integer> assocVector = new HashMap<String, Integer>();

  pixel(int x, int y) {
    xLoc = x;
    yLoc = y;
    assocVector.put("head", 0);
    assocVector.put("body", 1);
    assocVector.put("food", 2);
  }

  void changeStatus(String x) {
    boolean wasFood = false;
    if(status[2] == 1){
      wasFood = true;
    }
    for (int i = 0; i < status.length; i++) { //Clear array
      status[i] = 0;
    }
    if (x != "empty") {
      status[assocVector.get(x)] = 1;
    }
    if((x == "head" || x == "body") && wasFood == true){
      status[2] = 1;
    }
  }

  int[] getStatus() {
    return status;
  }

  void show() {
    if (!isEmpty()) {
      if (status[0] == 1) {
        fill(150);
      } else if (status[1] == 1) {
        fill(220);
      } else if (status[2] == 1) {
        fill(244, 80, 66);
      }
      rect(20 * xLoc + 1, 20 * yLoc + 1, 18, 18, 2);
    }
  }

  boolean isEmpty() {
    if (status[0] + status[1] + status[2] == 0) {
      return true;
    } else {
      return false;
    }
  }
}
