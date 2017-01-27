//import peasy.*;
import processing.pdf.*;

//PeasyCam cam;

boolean record;
boolean refresh = false;
boolean drew = false;
boolean outline = true;

JSONArray books;
JSONObject book;
int current_book = 0;

int timer = 0;
int refresh_rate = 200;

float cover_width = 700.0;
float cover_height = 1050.0;
float ratio = cover_height / cover_width;
float x_ini = 10;
float y_ini = 10;
float depth_multiplier = 10;
float letter_size = cover_width / 20.0;
float line_height = letter_size * 2.0;
int circle_divisions = 4; // for rotations

String title;
String author;

void setup() {
  size(700, 1050, P3D);
  textMode(SHAPE);
  books = loadJSONArray("feedbooks.json");
  println("loaded", books.size(), "books");
  getBook();
  //cam = new PeasyCam(this, width * .5, height * .5, 0, 1000);
  //cam.setMinimumDistance(50);
  //cam.setMaximumDistance(50000);
}

void draw() {
  if (record) {
    beginRaw(PDF, "output.pdf");
  }

  getBook();
  
  float author_value = getColumnAsNumber("author");
  float title_value = getColumnAsNumber("title");
  float lang_value = getColumnAsNumber("language");
  int type = getColumnValue("type") == "fiction" ? 25 : 0;
  float category_value = getColumnAsNumber("category"); 
  
  float hue = lang_value + title_value + author_value;
  float saturation = 75 + type;
  float brightness = 50 + (category_value % 30);

  colorMode(HSB, 300, 100, 100);
  background(color(hue, saturation, brightness));
  noStroke();

  drawBook();

  if (refresh && millis() > timer + refresh_rate) {
    timer = millis();
    nextBook();
  }
  
  // white border rect
  if (outline) {
    pushMatrix();
    translate(0, 0, -100);
    colorMode(HSB, 100, 100, 100);
    fill(color(0, 0, 100, 75));
    rect(0, 0, cover_width, cover_height);
    fill(color(0, 0, 100));
    popMatrix();
  }
  // end white border rect
  
  if (record) {
    endRaw();
    saveFrame("output.png");
    record = false;
  }
}

void drawBook() {
  float center_x = cover_width * 0.5, center_y = cover_height * 0.25, center_z = 0.0;
  float eye_x = 0.0, eye_y = 0.0, eye_z = 0.0;
  float up_x = 0.0, up_y = 0.0, up_z = 0.0;

  float author_value = getColumnAsNumber("author"); 
  float title_value = getColumnAsNumber("title");
  float genre_value = getColumnAsNumber("category");

  eye_x = center_x;
  eye_y = map(title_value, 0, 100, 600, 1000);
  eye_z = map(title_value + author_value, 0, 200, 300, 600);
  
  if (title_value + author_value < 60) {
    eye_x = title_value + author_value;
    center_x = title_value + author_value;
  }
  //if (author_value > 75) up_x = 1.0;
  //if (title_value > 50) up_y = 1.0;
  //if (author_value + title_value < 50) up_z = 1.0;
  if (genre_value == 0) {
    up_x = 1.0;
  } else {
    up_x = -1.0;
  }
  
  if (!drew) {
    println(current_book, title, author);
    println("txt:", author_value, title_value, genre_value);
    println("num:", eye_x, eye_y, eye_z, center_x, center_y, center_z);
    println("up :", up_x, up_y, up_z);
    drew = true;
  }
  
  // draw sentences
  float title_height = drawSentence(title);
  drawSentence(author, x_ini, y_ini + title_height + line_height);
  // end draw

  beginCamera();
  camera(eye_x, eye_y, eye_z, center_x, center_y, center_z, up_x, up_y, up_z);
  endCamera();
}

float getColumnAsNumber(String column) {
  float value = 0.0;
  String cat = getColumnValue(column);
  for (int i=0; i < cat.length(); i++) {
    value = value + float(cat.charAt(i));
  }
  if (value > 3000) value = 3000;
  value = map(value, 0, 3000, 0, 100);
  return value;
}

String getColumnValue(String column) {
   return book.getString(column);
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
      sentence_height = sentence_height + line_height * 3;
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
  drew = false;
  current_book--;
  if (current_book < 0) current_book = books.size() - 1;
}

void nextBook() {
  drew = false;
  current_book++;
  if (current_book >= books.size()) current_book = 0;
}

void getBook() {
  book = books.getJSONObject(current_book);
  title = getColumnValue("title");
  author = getColumnValue("author");
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
  if (key == 'a' || key == ' ') {
    refresh = !refresh;
  }
  if (key == 'o') {
    outline = !outline;
  }
}