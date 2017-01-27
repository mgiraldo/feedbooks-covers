//import peasy.*;
import processing.pdf.*;

//PeasyCam cam;

boolean record;
boolean refresh = false;
boolean drew = false;
boolean outline = true;
boolean text_shadow_on = false;

JSONArray books;
JSONObject book;
int current_book = 0;

int timer = 0;
int refresh_rate = 1;

float cover_width = 700.0;
float cover_height = 1050.0;
float ratio = cover_height / cover_width;
float x_ini = 10;
float y_ini = 10;
float depth_multiplier = 12;
float letter_size = cover_width / 20.0;
float line_height = letter_size * 2.0;
int rotation_factor = 4;
float margin = 20;

String title;
String author;
boolean is_fiction = false;
boolean is_english = false;
float hue, saturation, brightness;

PGraphics pg;
PFont title_font_sans, author_font_sans, title_font_serif, author_font_serif;
int title_size = 55;
int title_leading = title_size + 5;
int author_size = 45;
int author_leading = author_size + 5;

void setup() {
  size(700, 1050, P3D);
  textMode(SHAPE);
  books = loadJSONArray("feedbooks.json");
  println("loaded", books.size(), "books");
  getBook();
  String[] fontList = PFont.list();
  printArray(fontList);
  pg = createGraphics(width, height, P3D);
  title_font_sans = createFont("AvenirNext-Bold", title_size);
  author_font_sans = createFont("AvenirNext-Regular", author_size);
  title_font_serif = createFont("Superclarendon-Black", title_size);
  author_font_serif = createFont("Superclarendon-Light", author_size);
  //cam = new PeasyCam(this, width * .5, height * .5, 0, 1000);
  //cam.setMinimumDistance(50);
  //cam.setMaximumDistance(50000);
}

void draw() {
  //if (record) {
  //  pg.beginRaw(PDF, "output.pdf");
  //}
  
  colorMode(RGB, 255, 255, 255);
  background(255);

  getBook();

  drawBook();

  if (refresh && millis() > timer + refresh_rate) {
    timer = millis();
    nextBook();
  }

  if (record) {
    //endRaw();
    String urn = getColumnValue("urn");
    String id = urn.substring(30);
    id = id.replace(".epub","");
    saveFrame("output/" + id + ".png");
    //record = false;
  }
}

void drawBook() {
  float author_value = getColumnValue("author").length();
  float title_value = getColumnValue("title").length();
  float category_value = getColumnAsNumber("category");
  String lang = getColumnValue("language");
  is_english = (lang.equals("eng"));
  String type = getColumnValue("type");
  is_fiction = (type.equals("fiction"));
  int type_amount = is_fiction ? 25 : 0;

  if (title_value > 40) title_value = 40;
  title_value = map(title_value, 8, 40, 0, 100);

  if (author_value > 30) author_value = 30;
  author_value = map(author_value, 10, 30, 0, 100);

  hue = title_value + author_value;
  saturation = 75 + type_amount;
  brightness = 50 + (category_value * 0.30);

  pg.beginDraw();
  pg.hint(DISABLE_DEPTH_TEST);
  pg.colorMode(HSB, 200, 100, 100);
  if (is_english) {
    pg.background(hue, saturation, brightness, 10);
  } else {
    pg.background(hue, saturation, brightness);
  }
  pg.noStroke();

  float center_x = cover_width * 0.5, center_y = cover_height * 0.25, center_z = 0.0;
  float eye_x = 0.0, eye_y = 0.0, eye_z = 0.0;
  float up_x = 0.0, up_y = 0.0, up_z = 0.0;

  eye_x = center_x;
  eye_y = map(title_value, 0, 100, 600, 1000);
  eye_z = map(title_value + author_value, 0, 200, 0, 600);

  if (title_value + author_value < 60) {
    eye_x = title_value + author_value;
    center_x = title_value + author_value;
  }
  //if (author_value > 75) up_x = 1.0;
  //if (title_value > 50) up_y = 1.0;
  //if (author_value + title_value < 50) up_z = 1.0;
  if (is_fiction) {
    up_x = 1.0;
  } else {
    up_z = -1.0;
  }

  if (!drew) {
    println();
    println(current_book, title, author);
    println("hsb:", hue, saturation, brightness);
    println("txt:", author_value, title_value, category_value, lang, type);
    println("num:", eye_x, eye_y, eye_z, center_x, center_y, center_z);
    println("up :", up_x, up_y, up_z);
    drew = true;
  }

  // draw sentences
  //pg.lights();
  float title_height = drawSentence(title);
  drawSentence(author, x_ini, y_ini + title_height + line_height);
  // end draw
  pg.colorMode(HSB, 200, 100, 100);
  if (is_english) {
    pg.fill(hue, saturation, brightness, 50);
  } else {
    pg.fill(0, 0, 100, 50);
  }

  // white border rect
  if (outline) {
    pg.pushMatrix();
    pg.translate(0, 0, -100);
    if (is_english) {
      pg.rect(0, 0, cover_width, cover_height);
    } else {
      pg.ellipseMode(CENTER);
      pg.ellipse(cover_width * .5, cover_height * .5, cover_height, cover_height);
    }
    pg.popMatrix();
  }
  // end white border rect

  pg.beginCamera();
  pg.camera(eye_x, eye_y, eye_z, center_x, center_y, center_z, up_x, up_y, up_z);
  pg.endCamera();

  pg.endDraw();
  image(pg, 0, 0);
  
  // text stuff
  pushMatrix();
  float text_width;
  if (is_fiction) {
    textAlign(LEFT);
    text_width = width * .80;
    //translate(width * .35 - margin * 2, 0);
  } else {
    textAlign(CENTER);
    text_width = width - margin * 6;
    translate(margin * 2, 0);
  }

  colorMode(HSB, 200, 100, 100);
  if (is_english) {
    fill(hue, saturation, brightness, 25);
  } else {
    fill(0, 0, 100, 25);
  }

  if (text_shadow_on) {
    pushMatrix();
    translate(-10, 0);
    if (is_fiction) {
      textFont(title_font_serif);
    } else {
      textFont(title_font_sans);
    }
    textLeading(title_leading);
    text(title, margin, margin, text_width, (height - margin * 2) * .4);
    if (is_fiction) {
      textFont(author_font_serif);
    } else {
      textFont(author_font_sans);
    }
    textLeading(author_leading);
    text(author, margin, height * .5, text_width, (height - margin * 2) * .4);
    popMatrix();
  
    pushMatrix();
    translate(10, 0);
    if (is_fiction) {
      textFont(title_font_serif);
    } else {
      textFont(title_font_sans);
    }
    textLeading(title_leading);
    text(title, margin, margin, text_width, (height - margin * 2) * .4);
    if (is_fiction) {
      textFont(author_font_serif);
    } else {
      textFont(author_font_sans);
    }
    textLeading(author_leading);
    text(author, margin, height * .5, text_width, (height - margin * 2) * .4);
    popMatrix();
  }

  if (is_english) {
    fill(hue, saturation, brightness);
  } else {
    fill(200);
  }
  if (is_fiction) {
    textFont(title_font_serif);
  } else {
    textFont(title_font_sans);
  }
  textLeading(title_leading);
  text(title, margin, margin, text_width, (height - margin * 2) * .4);
  if (is_fiction) {
    textFont(author_font_serif);
  } else {
    textFont(author_font_sans);
  }
  textLeading(author_leading);
  text(author, margin, height * .5, text_width, (height - margin * 2) * .4);

  popMatrix();
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
    sentence = sentence.replaceAll("  ", " ");
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
    float rotation = float(word_length * rotation_factor);// * (360.0 / float(rotation_factor));
    if (word_length % 2 == 0) rotation = -rotation;
    z = word_length * depth_multiplier;
    if (i % 2 == 0) {
      z = -z;
    }
    if (x + word_width > cover_width) {
      x = start_x;
      y = y + line_height * 2;
      sentence_height = sentence_height + line_height * 3;
    }
    pg.pushMatrix();
    pg.translate(x, y, -z);
    pg.rotateY(radians(rotation));
    pg.pushMatrix();
    //rotateZ(radians(first_letter % 180));
    pg.popMatrix();
    //colorMode(RGB, 360, 360, 360);
    if (is_english) {
      pg.fill(hue, saturation, brightness, 75);
      pg.rect(0, 0, word_width, line_height);
    } else {
      pg.fill(0, 0, 100, 75);
      pg.ellipseMode(CORNER);
      pg.ellipse(0, 0, word_width, word_width);
    }
    pg.popMatrix();
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
  if (key == 'r' || key == 's') {
    record = !record;
  }
  if (key == 'a' || key == ' ') {
    refresh = !refresh;
  }
  if (key == 'o') {
    outline = !outline;
  }
}