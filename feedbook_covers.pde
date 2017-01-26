import peasy.*;
import processing.pdf.*;

PeasyCam cam;

boolean record;

int cover_width = 400;
int cover_height = 600;
float x_ini = 10;
float y_ini = 10;
float letter_size = 10;
float line_height = 20;
String title = "Le trappeur La Renardière - Au Canada, la tribu des Bois-Brûlés - Voyages, explorations, aventures -";
String author = "Rodrigo Borja, Borgia Alejandro, Alexandre, Alessandro VI";

void setup() {
  size(1000, 800, P3D);
  textMode(SHAPE);
  cam = new PeasyCam(this, width * .5, height * .5, 0, 1000);
  //cam.setMinimumDistance(50);
  //cam.setMaximumDistance(50000);
}

void draw() {
  if (record) {
    beginRaw(PDF, "output.pdf");
  }

  background(0);
  
  // white border rect
  stroke(255);
  noFill();
  rect(0, 0, cover_width, cover_height);
  noStroke();
  fill(255);
  // end white border rect

  float title_height = drawSentence(title);
  
  drawSentence(author, x_ini, y_ini + title_height + line_height);

  if (record) {
    endRaw();
    saveFrame("output.png");
    record = false;
  }
}

float drawSentence(String sentence) {
  return drawSentence(sentence, x_ini, y_ini);
}

float drawSentence(String sentence, float start_x, float start_y) {
  float sentence_height = line_height;
  int[] word_lengths = getWordLengths(sentence);
  float x=start_x, y=start_y;
  for (int i=0; i < word_lengths.length; i++) {
    float word_width = letter_size * word_lengths[i];
    if (x + word_width > cover_width) {
      x = start_x;
      y = y + line_height * 2;
      sentence_height = sentence_height + line_height * 2;
    }
    rect(x, y, word_width, line_height);
    x = x + word_width + letter_size;
  }
  return sentence_height;
}

int[] getWordLengths(String sentence) {
  String[] words = sentence.split(" ");
  int[] lengths = new int[words.length];
  for (int i=0; i < words.length; i++) {
    String word = words[i];
    lengths[i] = word.length();
  }
  return lengths;
}

// Hit 'r' to record a single frame
void keyPressed() {
  if (key == 'r') {
    record = true;
  }
}