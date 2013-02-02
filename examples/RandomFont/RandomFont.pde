import fontastic.*;

Fontastic f;

int version = 0;


void setup() {

  size(600, 400);
  fill(0);

  createFont();

}


void draw() {
  
  background(255);

  PFont myFont = createFont(f.getTTFfilename(), 64);
  PFont defaultFont = createFont("Helvetica", 8);

  textFont(myFont);
  textAlign(CENTER, CENTER);
  text(Fontastic.alphabet, 0, Fontastic.alphabet.length/2, width/2, height/5);
  text(Fontastic.alphabet, Fontastic.alphabet.length/2, Fontastic.alphabet.length, width/2, height/5*2);

  text(Fontastic.alphabetLc, 0, Fontastic.alphabet.length/2, width/2, height/5*3);
  text(Fontastic.alphabetLc, Fontastic.alphabet.length/2, Fontastic.alphabet.length, width/2, height/5*4);

  noLoop();
 
}

void createFont() {

  version++;

  if (f != null) { f.cleanup(); }

  f = new Fontastic(this, "RandomFont" + nf(version,4));

  // f.setFontFamilyName("RandomFont");
  f.setAuthor("Andreas Koller");
  f.setVersion("1.0");
  f.setAdvanceWidth(600);

  for (char c : Fontastic.alphabet) {

    PVector[] points = new PVector[4];

    points[0] = new PVector(0, 0);
    points[1] = new PVector(random(512), 0);
    points[2] = new PVector(random(512), random(1024));
    points[3] = new PVector(0, random(1024));

    f.addGlyph(c).addContour(points);

    PVector[] pointsLc = new PVector[points.length];

    for (int i=0; i<pointsLc.length; i++) {
      pointsLc[i] = new PVector();
      pointsLc[i].x = points[i].x;
      pointsLc[i].y = points[i].y * 0.5;
    }

    f.addGlyph(Character.toLowerCase(c)).addContour(pointsLc);
  }

  f.buildFont();
  f.cleanup();

}

void keyPressed() {

  if (key == ' ') {
    createFont();
    loop();
  }
  
}

