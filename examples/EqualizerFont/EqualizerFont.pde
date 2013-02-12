 /**
 * Fontastic
 * A font file writer for Processing.
 * http://code.andreaskoller.com/libraries/fontastic
 *
 * Example: EqualizerFont
 *
 * How to create characters made out of horizonal lines for each character of the alphabet
 *
 * 
 * @author      Andreas Koller http://andreaskoller.com
 */
 
import fontastic.*;


Fontastic f;


void setup() {

  size(600, 600);
  fill(0);

  createFont();

}


void draw() {

  background(255);

  PFont myFont = createFont(f.getTTFfilename(), 64);

  textFont(myFont);
  textAlign(CENTER, CENTER);
  text(Fontastic.alphabet, 0, Fontastic.alphabet.length/2, width/2, height/5);
  text(Fontastic.alphabet, Fontastic.alphabet.length/2, Fontastic.alphabet.length, width/2, height/5*2);

  text(Fontastic.alphabetLc, 0, Fontastic.alphabet.length/2, width/2, height/5*3);
  text(Fontastic.alphabetLc, Fontastic.alphabet.length/2, Fontastic.alphabet.length, width/2, height/5*4);

  noLoop();

}


void createFont() {

  f = new Fontastic(this, "EqualizerFont");

  f.setAuthor("Andreas Koller");

  int i = 0;

  for (char c : Fontastic.alphabet) {

    f.addGlyph(c);
    f.addGlyph(Character.toLowerCase(c));

    for (int j=0; j<=i; j++) {

      float thickness = 10;    
      float y = map(j, 0, Fontastic.alphabet.length, 0, 1024-thickness);

      PVector[] points = new PVector[4];
      points[0] = new PVector(0, y);
      points[1] = new PVector(500, y);
      points[2] = new PVector(500, y+thickness);
      points[3] = new PVector(0, y+thickness);

      f.getGlyph(c).addContour(points);

      PVector[] pointsLc = new PVector[points.length];
      for (int k=0; k<pointsLc.length; k++) {
        pointsLc[k] = new PVector();
        pointsLc[k].x = points[k].x*0.2;
        pointsLc[k].y = points[k].y;
      }

      f.getGlyph(Character.toLowerCase(c)).addContour(pointsLc);
    }

    i++;

  }

  f.buildFont();

  f.cleanup();
  
}

