import fontastic.*;

Fontastic f;
String inputString = "Hello Pie";
float fontSize;

void setup() {

  size(600, 600);

  createFont();

  fontSize = width/3;

}

void draw() {

  background(255);

  PFont myFont = createFont(f.getTTFfilename(), fontSize);
  PFont defaultFont = createFont("Helvetica", 8);

  fill(0,80);
  textFont(myFont);
  textAlign(CENTER, CENTER);
//  text(inputString, width/2 - fontSize/2, height/2); // works fine, but multiple letters in one word don't show up
  textByChar(inputString, width/2 - fontSize/2, height/2); // better

  fill(0);
  textFont(defaultFont);
  textSize(14);
  text(inputString, width/2, height-20);

}

void textByChar(String text, float x, float y) {
  String[] strings = split(text, ' ');
  float xStart = - (strings.length / 2f) * fontSize / 2;
  for (String s: strings) {

    for (char c: s.toCharArray()) {
      text(c, x + xStart, y);
    }
    xStart += fontSize;
  }
}

void createFont() {

  float charWidth = 1024;

  f = new Fontastic(this, "PieChart");
  f.setAdvanceWidth(0);

  f.addGlyph(' ').setAdvanceWidth(int(charWidth*1.1));

  int i = 0;

  for (char c : Fontastic.alphabet) {

    f.addGlyph(c);
    f.addGlyph(Character.toLowerCase(c));

    // draw pie piece
    PVector[] points = new PVector[9];
    points[0] = new PVector(charWidth/2, charWidth/2); // first point in middle

    PVector[] pointsLc = new PVector[9];
    pointsLc[0] = new PVector(charWidth/2, charWidth/2); // first point in middle

    for (int j=0; j<8; j++) {

      float angle = TWO_PI/(Fontastic.alphabet.length * 1f) * i;
      float angleStep = TWO_PI/(Fontastic.alphabet.length * 1f) / 7f;

      angle += angleStep * j;

      float x = charWidth/2 + sin(angle) * charWidth/2;
      float y = charWidth/2 + cos(angle) * charWidth/2;

      points[j+1] = new PVector(x, y);

      x = charWidth/2 + sin(angle) * charWidth/2 * 0.8;
      y = charWidth/2 + cos(angle) * charWidth/2 * 0.8;

      pointsLc[j+1] = new PVector(x, y);

    }

    f.getGlyph(c).addContour(points);
    f.getGlyph(Character.toLowerCase(c)).addContour(pointsLc);

    i++;
  }


  PVector[] points;

  // Glyph .
  points = new PVector[36];

  for (int j=0; j<points.length; j++) {
    float angle = TWO_PI/points.length * j;
    float x = charWidth/2 + sin(angle) * charWidth/10;
    float y = charWidth/2 + cos(angle) * charWidth/10;

    points[j] = new PVector(x, y);
  }
  f.addGlyph('.').addContour(points);

  // Glyph -
  points = new PVector[18];

  for (int j=0; j<points.length; j++) {
    float angle = HALF_PI + PI/(points.length - 1) * j;

    float x = charWidth/2 + sin(angle) * charWidth/10;
    float y = charWidth/2 + cos(angle) * charWidth/10;

    points[j] = new PVector(x, y);
  }
  f.addGlyph('-').addContour(points);

    // Glyph ,
  points = new PVector[18];

  for (int j=0; j<points.length; j++) {
    float angle =  PI/(points.length - 1) *   j;

    float x = charWidth/2 + sin(angle) * charWidth/10;
    float y = charWidth/2 + cos(angle) * charWidth/10;

    points[j] = new PVector(x, y);
  }
  f.addGlyph(',').addContour(points);

  f.buildFont();

  f.cleanup();

}

void keyPressed() {

  for (int j=0; j<Fontastic.alphabet.length; j++) {
    if (key == Fontastic.alphabet[j]) {
      inputString += Fontastic.alphabet[j];
      break;
    }
  }

  for (int j=0; j<Fontastic.alphabetLc.length; j++) {
    if (key == Fontastic.alphabetLc[j]) { // add to string when lowercase
      inputString += Fontastic.alphabetLc[j];
      break;
    }
  }

  if (key == ESC) {
    inputString = "";
    key = 0;
  }

  if (keyCode == BACKSPACE) {     
    if (inputString.length() > 0) inputString = inputString.substring( 0, inputString.length()-1 );
  }

  if (key == ' ') {
    inputString += ' ';
  }

}

