World world;


void setup() {

  size(1200, 600); 
  background(255);
  world = new World(50);
  world.update();
  world.robotflow.sethead("move()");  // sethead(command)
  world.robotflow.addcondition("isBlocked()", "turnleft()", "turnright()"); //addcondition (condition , true , false)
  world.robotflow.addtruecommand("turnleft()"); // addtruecommand (command)
  world.robotflow.addfalsecommand("turnright()"); // addfalsecommand (command)
  world.robotflow.addendconditioncommand("move()"); // addendconditioncommand (command)
  
  world.robotflow.addcommand("turnleft()");// addcommand (command)
  world.robotflow.addcondition("isBlocked()", "turnleft()", "turnright()");
  world.robotflow.addendconditioncommand("move()");
  
  world.robotflow.addcondition("isBlocked()", "turnleft()", "turnright()");
  world.robotflow.addendconditioncommand("move()");
  
  world.robotflow.addcommand("turnright()");
  world.robotflow.flowprint();
}

void draw() {

  world.runflow();
  world.update();
}


class World {
  Robot robot ;
  Target target ;
  Wall[] walls ;
  int block_size;
  InputProcessor input;

  Flowchart robotflow = new Flowchart();

  World(int block_size ) {
    this.robot = new Robot(5, 5, this);
    this.block_size = block_size;
    this.target = new Target(int(random(0, width/this.block_size)), int(random(0, height/this.block_size)), this);
    this.walls = new Wall[50];
    this.input = new InputProcessor('w', 'a', 'd');


    for (int x = 0; x < walls.length; x += 1) { // create object walls
      walls[x] = new Wall(int(random(0, width/this.block_size)), int(random(0, height/this.block_size)), this);
      if ((walls[x].column == robot.column && walls[x].rown == robot.rown) || (walls[x].column == target.column && walls[x].rown == target.rown)) {
        walls[x] = new Wall(int(random(0, width/this.block_size)), int(random(0, height/this.block_size)), this);
      }
    }
  }

  void runflow() {
    robotflow.runflow();
  }

  void draw () {
    this.robot.draw();
    this.target.draw();
    line(0, 0, width, 0);  // draw world
    for (int x = this.block_size; x < width; x += this.block_size) {
      line(x, 0, x, height);
      line(0, x, width, x);
    }

    for (int i = 0; i < walls.length; i +=1) walls[i].draw(); //draw walls
    stroke(#FF7F50);
    noFill();
    rect(width - this.block_size*2, height - this.block_size, this.block_size*2, this.block_size);
    rect(width - this.block_size*2, height - (this.block_size*2), this.block_size*2, this.block_size);
    stroke(0);
    fill(#FF7F50);
    text("Save", width - this.block_size * 2 + 15, height-10);
    text("Load", width - this.block_size * 2 + 15, height-60);
  }

  void update() {   
    if (robot.column == target.column && robot.rown == target.rown) {  // robot hit target
      target = new Target(int(random(0, width/this.block_size)), int(random(0, height/this.block_size)), this);
      for (int i = 0; i < this.walls.length; i +=1) {
        if ((walls[i].column == target.column && walls[i].rown == target.rown) || robot.column == target.column && robot.rown == target.rown) {
          target = new Target(int(random(0, width/this.block_size)), int(random(0, height/this.block_size)), this);
        }
      }
    }
    input.detect();
    this.draw();
  }

  void save(String save_file) {
    PrintWriter save;
    save = createWriter(save_file);
    save.println("block_size="+this.block_size);
    save.println("robot="+this.robot.column+","+this.robot.rown);
    save.println("target="+target.column+","+target.rown);
    save.println("input_pro="+input.move_key+","+input.turn_left+","+input.turn_right);    
    for (int i = 0; i < this.walls.length; i++) {
      save.println(walls[i].column+","+walls[i].rown);
    }
    save.flush(); // Writes the remaining data to the file
    save.close();
  }

  void load( String load_file ) {
    String[] all_lines = loadStrings(load_file);
    String[] line_1 = split(all_lines[0], '=');
    this.block_size = int(line_1[1]);

    String[] line_2 = split(all_lines[1], '=');
    String[] robot_column_rown = split(line_2[1], ',');
    this.robot = new Robot(int(robot_column_rown[0]), int(robot_column_rown[1]), this);

    String[] line_3 = split(all_lines[2], '=');
    String[] target_column_rown = split(line_3[1], ',');
    this.target = new Target(int(target_column_rown[0]), int(target_column_rown[1]), this);

    String[] line_4 = split(all_lines[3], '=');
    String[] input_data = split(line_4[1], ',');
    this.input = new InputProcessor(input_data[0].charAt(0), input_data[1].charAt(0), input_data[2].charAt(0)); 

    for (int i = 4; i<walls.length+4; i++) {
      String[] wall_column_rown = split(all_lines[i], ',');
      walls[i-4] = new Wall(int(wall_column_rown[0]), int (wall_column_rown[1]), this);
    }
  }
}

class Robot {
  World world;

  int column, rown ;
  char direction ;


  Robot(int column, int rown, World world) {
    this.column = column ;
    this.rown = rown ;
    this.direction = 'w' ;
    this.world = world;
  }

  void draw() {
    float[] point1 = new float[2];
    float[] point2 = new float[2];
    float[] point3 = new float[2];
    float[] point4 = new float[2];
    float[] point5 = new float[2];
    float[] point6 = new float[2];
    float[] point7 = new float[2];
    float[] point8 = new float[2];

    background(255);

    point1[0] = this.column * world.block_size ;
    point1[1] = this.rown * world.block_size ;

    point2[0] = (this.column * world.block_size) + (world.block_size/2);
    point2[1] = (this.rown * world.block_size) ;

    point3[0] = (this.column * world.block_size) + (world.block_size);
    point3[1] = (this.rown * world.block_size);

    point4[0] = (this.column * world.block_size) + (world.block_size);
    point4[1] = (this.rown * world.block_size) + (world.block_size/2) ;

    point5[0] = (this.column * world.block_size) + (world.block_size);
    point5[1] = (this.rown * world.block_size) + (world.block_size);

    point6[0] = (this.column * world.block_size) + (world.block_size/2);
    point6[1] = (this.rown * world.block_size) + (world.block_size);

    point7[0] = (this.column * world.block_size);
    point7[1] = (this.rown * world.block_size) + (world.block_size);

    point8[0] = (this.column * world.block_size);
    point8[1] = (this.rown * world.block_size) + (world.block_size/2);

    if (this.direction == 'w') {
      triangle(point2[0], point2[1], point5[0], point5[1], point7[0], point7[1]);
    } else if (this.direction == 'd') {
      triangle(point1[0], point1[1], point4[0], point4[1], point7[0], point7[1]);
    } else if (this.direction == 's') {
      triangle(point1[0], point1[1], point3[0], point3[1], point6[0], point6[1]);
    } else if (this.direction == 'a') {
      triangle(point8[0], point8[1], point3[0], point3[1], point5[0], point5[1]);
    }
  }

  void move() {
    delay(300);
    if (this.direction == 'w') {
      if (this.isBlocked() == false) this.rown -= 1 ;
    } else if (this.direction == 'd') {
      if (this.isBlocked()== false) this.column += 1;
    } else if (this.direction == 's') {
      if (this.isBlocked()== false) this.rown += 1;
    } else if (this.direction == 'a') {
      if (this.isBlocked()== false)this.column -= 1;
    }
  }

  void right() {
    delay(300);
    if (this.direction == 'w') {
      this.direction ='d';
    } else if (this.direction == 'd') {
      this.direction ='s';
    } else if (this.direction == 's') {
      this.direction ='a';
    } else if (this.direction == 'a') {
      this.direction ='w';
    }
    this.draw();
  }

  void left() {
    delay(300);
    if (this.direction == 'w') {
      this.direction ='a';
    } else if (this.direction == 'a') {
      this.direction ='s';
    } else if (this.direction == 's') {
      this.direction ='d';
    } else if (this.direction == 'd') {
      this.direction ='w';
    }

    this.draw();
  }

  Boolean isBlocked() {

    Boolean check = false ;

    if (this.direction == 'w') {
      for (int i = 0; i < world.walls.length; i += 1) { // check wall at the font
        if (this.rown == 0 || world.walls[i].rown == this.rown - 1 && world.walls[i].column == this.column) check = true;
      }
    } else if (this.direction == 'd') {
      for (int i = 0; i < world.walls.length; i += 1) { // check wall at the right
        if (this.column == width/world.block_size-1 || world.walls[i].rown == this.rown && world.walls[i].column == this.column + 1) check = true;
      }
    } else if (this.direction == 's') {
      for (int i = 0; i < world.walls.length; i += 1) { // check wall at below
        if (this.rown == height/world.block_size-1 || (world.walls[i].rown == this.rown + 1 && world.walls[i].column == this.column)) check = true;
      }
    } else if (this.direction == 'a') {
      for (int i = 0; i < world.walls.length; i += 1) { // check wall at the left
        if (this.column == 0 || world.walls[i].rown == this.rown && world.walls[i].column == this.column - 1) check = true;
      }
    }
    return check ;
  }
}

class Target {
  World world ;
  float column, rown;
  Target(int column, int rown, World world) {
    this.column = column ;
    this.rown = rown;
    this.world = world;
  }

  void draw() {
    fill(0);
    this.polygon(world.block_size/2 + (world.block_size*this.column), world.block_size/2 + (world.block_size*this.rown), world.block_size/2, 6);
  }

  void polygon(float x, float y, float radius, int npoints) {
    float angle = TWO_PI / npoints;
    beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = x + cos(a) * radius;
      float sy = y + sin(a) * radius;
      vertex(sx, sy);
    }
    endShape(CLOSE);
  }
}

class Wall {
  World world;
  float column, rown;

  Wall(int column, int rown, World world) {
    this.column = column;
    this.rown = rown;
    this.world = world;
  }

  void draw() {
    fill(50, 50);
    rect((world.block_size*this.column), (world.block_size*this.rown), world.block_size, world.block_size);
  }
}

class InputProcessor {
  char move_key, turn_left, turn_right;

  InputProcessor(char move_key, char turn_left, char turn_right) {
    this.move_key = move_key;
    this.turn_left = turn_left;
    this.turn_right = turn_right;
  }

  void detect() {
    if (keyPressed) {  // pressed key
      delay(200);
      if (key == this.turn_left) world.robot.left();
      else if (key == this.turn_right) world.robot.right();
      else if (key == this.move_key) world.robot.move();
    }
    if (mousePressed) {
      if (mouseX > width - world.block_size*2 && mouseX < width && mouseY > height - world.block_size && mouseY < height) {
        print("save");
        delay(300);
        world.save("my_world");
      }
      if (mouseX > width - world.block_size*2 && mouseX < width && mouseY > height - (world.block_size*2) && mouseY < height - world.block_size) {
        print("load");
        delay(300);
        world.load("my_world");
      }
    }
  }
}


class Node {
  String data;
  Node nextTrue, nextFalse;

  Node(String data) {
    this.data = data;
    this.nextTrue = null;
    this.nextFalse = null;
  }
}


class Flowchart {
  Node head;
  Node run;
  Node[] nodelist = {};
  String[] nodename = {};
  int amountOfconditions = 0;
  Flowchart() {
    this.head = null;
    run = null;
  }

  void sethead (String command) { // set first command of flowchart
    this.head = new Node (command);
    run = this.head;
  }

  void addcommand(String command) {  // add commamd continue from last commamd and use to end of condition command
    Node commandtemp = new Node (command);
    this.sup_addcommand(this.head, commandtemp);
    run = this.head;
  }

  void sup_addcommand (Node base, Node next) { // sup method for addcommand use recursive
    if (base.nextTrue == null) {
      base.nextTrue = next;
    } else {    
      this.sup_addcommand(base.nextTrue, next);   // recursive until find base.next = null or base.data = "isBlocked()"
    }
  }

  void addcondition (String command, String truecom, String falsecom) { // add condition command continue from last commamd
    Node commandtemp = new Node (command);
    Node truetemp = new Node (truecom);
    Node falsetemp = new Node (falsecom);
    this.sup_addcondition(this.head, commandtemp, truetemp, falsetemp);
    run = this.head;
    amountOfconditions += 1 ;
  }

  void sup_addcondition (Node base, Node condition, Node truecom, Node falsecom) { // sup method for addcondition use recursive
    condition.nextTrue = truecom;
    condition.nextFalse = falsecom;

    if (base.nextTrue == null) {
      base.nextTrue = condition;
    } else {
      this.sup_addcondition(base.nextTrue, condition, truecom, falsecom);
    }
  }
  void addendconditioncommand (String command) {
    Node commandtemp = new Node (command);
    this.sup_addendconditioncommand(this.head, commandtemp);
    run = this.head;
  }
  void sup_addendconditioncommand (Node base, Node next) {
    int checkAmountOfconditions = 0;
    if (base.data == "isBlocked()") {
      checkAmountOfconditions += 1;
    }
    if (base.data == "isBlocked()" && checkAmountOfconditions == amountOfconditions ) {
      this.sup_addendconditioncommand(base.nextTrue, next);
      this.sup_addendconditioncommand(base.nextFalse, next);
      
    } else if (base.nextTrue == null) {
      base.nextTrue = next;
      
    } else {    
      this.sup_addendconditioncommand(base.nextTrue, next);
    }
  }


int getDeepValueTrueWay (Node flow) {
  int i = 0;
  while (flow!= null) {
    i += 1;
    flow = flow.nextTrue;
  }
  return i;
}
int getDeepValueFalseWay (Node flow) {
  int i = 0;
  while (flow!= null) {
    if (flow.data == "isBlocked()") {
      i += 1;
      flow = flow.nextFalse;
    }

    i += 1;
    flow = flow.nextTrue;
  }
  return i;
}
void addtruecommand(String command) { // add truecommamd continue from last truecommamd
  Node commandtemp = new Node (command);
  this.sup_addtrue(this.head, commandtemp);
  run = this.head;
}

void sup_addtrue (Node base, Node next) {  // sup method for addtruecommand use recursive
  if (base.data == "isBlocked()") {
    this.sup_addtrue(base.nextTrue, next);
  } else if (base.nextTrue == null) {
    base.nextTrue = next;
  } else {
    this.sup_addtrue(base.nextTrue, next);
  }
}
void addfalsecommand(String command) { // add falsecommamd continue from last falsecommamd
  Node commandtemp = new Node (command);
  this.sup_addfalse(this.head, commandtemp);
  run = this.head;
}
void sup_addfalse (Node base, Node next) {  // sup method for addfalsecommand use recursive
  if (base.data == "isBlocked()") {
    this.sup_addfalse(base.nextFalse, next);
  } else if (base.nextTrue == null) {
    base.nextTrue = next;
  } else {
    this.sup_addfalse(base.nextTrue, next);
  }
}

void addtruecondition(String command, String truecom, String falsecom) {
  Node commandtemp = new Node (command);
  Node truetemp = new Node (truecom);
  Node falsetemp = new Node (falsecom);
  commandtemp.nextTrue = truetemp;
  commandtemp.nextFalse = falsetemp;
  this.sup_addtrue(this.head, commandtemp);
  run = this.head;
}

void connect (String base, String next, String command) {
  nodename = append(nodename, next);
  int idxbase = arrayIndex(nodename, base);
  int idxnext = arrayIndex(nodename, next);
  Node tempnext = new Node (command);
  nodelist = (Node[]) append(nodelist, tempnext);
  nodelist[idxbase].nextTrue = nodelist[idxnext];
}

void connectFalseWay (String base, String next, String command) {
  nodename = append(nodename, next);
  int idxbase = arrayIndex(nodename, base);
  int idxnext = arrayIndex(nodename, next);
  Node tempnext = new Node (command);
  nodelist = (Node[]) append(nodelist, tempnext);
  nodelist[idxbase].nextFalse = nodelist[idxnext];
}

void flowprint() {

  Node printTrue = this.head;
  Node printFalse = null ; 


  while (printTrue != null) {

    if (printFalse != null) {

      print (printTrue.data + "  ");
      println (printFalse.data);

      if (printTrue.nextTrue  ==  printFalse.nextTrue) {
        printTrue = printTrue.nextTrue;
        printFalse = null;
      } else {
        printTrue = printTrue.nextTrue;
        printFalse = printFalse.nextTrue;
      }
    } else {

      println (printTrue.data);

      if (printTrue.nextFalse != null) {
        printFalse = printTrue.nextFalse;
      }
      printTrue = printTrue.nextTrue;
    }
  }
}

void runflow () {

  while (run!= null) {  
    if (run.data == "move()") {
      world.robot.move();
      run = run.nextTrue;
      break;
    }
    if (run.data == "turnleft()") {
      world.robot.left();
      run = run.nextTrue;
      break;
    }
    if (run.data == "turnright()") {
      world.robot.right();
      run = run.nextTrue;
      break;
    }

    if (run.data == "isBlocked()") {
      if (world.robot.isBlocked()) {
        run = run.nextTrue;
      } else {
        run = run.nextFalse;
      }
    }
  }
  if (run == null) {
    run = this.head;
  }
}
}

int arrayIndex(String[] x, String value) {
  int a = 0;
  for (int i=0; i<x.length; i++) {
    if (x[i]==value) {
      a = i ;
    }
  }
  return (a);
}
