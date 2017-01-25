import peasy.*;

PeasyCam cam;

int cover_width = 400;
int cover_height = 600;

void setup() {
  size(1000, 800, P3D);
  cam = new PeasyCam(this, width * .5, height * .5, 0, 1000);
  //cam.setMinimumDistance(50);
  //cam.setMaximumDistance(50000);
}

void draw() {
  background(0);
  color(255);
  rectMode(CENTER);
  rect(width * .5, height * .5, 200, 200);
}