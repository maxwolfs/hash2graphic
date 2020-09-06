/*
hash2graphic 

Three transformations are applied to receive an array with elements and corresponding 
colors.


*/

// import the library for the UI controls
import controlP5.*; 

// create the instance 
ControlP5 cp5; 
// ...and Slider object
Slider abc;

// UI control parameters
// jitter controls the multiplier modulo for transformation that differs in pattern space
int jitter = 50; 
// speed controls the framerate, between high (=immersive gazing) and low (=choose favourite frames)
int speed = 8;
// controls the selection of specific array of tuned colors
int colorPalette = 0;
// multiplier for the amount of rects being produced
int resolution = 100;


// starting input for the hashing algorithm
int seed = 0; 
// the generated hash by the SHA-512 algorithm
String hash;
// multiplier for the animation
int multiplier;

// Array of Color Spaces that are tuned to fit well for each one
color[][] colors = {
{#ffcbf2,#f3c4fb,#ecbcfd,#e5b3fe,#e2afff,#deaaff,#d8bbff,#d0d1ff,#c8e7ff,#c0fdff}, // vaporspace
{#05668d,#028090,#00a896,#02c39a,#f0f3bd,#05668d,#028090,#00a896,#02c39a,#f0f3bd}, // blueish-greens
{#f94144,#f3722c,#f8961e,#f9844a,#f9c74f,#90be6d,#43aa8b,#4d908e,#577590,#277da1}, // gedeckter grundstock
{#eddcd2,#fff1e6,#fde2e4,#fad2e1,#c5dedd,#dbe7e4,#f0efeb,#d6e2e9,#bcd4e6,#99c1de}, // pasetel tones
{#7400b8,#6930c3,#5e60ce,#5390d9,#4ea8de,#48bfe3,#56cfe1,#64dfdf,#72efdd,#80ffdb}, // blue-violettes
{#9b5de5,#f15bb5,#fee440,#00bbf9,#00f5d4,#9b5de5,#f15bb5,#fee440,#00bbf9,#00f5d4} // bunt
}; 

void setup() {

  // UI Control Configuration
  // In total four sliders to control the output parameters
  cp5 = new ControlP5(this);

    cp5.addSlider("resolution")
    .setPosition(50,25)
    .setRange(1,100)
  ;

  cp5.addSlider("jitter")
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

  cp5.addSlider("colorPalette")
    .setPosition(50,125)
    .setRange(0,5)
  ;

  // After lot of iterations I prefer for output images classic squares
  // for exhibitions, large screens and projectors fullscreen a more immersive experience
  size(800, 800); 
  //fullScreen();
  //noCursor();
  frameRate(30);
  //noLoop();
  // create the first hash out of the initial seed
  regenerate();
}

void draw() {
  background(colors[0][0]); 
  // make the framerate variable and controllable with the UI slider
  frameRate(speed);

  // transform the seed into a hash via the SHA512 Algorithm
  hash = sha512(str(seed));
  
  // pick the colors for the graphics via the getColors and the generated hash as input
  color[] colors = getColors(hash);

  // apply transformations to the rect elements that create the final graphics with colors
  int[] transformation1 = transformation1(hash, colors);
  int[][] transformation2 = transformation2(transformation1);

  for (int i = 0; i < jitter % 1000; i++) {
    // for animation mode that automates the resolution randomly uncomment the following line
    // resolution = floor(random(i,100));

    transformation2 = transformation3(transformation2, colors.length);
  }

  // display the final two dimensional array with the 
  showState(transformation2, colors);
}

// If noLoop() mode is on, manual control for changing seeds via keyboard and save images
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

// function called for generating new hash from given seed
void regenerate () {
  hash = sha512(str(seed));
  }

// takes the output of the applied transformations and creates rects per element
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

// takes the hash and outputs the trimmed colors from the palette
color[] getColors(String hash) {
  int colorCount = hash.chars().sum() % 7 + 1;
  int colorRange = hash.chars().sum() % 98;
  int indexJump = hash.chars().sum() % 2 + 1;

  int length = min(colorCount, colors[colorPalette].length);
  length = max(3, colorCount);

  int start = floor(float(colors[colorPalette].length) * float(colorRange) / 99.0);

  color[] trimmedColors = new color[length];

  for (int i = 0; i < length; i++) {
    int copyIndex = (start + i * indexJump) % colors.length;
    trimmedColors[i] = colors[colorPalette][copyIndex];
  }
  return trimmedColors;
}

// transformation1 takes the hash and the selected colors from the chosen palette
// and disassembles the hash into list to get a color for each position
// then creates depending on resolution the elements with corresponding color

int[] transformation1(String hash, color[] colors) {
  // Amount of rectangles being produced for the final graphics
  ArrayList<Integer> convertedCharacters = new ArrayList();

  for (int i = 0; i < hash.length(); i++) {
    int position = int(hash.charAt(i));

    // Converting ASCII DEC values to useful values
    if (position >= 48 && position <= 57) {
      position -= 48;
    } else {
      position -= 55;
    }

    // get the color for each position depending on modulo of total colors
    int colorIndex = position % colors.length;

    // create the amount of elements regarding to resolution  
    // corresponds to (1 -> 64, 2 -> 127, 10 -> 631, ...)
    // and add the specific color to each element
    if (i > 0) {    
      for (int j = 0; j < resolution; j++) {
        convertedCharacters.add(colorIndex);
      }
    } else {
      convertedCharacters.add(colorIndex);
    }
  }

  // convert the array list to an int array graphics that can be visualised
  int[] graphics = new int[convertedCharacters.size()];
  for (int i = 0; i < convertedCharacters.size(); i++) {
    graphics[i] = convertedCharacters.get(i);
  }
  return graphics;
}

// Algorithm to get the maximum size of n squares that fit into a rectangle with a given width and height
// which is relevant if the resolution changes
// https://math.stackexchange.com/a/2570649

int[][] transformation2(int[] state) {

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

// transformation3 converts neighboring elements to different state and creating jitter
// to enhance the graphics into less barcode and more spatial results 

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

// SHA-512 Algorithm from 
// https://stackoverflow.com/questions/33085493/how-to-hash-a-password-with-sha-512-in-java

import java.nio.charset.StandardCharsets; 
import java.security.MessageDigest; 
import java.security.NoSuchAlgorithmException; 

public String sha512(String passwordToHash) {
  String salt = "";
  String generatedPassword = null; 

  try {
    MessageDigest md = MessageDigest.getInstance("SHA-512"); 
    md.update(salt.getBytes(StandardCharsets.UTF_8)); 

    // digest() method is called 
    // to calculate message digest of the input string 
    // returned as array of byte 
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
