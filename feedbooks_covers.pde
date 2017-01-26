import peasy.*;
import processing.pdf.*;

PeasyCam cam;

boolean record;
boolean refresh = false;

JSONArray books;
JSONObject book;
int current_book = 0;

int timer = 0;
int refresh_rate = 50;

float cover_width = 400;
float cover_height = 600;
float ratio = cover_height / cover_width;
float x_ini = 10;
float y_ini = 10;
float letter_size = cover_width / 40;
float line_height = letter_size * 2;
float depth_multiplier = 10;

String title;
String author;

void setup() {
  size(1000, 800, P3D);
  textMode(SHAPE);
  books = loadJSONArray("feedbooks.json");
  println("loaded", books.size(), "books");
  getBook();
  cam = new PeasyCam(this, width * .5, height * .5, 0, 1000);
  //cam.setMinimumDistance(50);
  //cam.setMaximumDistance(50000);
  println("ratio", ratio);
  println(".", int("."));
}

void draw() {
  if (record) {
    beginRaw(PDF, "output.pdf");
  }

  getBook();
  
  int author_first = int(author.charAt(0)) % 255;
  int title_first = int(title.charAt(0)) % 255;
  int lang_first = int(book.getString("language").charAt(0)) % 255;

  background(author_first, title_first, lang_first);

  float title_height = drawSentence(title);
  drawSentence(author, x_ini, y_ini + title_height + line_height * 3);
  if (refresh && millis() > timer + refresh_rate) {
    timer = millis();
    nextBook();
  }
  
  // white border rect
  stroke(255);
  noFill();
  rect(0, 0, cover_width, cover_height);
  noStroke();
  fill(255);
  // end white border rect

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
  String[] words = sentence.split(" ");
  float x=start_x, y=start_y, z=0;
  for (int i=0; i < words.length; i++) {
    String word = words[i];
    int word_length = word.length();
    float word_width = letter_size * word_length;
    z = word_length * depth_multiplier;
    pushMatrix();
    translate(0, 0, z);
    if (x + word_width > cover_width) {
      x = start_x;
      y = y + line_height * 2;
      sentence_height = sentence_height + line_height * 2;
    }
    rect(x, y, word_width, line_height);
    x = x + word_width + letter_size;
    popMatrix();
  }
  return sentence_height;
}

void prevBook() {
  current_book--;
  if (current_book < 0) current_book = books.size() - 1;
}

void nextBook() {
  current_book++;
  if (current_book >= books.size()) current_book = 0;
}

void getBook() {
  book = books.getJSONObject(current_book);
  title = book.getString("title");
  author = book.getString("author");
}

// Hit 'r' to record a single frame
void keyPressed() {
  if (keyCode == 39) {
    nextBook();
  }
  if (keyCode == 37) {
    prevBook();
  }
  println(current_book);
  if (key == 'r') {
    record = true;
  }
  if (key == 'a') {
    refresh = !refresh;
  }
}