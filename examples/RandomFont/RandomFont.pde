 /**
 * Fontastic
 * A font file writer for Processing.
 * http://code.andreaskoller.com/libraries/fontastic
 *
 * Example: RandomFont
 *
 * How to create a random shape for each character of the alphabet.
 * 
 * @author      Andreas Koller http://andreaskoller.com
 */
 
import fontastic.*;


Fontastic f;

int version = 0;


void setup() {

  size(600, 400);
  fill(0);

  createFont(); // create the font

}


void draw() {
  
  background(255);

  PFont myFont = createFont(f.getTTFfilename(), 64); // reading the font that has just been created

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

  f.setAuthor("Andreas Koller");
  f.setVersion("1.0");
  f.setAdvanceWidth(600);
	
  // go through alphabet and create contours for each glyph
  for (char c : Fontastic.alphabet) {
	
	// create a PVector array with 4 random coordinates
    PVector[] points = new PVector[4];
	
    points[0] = new PVector(0, 0);  // lower left corner. y coordinates go up in ttf!
    points[1] = new PVector(random(512), 0);
    points[2] = new PVector(random(512), random(1024));
    points[3] = new PVector(0, random(1024));

    f.addGlyph(c).addContour(points);

    PVector[] pointsLc = new PVector[points.length];
	
	// and to the same for lowercase characters. The contour gets scaled down by 50% in y.
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

