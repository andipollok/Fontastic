package fontastic;

/**
 * Fontastic
 * A TrueType font file writer for Processing.
 * http://code.andreaskoller.com/libraries/fontastic
 *
 * Copyright 2013 Andreas Koller http://andreaskoller.com
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
 * @modified    02/02/2013
 * @version     0.1 (1)
 */

import processing.core.PVector;


/**
 * Class FPoint extends PVector
 * 
 * Stores a point with x and y coordinates and optional PVector controlPoint1 and controlPoint2.
 * 
 */
public class FPoint extends PVector {

	private boolean bezier;
	public PVector controlPoint1;
	public PVector controlPoint2;
	
	private boolean hasControlPoint1;
	private boolean hasControlPoint2;

	public FPoint() {	
	}
	
	public FPoint(PVector point) {
		this.x = point.x;
		this.y = point.y;
		this.hasControlPoint1 = false;
		this.hasControlPoint2 = false;
	}
	
	public FPoint(float x, float y) {
		this.x = x;
		this.y = y;
		this.hasControlPoint1 = false;
		this.hasControlPoint2 = false;
	}
	
	public FPoint(PVector point, PVector controlPoint1, PVector controlPoint2) {
		this.x = point.x;
		this.y = point.y;
		this.controlPoint1 = controlPoint1;
		this.controlPoint2 = controlPoint2;
		this.hasControlPoint1 = true;
		this.hasControlPoint2 = true;
	}
	
	public void setControlPoint1(PVector controlPoint1) {
		this.controlPoint1 = controlPoint1;
		this.hasControlPoint1 = true;
	}

	public void setControlPoint1(float x, float y) {
		this.controlPoint1 = new PVector(x,y);
		this.hasControlPoint1 = true;
	}

	public void setControlPoint2(PVector controlPoint2) {
		this.controlPoint2 = controlPoint2;
		this.hasControlPoint2 = true;
	}

	public void setControlPoint2(float x, float y) {
		this.controlPoint2 = new PVector(x,y);
		this.hasControlPoint2 = true;
	}
	
	public boolean hasControlPoint1() {
		return hasControlPoint1;		
	}

	public boolean hasControlPoint2() {
		return hasControlPoint2;		
	}

}