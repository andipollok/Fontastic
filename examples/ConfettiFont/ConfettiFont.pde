/**
 * Fontastic
 * A font file writer for Processing.
 * http://code.andreaskoller.com/libraries/fontastic
 *
 * Example: ConfettiFont
 *
 * How to create characters made of multiple shapes
 * based on outlines of another font.
 * - Press 's' to save ttf and woff files (Might take a while! Be patient.)
 *
 * Based on the example P_3_2_1_01.pde by Generative Gestaltung
 * http://www.generative-gestaltung.de/P_3_2_1_01
 * 
 * @author      Andreas Koller http://andreaskoller.com
 */

import fontastic.*;
import geomerative.*;


Fontastic f;
RFont font;

PFont myFont;

int version = 0;

int charWidth = 512;

boolean fontBuilt = false;


void setup() {

  size(600, 400);
  fill(0);

  // always initialize the library in setup
  RG.init(this);

  // load the initial font
  font = new RFont("FreeSans.ttf",150);

  // get the points on the curve's shape
  // set style and segment resultion
  RCommand.setSegmentLength(10);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  initFont();

  updateFont();

}


void draw() {

  updateFont();

  background(255);

  int numberOfLetters = 10; // the number of letters to display
  for (int i=0; i<numberOfLetters; i++) {
    pushMatrix();
    translate(width/2, height/3);
    scale(charWidth/1000f / 5f);
    translate(-(numberOfLetters -1)*charWidth / 2 + i*charWidth, 0);
    translate(-charWidth/2, charWidth/2);
    noStroke();
    fill(0,128,255);
    renderGlyphSolid(Fontastic.alphabet[i]);
    popMatrix();
  }

  if (fontBuilt) {
    pushMatrix();
    textFont(myFont);
    textAlign(CENTER, CENTER);
    fill(0);
    textSize(charWidth / 5f);
    text(new String(subset(Fontastic.alphabet, 0, numberOfLetters)), width/2, height*0.6);
    popMatrix();
  }
 
}

void initFont() {

  f = new Fontastic(this, "Confetti" + nf(version,4)); // create new Fontastic object

  // add letters to the font, without adding glyph shapes
  for (char c : Fontastic.alphabet) {   
    f.addGlyph(c);                      // add all uppercase letters from the alphabet 
  }

  for (char c : Fontastic.alphabetLc) {
    f.addGlyph(c);                      // add all lowercase letters from the alphabet
  }

//  f.setFontFamilyName("Confetti");  // if font has same name, it won't be loaded twice by Processing during runtime
  f.setAuthor("Andreas Koller");
  f.setVersion("0.1");
  f.setAdvanceWidth(int(charWidth * 1.1));

}

void updateFont() {
  
  for (char c : Fontastic.alphabet) {

    RShape shp = font.toShape(c);
    RPoint[] pnts = shp.getPoints();

    f.getGlyph(c).clearContours();

    for (int i=0; i<pnts.length-1; i++) {

      RPoint p = pnts[i];
      PVector[] points = new PVector[4];

      float circleSize = 20;

      int resolution = 6; // the resolution of a confetti circle
      points = new PVector[resolution];
      for (int j=0; j<resolution; j++) {
        float angle = TWO_PI/(resolution * 1f) * j;
        float x = p.x * 5 + sin(angle) * circleSize;
        float y = -p.y * 5 +  cos(angle) * circleSize;
        x += (mouseX - width/2f) / width/2f * noise(i+millis()/1000f) * 2000;
        y -= (mouseY - height/2f) / height/2f * noise(i * 2+millis()/1000f) * 2000;
        points[j] = new PVector(x, y);
      }

      f.getGlyph(c).addContour(points);

    }
  }

}


void createFont() {

  f.buildFont(); // write ttf file
  f.cleanup();   // delete all glyph files that have been created while building the font
  
  fontBuilt = true;

  myFont = createFont(f.getTTFfilename(), 200); // set the font to be used for rendering

  version++;
  
  initFont();   // and make a new font right away

}


// A function to preview a glyph in Processing

void renderGlyphSolid(char c) {
    
  FContour[] contours = f.getGlyph(c).getContoursArray();

  for (int j=0; j<contours.length; j++) {

    FPoint[] points = f.getGlyph(c).getContour(j).getPointsArray();

    if (points.length > 0) { //just to be sure    
      // Draw the solid shape in Processing
      beginShape();      
      for (int i=0; i<points.length; i++) {
        FPoint p1 = points[i];
        FPoint p2 = points[(i+1)%points.length];
        if (p1.hasControlPoint2() && p2.hasControlPoint1()) {
          if (i == 0) { 
            vertex(points[0].x, -points[0].y);
          }
          bezierVertex(p1.controlPoint2.x, -p1.controlPoint2.y, p2.controlPoint1.x, -p2.controlPoint1.y, p2.x, -p2.y);
        }
        else {
          vertex(p1.x, -p1.y);
        }
      }
      endShape();
    }
  }

}

void keyPressed() {

  if (key == 's') {
    createFont();
  }
  
}

