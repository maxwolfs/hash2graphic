import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import java.nio.charset.StandardCharsets; 
import java.security.MessageDigest; 
import java.security.NoSuchAlgorithmException; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class hash2graphic extends PApplet {

/*
hash2graphic 

The seed, the starting point is transformed by the SHA-512 algorithm into a hash.
As the seed is for easier use an incrementing integer starting with 0, 
it must be converted to a string in order to be processed by the hashing algorithm.

Three transformations are applied to receive 
*/

// import the library for the UI controls
 

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
int[][] colors = {
{0xffffcbf2,0xfff3c4fb,0xffecbcfd,0xffe5b3fe,0xffe2afff,0xffdeaaff,0xffd8bbff,0xffd0d1ff,0xffc8e7ff,0xffc0fdff}, // vaporspace
{0xff05668d,0xff028090,0xff00a896,0xff02c39a,0xfff0f3bd,0xff05668d,0xff028090,0xff00a896,0xff02c39a,0xfff0f3bd}, // blueish-greens
{0xfff94144,0xfff3722c,0xfff8961e,0xfff9844a,0xfff9c74f,0xff90be6d,0xff43aa8b,0xff4d908e,0xff577590,0xff277da1}, // gedeckter grundstock
{0xffeddcd2,0xfffff1e6,0xfffde2e4,0xfffad2e1,0xffc5dedd,0xffdbe7e4,0xfff0efeb,0xffd6e2e9,0xffbcd4e6,0xff99c1de}, // pasetel tones
{0xff7400b8,0xff6930c3,0xff5e60ce,0xff5390d9,0xff4ea8de,0xff48bfe3,0xff56cfe1,0xff64dfdf,0xff72efdd,0xff80ffdb}, // blue-violettes
{0xff9b5de5,0xfff15bb5,0xfffee440,0xff00bbf9,0xff00f5d4,0xff9b5de5,0xfff15bb5,0xfffee440,0xff00bbf9,0xff00f5d4} // bunt
}; 

public void setup() {

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
   
  //fullScreen();
  //noCursor();
  frameRate(30);
  //noLoop();
  // create the first hash out of the initial seed
  regenerate();
}

public void draw() {
  background(colors[0][0]); 
  // make the framerate variable and controllable with the UI slider
  frameRate(speed);

  // transform the seed into a hash via the SHA512 Algorithm
  hash = sha512(str(seed));
  
  // pick the colors for the graphics via the getColors and the generated hash as input
  int[] colors = getColors(hash);

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
public void keyReleased() {
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
public void regenerate () {
  hash = sha512(str(seed));
  }

// takes the output of the applied transformations and creates rects per element
public void showState(int[][] state, int[] colors) {
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
public int[] getColors(String hash) {
  int colorCount = hash.chars().sum() % 7 + 1;
  int colorRange = hash.chars().sum() % 98;
  int indexJump = hash.chars().sum() % 2 + 1;

  int length = min(colorCount, colors[colorPalette].length);
  length = max(3, colorCount);

  int start = floor(PApplet.parseFloat(colors[colorPalette].length) * PApplet.parseFloat(colorRange) / 99.0f);

  int[] trimmedColors = new int[length];

  for (int i = 0; i < length; i++) {
    int copyIndex = (start + i * indexJump) % colors.length;
    trimmedColors[i] = colors[colorPalette][copyIndex];
  }
  return trimmedColors;
}

// transformation1 takes the hash and the selected colors from the chosen palette
// and disassembles the hash into list to get a color for each position
// then creates depending on resolution the elements with corresponding color

public int[] transformation1(String hash, int[] colors) {
  // Amount of rectangles being produced for the final graphics
  ArrayList<Integer> convertedCharacters = new ArrayList();

  for (int i = 0; i < hash.length(); i++) {
    int position = PApplet.parseInt(hash.charAt(i));

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

public int[][] transformation2(int[] state) {

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

public int[][] transformation3(int[][] state, int neighborhoods) {
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
  public void settings() {  size(800, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "hash2graphic" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
