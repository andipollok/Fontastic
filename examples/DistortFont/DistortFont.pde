 /**
 * Fontastic
 * A font file writer for Processing.
 * http://code.andreaskoller.com/libraries/fontastic
 *
 * Example: DistortFont
 *
 * How to create character shapes based on another font.
 * - Press 's' to save ttf and woff files
 *   in the current state of distortion
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
  RCommand.setSegmentLength(200);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  initFont();

  updateFont();

}


void draw() {

  updateFont();

  background(255);

  strokeWeight(2);
  textSize(25);

  int numberOfLetters = 10;
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

  if (fontBuilt) { // if the ttf has already been built, display it
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

  f = new Fontastic(this, "Distort" + nf(version,4));

  for (char c : Fontastic.alphabet) {
    f.addGlyph(c);
  }

  for (char c : Fontastic.alphabetLc) {
    f.addGlyph(c);
  }

//  f.setFontFamilyName("Confetti");  // if font has same name, it won't be loaded by Processing in runtime
  f.setAuthor("Andreas Koller");
  f.setVersion("0.1");
  f.setAdvanceWidth(int(charWidth * 1.1));

}

void updateFont() {


  RCommand.setSegmentLength(mouseX / 2f);

  float maxOffset = 130; // seems to be the maximum value for setSegmentOffset with the font FreeSans
  float speed = 40;
  float timer = (millis()/speed) % maxOffset;
  float offset = (sin(timer / maxOffset * TWO_PI) + 1) * maxOffset / 2; // this is an sin oscillator between 0 and 100
  RCommand.setSegmentOffset(offset);
  
  for (char c : Fontastic.alphabet) {

    RShape shp = font.toShape(c);

    RPoint[] pnts = new RPoint[0];
    try {    
      pnts = shp.getPoints();
    }
    catch (NullPointerException e) {
      println("Problem with setSegmentOffset at Character "+c);
    }

    PVector[] points = new PVector[0];

    for (int i=0; i<pnts.length-1; i++) {
      RPoint p = pnts[i];
      points = (PVector[]) append(points, new PVector(p.x * 5, -p.y * 5));   
    }
    f.getGlyph(c).clearContours();
    f.getGlyph(c).addContour(points);
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

void renderGlyphSolid(char c) {
    
  FContour[] contours = f.getGlyph(c).getContoursArray();

  for (int j=0; j<contours.length; j++) {

    FPoint[] points = f.getGlyph(c).getContour(j).getPointsArray();

    if (points.length > 0) { //just to be sure    
      // Draw the solid shape in Processing
      beginShape();
      vertex(points[0].x, -points[0].y);
      for (int i=0; i<points.length; i++) {
        FPoint p1 = points[i];
        FPoint p2 = points[(i+1)%points.length];
        if (p1.hasControlPoint2() && p2.hasControlPoint1()) {
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

