/**
 * Fontastic
 * A font file writer to create TTF and WOFF (Webfonts).
 * http://code.andreaskoller.com/libraries/fontastic
 *
 * Copyright (C) 2013 Andreas Koller http://andreaskoller.com
 *
 * Uses:
 *  doubletype http://sourceforge.net/projects/doubletype/ for TTF creation
 *  sfntly http://code.google.com/p/sfntly/ for WOFF creation
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 * 
 * @author      Andreas Koller http://andreaskoller.com
 * @modified    06/19/2013
 * @version     0.4 (4)
 */

package fontastic;

import processing.core.*;

import fontastic.FGlyph;
import fontastic.FContour;
import fontastic.FPoint;

import org.doubletype.ossa.*;
import org.doubletype.ossa.module.*;
import org.doubletype.ossa.truetype.*;
import org.doubletype.ossa.adapter.*;

import com.google.typography.font.sfntly.Font;
import com.google.typography.font.sfntly.FontFactory;
import com.google.typography.font.sfntly.data.WritableFontData;
import com.google.typography.font.tools.conversion.woff.WoffWriter;

import java.io.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

/**
 * Fontastic A font file writer to create TTF and WOFF (Webfonts). http://code.andreaskoller.com/libraries/fontastic
 * 
 */
public class Fontastic {

	private PApplet myParent;

	private org.doubletype.ossa.module.TypefaceFile typeface;
	private org.doubletype.ossa.Engine m_engine;

	private String fontname;

	private String TTFfilename;
	private String WOFFfilename;
	private String HTMLfilename;
	
	private List<FGlyph> glyphs;

	private int advanceWidth = 512;

	public final static String VERSION = "0.4";
	private boolean debug = true; // debug toggles println calls

	/** Uppercase alphabet 26 characters **/
	public final static char alphabet[] = { 'A', 'B', 'C', 'D', 'E', 'F', 'G',
			'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
			'U', 'V', 'W', 'X', 'Y', 'Z' };
	/** Lowercase alphabet 26 characters **/
	public final static char alphabetLc[] = { 'a', 'b', 'c', 'd', 'e', 'f',
			'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
			't', 'u', 'v', 'w', 'x', 'y', 'z' };

	/**
	 * Return the version of the library.
	 * 
	 * @return String
	 */
	public static String version() {
		return VERSION;
	}

	/**
	 * Constructor
	 * 
	 * @example Fontastic f = new Fontastic(this, "MyFont");
	 * 
	 * @param theParent
	 *            Your processing sketch (this).
	 * @param fontname
	 *            Font name
	 * 
	 */
	public Fontastic(PApplet myParent, String fontname) {
		this.myParent = myParent;
		this.fontname = fontname;
		intitialiseFont();
		this.glyphs = new ArrayList<FGlyph>();
	}

	/**
	 * Returns the font name.
	 * 
	 * @return String
	 */
	public String getFontname() {
		return fontname;
	}

	/**
	 * Creates and initialises a new typeface. Font data is put into sketch
	 * folder data/fontname.
	 */
	private void intitialiseFont() {
		File data_dir = new File(myParent.dataPath(""));
		if (!data_dir.exists()) {
			data_dir.mkdir();
		}

		File a_dir = new File(myParent.dataPath(fontname));
		if (!a_dir.exists()) {
			a_dir.mkdir();
		} else {
			deleteFolderContents(a_dir, false);
		}

		m_engine = Engine.getSingletonInstance();
		m_engine.buildNewTypeface(fontname, a_dir);

		this.setFontFamilyName(fontname);
		this.setVersion("CC BY-SA 3.0 http://creativecommons.org/licenses/by-sa/3.0/"); // default
																						// license

		String directoryName = a_dir + File.separator + "bin" + File.separator;

		TTFfilename = directoryName + fontname + ".ttf";
		WOFFfilename = directoryName + fontname + ".woff";
		HTMLfilename = directoryName + "template.html";
	}

	/**
	 * Builds the font and writes the .ttf and the .woff file as well as a HTML template for previewing the WOFF.
	 * If debug is set (default is true) then you'll see the .ttf and .woff file name in the console.
	 */
	public void buildFont() {
		
		// Create TTF file with doubletype
		
		m_engine.addDefaultGlyphs();

		for (FGlyph glyph : glyphs) {

			GlyphFile glyphFile = m_engine.addNewGlyph(glyph.getGlyphChar());
			glyphFile.setAdvanceWidth(glyph.getAdvanceWidth());

			for (FContour contour : glyph.getContours()) {

				EContour econtour = new EContour();
				econtour.setType(EContour.k_cubic);

				for (FPoint point : contour.points) {

					EContourPoint e = new EContourPoint(point.x, point.y, true);

					if (point.hasControlPoint1()) {
						EControlPoint cp1 = new EControlPoint(true,
								point.controlPoint1.x, point.controlPoint1.y);
						e.setControlPoint1(cp1);
					}

					if (point.hasControlPoint2()) {
						EControlPoint cp2 = new EControlPoint(false,
								point.controlPoint2.x, point.controlPoint2.y);
						e.setControlPoint2(cp2);
					}

					econtour.addContourPoint(e);
				}

				glyphFile.addContour(econtour);
			}
			glyphFile.saveGlyphFile();
		}

		m_engine.buildTrueType(false);
		if (debug)
			System.out.println("TTF file created successfully: " + getTTFfilename());

		// End TTF creation
		
		// Create a WOFF file from this TTF file using sfntly

		FontFactory fontFactory = FontFactory.getInstance();

		File fontFile = new File(getTTFfilename());
		File outputFile = new File(WOFFfilename);

		byte[] fontBytes = new byte[0];
		try {
			FileInputStream fis = new FileInputStream(fontFile);
			fontBytes = new byte[(int) fontFile.length()];
			fis.read(fontBytes);
		} catch (IOException e) {
			System.out
					.println("Error while creating WOFF File. TTF file not found: "
							+ getTTFfilename());
			e.printStackTrace();
		}

		Font[] fontArray = null;
		try {
			fontArray = fontFactory.loadFonts(fontBytes);
		} catch (IOException e) {
			System.out
					.println("Error while creating WOFF File. TTF file could not be read: "
							+ getTTFfilename());
			e.printStackTrace();
		}
		Font font = fontArray[0];

		try {
			FileOutputStream fos = new FileOutputStream(outputFile);
			WoffWriter w = new WoffWriter();
			WritableFontData woffData = w.convert(font);
			woffData.copyTo(fos);
			if (debug)
				System.out.println("WOFF File created successfully: "
						+ getWOFFfilename());
		} catch (IOException e) {
			System.out
					.println("Error while creating WOFF File. WOFF file could not be written."
							+ outputFile);
			e.printStackTrace();
		}

		// End of WOFF creation
		
		// Create HTML Template for WOFF file
		String htmlTemplate = myParent.join(myParent.loadStrings("template.html"), "\n");
		Map<String, String> params = new HashMap<String, String>();
		params.put("FONTNAME", fontname);
		params.put("WOFFFILENAME", getFontname()+".woff");
		String htmlContent = replaceAll(htmlTemplate, params);
		
		myParent.saveStrings(HTMLfilename, myParent.split(htmlContent, "\n"));
		// End HTML Template
	}

	/**
	 * Deletes all the glyph files created by doubletype in your data/fontname
	 * folder.
	 */
	public void cleanup() {

		File a_dir = new File(myParent.dataPath(fontname));
		File[] filesToExclude = new File[3];
		filesToExclude[0] = new File(getTTFfilename());
		filesToExclude[1] = new File(getWOFFfilename());
		filesToExclude[2] = new File(HTMLfilename);

		deleteFolderContents(a_dir, true, filesToExclude);
		if (debug)
			System.out
					.println("Cleaned up and deleted all glyph files, except font files.");

	}

	/**
	 * Sets the author of the font.
	 */
	public void setAuthor(String author) {
		m_engine.setAuthor(author);
	}

	/**
	 * Sets the copyright year of the font.
	 */
	public void setCopyrightYear(String copyrightYear) {
		m_engine.setCopyrightYear(copyrightYear);
	}

	/**
	 * Sets the version of the font (default is "0.1").
	 */
	public void setVersion(String version) {
		m_engine.getTypeface().getGlyph().getHead().setVersion(version);
	}

	/**
	 * Sets the font family name of the font. Also called in the constructor. If
	 * changed with setFontFamilyName() it won't affect folder the font is
	 * stored in.
	 */
	public void setFontFamilyName(String fontFamilyName) {
		m_engine.setFontFamilyName(fontFamilyName);
	}

	/**
	 * Sets the sub family of the font.
	 */
	public void setSubFamily(String subFamily) {
		m_engine.getTypeface().setSubFamily(subFamily);
	}

	/**
	 * Sets the license of the font (default is
	 * "CC BY-SA 3.0 http://creativecommons.org/licenses/by-sa/3.0/")
	 */
	public void setTypefaceLicense(String typefaceLicense) {
		m_engine.setTypefaceLicense(typefaceLicense);
	}

	/**
	 * Sets the baseline of the font.
	 */
	public void setBaseline(float baseline) {
		m_engine.setBaseline(baseline);
	}

	/**
	 * Sets the meanline of the font.
	 */
	public void setMeanline(float meanline) {
		m_engine.setMeanline(meanline);
	}

	/**
	 * Sets the advanceWidth of the font. Can be changed for every glyph
	 * individually. Won't affect already created glyphs.
	 */
	public void setAdvanceWidth(int advanceWidth) {
		m_engine.setAdvanceWidth(advanceWidth);
		this.advanceWidth = advanceWidth;
	}

	public void setTopSideBearing(float topSideBearing) {
		try {
			m_engine.getTypeface().setTopSideBearing(topSideBearing);
		} catch (OutOfRangeException e) {
			System.out
					.println("Error while setting aopSideBearing (must be within range "
							+ m_engine.getTypeface().getEm());
			e.printStackTrace();
		}
	}

	public void setBottomSideBearing(float bottomSideBearing) {
		try {
			m_engine.getTypeface().setBottomSideBearing(bottomSideBearing);
		} catch (OutOfRangeException e) {
			System.out
					.println("Error while setting bottomSideBearing (must be within range "
							+ m_engine.getTypeface().getEm());
			e.printStackTrace();
		}
	}

	public void setAscender(float ascender) {
		try {
			m_engine.getTypeface().setAscender(ascender);
		} catch (OutOfRangeException e) {
			System.out
					.println("Error while setting ascender (must be within range 0 to "
							+ m_engine.getTypeface().getEm() + ")");
			e.printStackTrace();
		}
	}

	public void setDescender(float descender) {
		try {
			m_engine.getTypeface().setDescender(descender);
		} catch (OutOfRangeException e) {
			System.out
					.println("Error while setting descender (must be within range 0 to "
							+ m_engine.getTypeface().getEm() + ")");
			e.printStackTrace();
		}
	}

	public void setXHeight(float xHeight) {
		try {
			m_engine.getTypeface().setXHeight(xHeight);
		} catch (OutOfRangeException e) {
			System.out
					.println("Error while setting xHeight (must be within range 0 to "
							+ m_engine.getTypeface().getEm()
							+ " as well as lower than the ascender "
							+ m_engine.getTypeface().getAscender() + ")");
			e.printStackTrace();
		}
	}

	/**
	 * Sets the default metrics for the typeface: setTopSideBearing(170); // 2
	 * px setAscender(683); // 8 px setXHeight(424); // 5 px setDescender(171);
	 * // 2 px setBottomSideBearing(0); // 0px
	 * 
	 */
	public void setDefaultMetrics() {
		m_engine.getTypeface().setDefaultMetrics();
	}

	/**
	 * Sets debug to true (in debug mode, the library outputs what happens under
	 * the hood).
	 */
	public void setDebug() {
		setDebug(true);
	}

	/**
	 * Sets the value of debug
	 * 
	 * @param debug
	 *            true or false
	 */
	public void setDebug(boolean debug) {
		this.debug = debug;
	}

	/**
	 * Add a glyph
	 * 
	 * @param c
	 *            Character of the glyph.
	 * 
	 * @return FGlyph that has been created.
	 * 
	 */
	public FGlyph addGlyph(char c) {

		FGlyph glyph = new FGlyph(c);
		glyph.setAdvanceWidth(advanceWidth);
		glyphs.add(glyph);
		if (debug)
			System.out.println("Glyph " + c + " added. Number of glyphs: "
					+ glyphs.size());
		return glyph;

	}

	/**
	 * Add a glyph and its one contour
	 * 
	 * @param c
	 *            Character of the glyph.
	 * 
	 * @param FContour
	 *            Shape of the glyph as FContour.
	 * 
	 * @return The glyph FGlyph that has been created. You can use this to store
	 *         the glyph and add contours afterwards. Alternatively, you can
	 *         call getGlyph(char c) to retrieve it.
	 */
	public FGlyph addGlyph(char c, FContour contour) {

		FGlyph glyph = new FGlyph(c);
		glyphs.add(glyph);
		if (debug)
			System.out.println("Glyph " + c + " added. Number of glyphs: "
					+ glyphs.size());

		glyph.addContour(contour);

		glyph.setAdvanceWidth(advanceWidth);
		return glyph;

	}

	/**
	 * Add a glyph and its contours
	 * 
	 * @param c
	 *            Character of the glyph.
	 * 
	 * @param FContour
	 *            [] Shape of the glyph in an array of FContour.
	 * 
	 * @return The FGlyph that has been created. You can use this to store the
	 *         glyph and add contours afterwards. Alternatively, you can call
	 *         getGlyph(char c) to retrieve it.
	 */
	public FGlyph addGlyph(char c, FContour[] contours) {

		FGlyph glyph = new FGlyph(c);
		glyphs.add(glyph);
		if (debug)
			System.out.println("Glyph " + c + " added. Number of glyphs: "
					+ glyphs.size());

		for (FContour contour : contours) {
			// if (debug) System.out.println(p.x + " - " + p.y);
			glyph.addContour(contour);
		}
		glyph.setAdvanceWidth(advanceWidth);
		return glyph;

	}

	/**
	 * Get glyph by character
	 * 
	 * @param c
	 *            The character of the glyph
	 * 
	 * @return The glyph
	 */

	public FGlyph getGlyph(char c) {

		FGlyph glyph = null;
		for (int i = 0; i < glyphs.size(); i++) {
			if (glyphs.get(i).getGlyphChar() == c) {
				glyph = glyphs.get(i);
				break;
			}
		}
		return glyph;

	}

	/**
	 * Engine getter
	 * 
	 * @return The doubletype Engine used for font creation, so that you can
	 *         access all functions of doubletype in case you need them.
	 */
	public Engine getEngine() {
		return m_engine;
	}

	/**
	 * Returns the TypefaceFile
	 * 
	 * @return The doubletype TypefaceFile used for font creation, so that you
	 *         can access functions of doubletype in case you need them.
	 */
	public TypefaceFile getTypefaceFile() {
		return m_engine.getTypeface();
	}

	/**
	 * Returns the .ttf file name
	 * 
	 * @return The .ttf file name, which is being created when you call build()
	 */
	public String getTTFfilename() {
		return TTFfilename;
	}

	/**
	 * Returns the .woff file name
	 * 
	 * @return The .woff file name, which is being created when you call build()
	 */
	public String getWOFFfilename() {
		return WOFFfilename;
	}

	private static void deleteFolderContents(File folder,
			boolean deleteFolderItself) {
		File[] files = folder.listFiles();
		if (files != null) { // some JVMs return null for empty dirs
			for (File f : files) {
				if (f.isDirectory()) {
					deleteFolderContents(f, true);
					f.delete();
				} else {
					f.delete();
				}
			}
		}
		if (deleteFolderItself)
			folder.delete();
	}

	private static void deleteFolderContents(File folder,
			boolean deleteFolderItself, File[] exceptions) {
		File[] files = folder.listFiles();
		if (files != null) { // some JVMs return null for empty dirs
			for (File f : files) {
				boolean deleteFile = true;
				for (File exceptfile : exceptions) {
					if (f.equals(exceptfile))
						deleteFile = false;
				}
				if (deleteFile) {
					if (f.isDirectory()) {
						deleteFolderContents(f, true, exceptions);
						f.delete();
					} else {
						f.delete();
					}
				}
			}
		}
		if (deleteFolderItself)
			folder.delete();
	}

	private String sketchName() {
		String s = myParent.sketchPath("");
		s = s.substring(0, s.length() - 1);
		String sketchName = s.substring(s.lastIndexOf(File.separator) + 1,
				s.length());
		return sketchName;
	}

	// http://stackoverflow.com/questions/2368802/how-to-create-dynamic-template-string
	// Author: cletus http://stackoverflow.com/users/18393/cletus
	private static String replaceAll(String text, Map<String, String> params) {
		return replaceAll(text, params, '%', '%');
	}

	// http://stackoverflow.com/questions/2368802/how-to-create-dynamic-template-string
	// Author: cletus http://stackoverflow.com/users/18393/cletus
	private static String replaceAll(String text, Map<String, String> params,
			char leading, char trailing) {
		String pattern = "";
		if (leading != 0) {
			pattern += leading;
		}
		pattern += "(\\w+)";
		if (trailing != 0) {
			pattern += trailing;
		}
		Pattern p = Pattern.compile(pattern);
		Matcher m = p.matcher(text);
		boolean result = m.find();
		if (result) {
			StringBuffer sb = new StringBuffer();
			do {
				String replacement = params.get(m.group(1));
				if (replacement == null) {
					replacement = m.group();
				}
				m.appendReplacement(sb, replacement);
				result = m.find();
			} while (result);
			m.appendTail(sb);
			return sb.toString();
		}
		return text;
	}

}
