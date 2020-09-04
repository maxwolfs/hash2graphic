/*
The seed, the starting point is transformed by the SHA-512 algorithm into a hash.
As the seed is for easier use an incrementing integer starting with 0, 
it must be converted to a string in order to be processed by the hashing algorithm
*/

import controlP5.*;

ControlP5 cp5;

int multiplierValue = 20;
int speed = 30;
Slider abc;

int seed = 0;
String hash;
int multiplier;
int r = Math.round(random(0, 128));

color[] colors = {
#ffcbf2,#f3c4fb,#ecbcfd,#e5b3fe,#e2afff,#deaaff,#d8bbff,#d0d1ff,#c8e7ff,#c0fdff, // vaporspace
#05668d,#028090,#00a896,#02c39a,#f0f3bd, // blueish-greens
#f94144,#f3722c,#f8961e,#f9844a,#f9c74f,#90be6d,#43aa8b,#4d908e,#577590, #277da1, // gedeckter grundstock
#eddcd2,#fff1e6,#fde2e4,#fad2e1,#c5dedd,#dbe7e4,#f0efeb,#d6e2e9,#bcd4e6,#99c1de, // pasetel tones
#7400b8,#6930c3,#5e60ce,#5390d9,#4ea8de,#48bfe3,#56cfe1,#64dfdf,#72efdd,#80ffdb, // blue-violettes
}; 



void setup() {
  cp5 = new ControlP5(this);
  cp5.addSlider("multiplierValue")
    .setPosition(50,50)
    .setRange(1,100)
  ;

  cp5.addSlider("speed")
    .setPosition(50,75)
    .setRange(1,30)
  ;

    cp5.addSlider("seed")
    .setPosition(50,100)
    .setRange(1,1000)
  ;

  size(800, 800);
  //fullScreen();
  //noCursor();
  frameRate(30);
  //noLoop();
  regenerate();

  
}

void draw() {
  background(colors[0]); 
  frameRate(speed);

  fill(multiplierValue);
  rect(0,0,width,100);

  
  hash = sha512(str(seed));
  
  color[] colors = getColors(hash);

  int[] transformation1 = transformation1(hash, colors);
  int[][] transformation2 = transformation2(transformation1);

  for (int i = 0; i < multiplierValue % 1000; i++) {
  multiplier = floor(random(i,100));
    transformation2 = transformation3(transformation2, colors.length);
    
  }
  showState(transformation2, colors);
  
}

void keyReleased() {
  if (keyCode == LEFT) {
    seed--;
    regenerate();
  }
  if (keyCode == RIGHT) {
    seed++;
    regenerate();
  }
  if (key == ' ') {
    regenerate();
  }
  if (key == 's') {
    saveFrame("export/seed_" + nf(seed, 4) + ".png");
  }
  redraw();
}

void regenerate () {
  hash = sha512(str(seed));
  }

void showState(int[][] state, color[] colors) {
  for (int i = 0; i < state.length; i++) {
    for (int j = 0; j < state[i].length; j++) {
      fill(colors[state[i][j]]);
      noStroke();

      float dx = width / (float) state.length;
      float dy = height / (float) state[i].length;
      float x = dx * i;
      float y = dy * j; 
      rect(floor(x), floor(y), ceil(dx), ceil(dy));
    }
  }
}


color[] getColors(String hash) {
  int colorCount = hash.chars().sum() % 7 + 1;
  int colorRange = hash.chars().sum() % 98;
  int indexJump = hash.chars().sum() % 2 + 1;

  int length = min(colorCount, colors.length);
  length = max(3, colorCount);

  int start = floor(float(colors.length) * float(colorRange) / 99.0);

  color[] trimmedColors = new color[length];

  for (int i = 0; i < length; i++) {
    int copyIndex = (start + i * indexJump) % colors.length;
    trimmedColors[i] = colors[copyIndex];
  }
  return trimmedColors;
}

int[] transformation1(String hash, color[] colors) {
  ArrayList<Integer> convertedCharacters = new ArrayList();
  for (int i = 0; i < hash.length(); i++) {
    int position = int(hash.charAt(i));

    // Converting ASCII DEC values to useful values
    if (position >= 48 && position <= 57) {
      position -= 48;
    } else {
      position -= 55;
    }

    int colorIndex = position % colors.length;

    if (i > 0) {    
      for (int j = 0; j < multiplier; j++) {
        convertedCharacters.add(colorIndex);
      }
    } else {
      convertedCharacters.add(colorIndex);
    }
  }

  int[] graphics = new int[convertedCharacters.size()];
  for (int i = 0; i < convertedCharacters.size(); i++) {
    graphics[i] = convertedCharacters.get(i);
  }
  return graphics;
}

int[][] transformation2(int[] state) {

  // https://math.stackexchange.com/a/2570649
  float ratio = (float) width / height;
  float elementsOnXAxisFloat = sqrt((state.length * ratio));
  int elementsOnXAxis = ceil(elementsOnXAxisFloat);
  int elementsOnYAxis = ceil(state.length / (float) elementsOnXAxis);
  while (elementsOnXAxis < elementsOnYAxis * ratio) {
    elementsOnXAxis++;
    elementsOnYAxis = ceil(state.length / (float) elementsOnXAxis);
  }

  int[][] neighbors = new int[elementsOnXAxis][elementsOnYAxis];
  for (int i = 0; i < elementsOnXAxis; i++) {
    for (int j = 0; j < elementsOnYAxis; j++) {
      if (i * elementsOnYAxis + j < state.length) {
        neighbors[i][j] = state[i * elementsOnYAxis + j];
      } else {
        neighbors[i][j] = 0;
      }
    }
  }

  return neighbors;
}

int[][] transformation3(int[][] state, int neighborhoods) {
  int[][] nextState = new int[state.length][state[0].length];
  for (int i = 0; i < state.length; i++) {
    for (int j = 0; j < state[i].length; j++) {
      if (i > 0 && state[i-1][j] == (state[i][j] + 1) % neighborhoods) {
        nextState[i][j] = state[i-1][j];
      } else if (i < state.length-1 && state[i+1][j] == (state[i][j] + 1) % neighborhoods) {
        nextState[i][j] = state[i+1][j];
      } else {
        nextState[i][j] = state[i][j];
      }
    }
  }

  return nextState;
}

// --- SHA-512

import java.nio.charset.StandardCharsets; 
import java.security.MessageDigest; 
import java.security.NoSuchAlgorithmException; 

public String sha512(String passwordToHash) {
  String salt = "";

  String generatedPassword = null; 
  try {
    MessageDigest md = MessageDigest.getInstance("SHA-512"); 
    md.update(salt.getBytes(StandardCharsets.UTF_8)); 
    byte[] bytes = md.digest(passwordToHash.getBytes(StandardCharsets.UTF_8)); 
    StringBuilder sb = new StringBuilder(); 
    for (int i=0; i< bytes.length; i++) {
      sb.append(Integer.toString((bytes[i] & 0xff) + 0x100, 33).substring(1));
    }
    generatedPassword = sb.toString();
  } 
  catch (NoSuchAlgorithmException e) {
    e.printStackTrace();
  }
  return generatedPassword;
}
