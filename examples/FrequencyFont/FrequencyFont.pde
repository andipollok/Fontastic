 /**
 * Fontastic
 * A font file writer for Processing.
 * http://code.andreaskoller.com/libraries/fontastic
 *
 * Example: FrequencyFont
 *
 * How to create a font based on a dataset
 * This example takes the frequency of the letters in the English language
 * to draw different sized bars for each character.
 * Letter frequency taken from: http://en.wikipedia.org/wiki/Letter_frequency
 *
 * 
 * @author      Andreas Koller http://andreaskoller.com
 */
 
import fontastic.*;
import java.util.*;


Fontastic f;


void setup() {

  size(600, 600);
  fill(0);

  createFont();

}


void draw() {

  background(255);

  PFont myFont = createFont(f.getTTFfilename(), 60);

  textFont(myFont);
  textAlign(CENTER, CENTER);

  text(new String(Fontastic.alphabet), width/2, height/4);

  text(new String(Fontastic.alphabetLc), width/2, height/4*3);

  noLoop();

}

void createFont() {

  f = new Fontastic(this, "Frequency");

  f.setAdvanceWidth(200);

  String lines[] = loadStrings(dataPath("letterfrequencies.txt"));
  HashMap<Character, Float> letterFreq = new HashMap<Character, Float>();
  for (String s : lines) {
    if (s.startsWith("#")) continue;
    String[] values = split(s, '\t');
    Character c = values[0].charAt(0);
    Float freq = Float.parseFloat(values[1]);
    letterFreq.put(c, freq);
  }

  Float maxFreq = (Collections.max(letterFreq.values()));

  for (Map.Entry entry : letterFreq.entrySet()) {

    Character c = (Character) entry.getKey();

    float value = (Float) entry.getValue();
    float h = map(value, 0, maxFreq, 0, 2048);

    float d = 60;
    PVector[] points = new PVector[0];

    points = (PVector[]) append(points, new PVector(0, 0));
    points = (PVector[]) append(points, new PVector(0, h));
    points = (PVector[]) append(points, new PVector(d, h));
    points = (PVector[]) append(points, new PVector(d, 0));

    f.addGlyph(c).addContour(points);

    PVector[] pointsLc = new PVector[points.length];

    for (int i=0; i<pointsLc.length; i++) {
      pointsLc[i] = new PVector();
      pointsLc[i].x = points[i].x * 0.5;
      pointsLc[i].y = points[i].y;
    }

    f.addGlyph(Character.toLowerCase(c)).addContour(pointsLc);
  }
  
  f.buildFont();
  
  f.cleanup();
  
}

