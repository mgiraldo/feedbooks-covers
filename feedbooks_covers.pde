import peasy.*;
import processing.pdf.*;

PeasyCam cam;

boolean record;
boolean refresh = false;

JSONArray books;
JSONObject book;
int current_book = 0;

int timer = 0;
int refresh_rate = 200;

float cover_width = 400.0;
float cover_height = 600.0;
float ratio = cover_height / cover_width;
float x_ini = 10;
float y_ini = 10;
float depth_multiplier = 10;
float letter_size = cover_width / 20.0;
float line_height = letter_size * 3.0;
int circle_divisions = 4; // for rotations

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
  
  int author_first = int(author.charAt(0)) % 30;
  int title_first = int(title.charAt(0)) % 30;
  int lang_first = int(book.getString("language").charAt(0)) % 30;
  int lang_second = int(book.getString("language").charAt(1)) % 30;
  int lang_third = int(book.getString("language").charAt(2)) % 30;
  int type = book.getString("type") == "fiction" ? 50 : 0;
  float category_value = getCategoryValue(); 
  
  float hue = lang_first + author_first + title_first;
  float saturation = 50 + type;
  float brightness = 70 + (category_value % 30);

  colorMode(HSB, 100, 100, 100);
  background(color(hue, saturation, brightness));

  // draw book
  float title_height = drawSentence(title);
  drawSentence(author, x_ini, y_ini + title_height + line_height);
  // end draw book

  if (refresh && millis() > timer + refresh_rate) {
    timer = millis();
    nextBook();
    println(current_book);
  }
  
  // white border rect
  pushMatrix();
  colorMode(HSB, 100, 100, 100);
  stroke(color(0, 0, 100));
  noFill();
  rect(0, 0, cover_width, cover_height);
  noStroke();
  fill(color(0, 0, 100));
  popMatrix();
  // end white border rect

  if (record) {
    endRaw();
    saveFrame("output.png");
    record = false;
  }
}

float getCategoryValue() {
  float value = 0.0;
  String cat = book.getString("category");
  for (int i=0; i < cat.length(); i++) {
    value = value + float(cat.charAt(i));
  }
  value = value % 100;
  return value;
}

float drawSentence(String sentence) {
  return drawSentence(sentence, x_ini, y_ini);
}

float drawSentence(String sentence, float start_x, float start_y) {
  float sentence_height = line_height;
  boolean finished = false;
  int tries = 20;
  while (!finished && tries > 0) {
    // clean sentence from double spaces (screws up split)
    sentence = sentence.replaceAll("  "," ");
    if (!sentence.contains("  ")) {
      finished = true;
    }
    tries--;
  }
  String[] words = sentence.split(" ");
  float x=start_x, y=start_y, z=0;
  for (int i=0; i < words.length; i++) {
    String word = words[i];
    int word_length = word.length();
    float word_width = letter_size * word_length;
    float first_letter = word.charAt(0);
    float rotation = float(i % circle_divisions) * (360.0 / float(circle_divisions));
    z = word_length * depth_multiplier;
    if (i % 2 == 0) {
      z = -z;
    }
    if (x + word_width > cover_width) {
      x = start_x;
      y = y + line_height * 2;
      sentence_height = sentence_height + line_height;
    }
    pushMatrix();
    translate(x, y, -z);
    rotateY(radians(rotation * -1));
    pushMatrix();
    rotateZ(radians(first_letter % 180));
    popMatrix();
    colorMode(RGB, 360, 360, 360);
    fill(color(360 - rotation % 180));
    rect(0, 0, word_width, line_height);
    popMatrix();
    x = x + word_width + letter_size;
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
  if (key == 'r') {
    record = true;
  }
  if (key == 'a') {
    refresh = !refresh;
  }
}