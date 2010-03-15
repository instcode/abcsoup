//
//  CurveType.m
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "PieceMesh.h"
#include "Point.h"
#include "Triangle.h"
#include "Geometry.h"
#include "Constant.h"

@implementation PieceMesh
//@synthesize curveType; 
@synthesize points, nbPoints;
@synthesize index, nbTriangles;

- (CurveType**) curveType {
	return curveType;
}

//-----------------------------------------------------------------------------------
// 1. Points in clock wise order.
// 2. Curve coordinate system: x to the right, y up. For designer's sake.
// In Photoshop, curve can be viewed as the y axis is down. 
// So the curve loaded will be conceived as flip vertical from the view of Photoshop.
// 3. OpenGL coordinate system: x to the right, y up. 
// 4. Note: clockwise/counter clockwise does not follow the plus sign direction 
// from the coordinate system.
//-----------------------------------------------------------------------------------
- (void) generateMeshVertices {
	
	// offset to save the points read from file into the point array. The additional points can be added to the front and the back.
	int offset = 0; 
	int width = 128;
	int height = 128;
	
	// allocate point memory
	nbPoints = 4; // 4 corner
	for (int i = 0; i < 4; ++i) 
		if (curveType[i] != NULL) 
			nbPoints += curveType[i].curve.nbPoints;
	
	// Points in clock wise order
	// curveType 0 corresponds to 12:00 clock
	int startOffset;
	
	/// !! Beware that the points may be overlap when translation
	// side 0
	points = (struct JPoint*) malloc (sizeof(struct JPoint) * nbPoints);
	points[0].x = - width / 2;
	points[0].y = height / 2;
	points[0].z = 0.0f;
	++offset;
	if (curveType[0] != NULL) {
		// move curve 0 to points[0]
		for (int i = 0; i < curveType[0].curve.nbPoints; ++i) {
			// !!!! can overlap points???
			int idx = i;
			float px, py;
			if (curveType[0].scaleX < 0) { // flip over y, reverse index
				idx = curveType[0].curve.nbPoints - i - 1;
				px = - curveType[0].curve.points[idx].x + curveType[0].curve.width;
			} else {
				px = curveType[0].curve.points[idx].x;
			}
			if (curveType[0].scaleY < 0) { // flip over x, keep index
				py = - curveType[0].curve.points[idx].y;
			} else {
				py = curveType[0].curve.points[idx].y;
			}
			
			
			/*
			float x =   curveType[0].curve.points[i].x + points[0].x;
			float y =   curveType[0].curve.points[i].y + points[0].y;
			*/
			
			float x =   px + points[0].x;
			float y =   py + points[0].y;
			
			
			points[offset].x = x;
			points[offset].y = y;
			points[offset].z = 0.0f;
			++offset;
		}
	}
	
	// side 1
	startOffset = offset;
	points[offset].x = width / 2;
	points[offset].y = height / 2;
	points[offset].z = 0.0f;
	++offset;
	if (curveType[1] != NULL) {
		for (int i = 0; i < curveType[1].curve.nbPoints; ++i) {
			int idx = i;
			float px, py;
			if (curveType[1].scaleX < 0) { // flip over y, reverse index
				idx = curveType[1].curve.nbPoints - i - 1;
				px = - curveType[1].curve.points[idx].x + curveType[1].curve.width;
			} else {
				px = curveType[1].curve.points[idx].x;
			}
			if (curveType[1].scaleY < 0) { // flip over x, keep index
				py = - curveType[1].curve.points[idx].y;
			} else {
				py = curveType[1].curve.points[idx].y;
			}
			
			// rotate curve 1 counter plus sign 90 degrees
			// y is down in curve's coordinate
			// ( 0 1) (1) = (0)
			// (-1 0) (0)   (-1)
			
			/*
			float x =	curveType[1].curve.points[i].y + points[startOffset].x;	
			float y = - curveType[1].curve.points[i].x + points[startOffset].y;
			*/
			
			float x =	py + points[startOffset].x;	
			float y = - px + points[startOffset].y;
			
			points[offset].x = x;
			points[offset].y = y;
			points[offset].z = 0.0f;
			++offset;
		}
	}
	
	// side 2
	startOffset = offset;
	points[offset].x =	width / 2;
	points[offset].y = - height / 2;
	points[offset].z = 0.0f;
	++offset;
	if (curveType[2] != NULL) {
		for (int i = 0; i < curveType[2].curve.nbPoints; ++i) {
			// flip over x
			//float x = - curveType[2].points[i].x + points[startOffset].x;	
			//float y = + curveType[2].points[i].y + points[startOffset].y;
			
			int idx = i;
			float px, py;
			if (curveType[2].scaleX < 0) { // flip over y, reverse index
				idx = curveType[2].curve.nbPoints - i - 1;
				px = - curveType[2].curve.points[idx].x + curveType[2].curve.width;
			} else {
				px = curveType[2].curve.points[idx].x;
			}
			if (curveType[2].scaleY < 0) { // flip over x, keep index
				py = - curveType[2].curve.points[idx].y;
			} else {
				py = curveType[2].curve.points[idx].y;
			}
			
			
			// rotate 180 degrees
			/*
			float x = - curveType[2].curve.points[i].x + points[startOffset].x;	
			float y = - curveType[2].curve.points[i].y + points[startOffset].y;
			*/
			float x = - px + points[startOffset].x;	
			float y = - py + points[startOffset].y;
			
			
			points[offset].x = x;
			points[offset].y = y;
			points[offset].z = 0.0f;
			++offset;
		}
	}
	
	// side 3
	startOffset = offset;
	points[offset].x = - width / 2;
	points[offset].y = - height / 2;
	points[offset].z = 0.0f;
	++offset;
	if (curveType[3] != NULL) {
		for (int i = 0; i < curveType[3].curve.nbPoints; ++i) {
			int idx = i;
			float px, py;
			if (curveType[3].scaleX < 0) { // flip over y, reverse index
				idx = curveType[3].curve.nbPoints - i - 1;
				px = - curveType[3].curve.points[idx].x + curveType[3].curve.width;
			} else {
				px = curveType[3].curve.points[idx].x;
			}
			if (curveType[3].scaleY < 0) { // flip over x, keep index
				py = - curveType[3].curve.points[idx].y;
			} else {
				py = curveType[3].curve.points[idx].y;
			}
			
			
			/*
			float x = -curveType[3].curve.points[i].y + points[startOffset].x;	
			float y = curveType[3].curve.points[i].x + points[startOffset].y;
			*/
			
			float x = -py + points[startOffset].x;	
			float y = px + points[startOffset].y;
			
			points[offset].x = x;
			points[offset].y = y;
			points[offset].z = 0.0f;
			++offset;
		}
	}
	nbPoints = offset;
	
	// remove duplicate points
	// temporary points structure
	struct JPoint* tmpPoints = (struct JPoint*) malloc(sizeof(struct JPoint) * nbPoints);
	memcpy(tmpPoints, points, sizeof(struct JPoint) * nbPoints);
	
	bool duplicate;
	int n = 0;
	for (int i = 0; i < nbPoints; ++i) { // have to scan until the last point to include the last point
		duplicate = false;
		for (int j = i+1; j < nbPoints; ++j) {
			if (tmpPoints[i].x == tmpPoints[j].x && tmpPoints[i].y == tmpPoints[j].y) {
				// skip copy i as we will encounter similar values to i later (j is behind i)
				duplicate = true;
				break;
			} 
		}
		if (! duplicate) {
			points[n] = tmpPoints[i];
			n++;
		}
	}
	nbPoints = n;
	free(tmpPoints);
	
	printf("Curve points\n");
	for (int i = 0; i < nbPoints; ++i) {
		printf("(%f, %f) ", points[i].x, points[i].y);
	}
	printf("Rotated curve type 3\n");
	for (int i = 0; i < curveType[3].curve.nbPoints; ++i) {
		printf("(%f, %f) ", -curveType[3].curve.points[i].y, curveType[3].curve.points[i].x);
	}
	/*
	 // add point
	 int nbPointsInFile = curveType.nbPoints;
	 // the point in the bottom middle
	 points[0].x = 0.5 * (points[0 + offset].x + points[nbPointsInFile - 1 + offset].x);
	 points[0].y = curveType.height - 1;
	 points[0].z = 0;
	 // the point in the bottom left
	 points[1].x = points[0 + offset].x;
	 points[1].y = curveType.height - 1;
	 points[1].z = 0;
	 // the point in the bottom right
	 points[nbPoints - 1].x = points[nbPointsInFile - 1 + offset].x;
	 points[nbPoints - 1].y = curveType.height - 1;
	 points[nbPoints - 1].z = 0;
	 */
	/*
	 printf("Augmented curve points\n");
	 for (int i = 0; i < nbPoints; ++i) {
	 printf("(%f, %f) ", points[i].x, points[i].y);
	 }*/
	
	// create mesh
	[self createMesh];
}

- (id) initWithCurveType: (CurveType*) _curveType {
	if ((self = [super init]) != NULL) {
		// use a curve type for 4 sides
		curveType[0] = _curveType;
		curveType[1] = _curveType;
		curveType[2] = _curveType;
		curveType[3] = _curveType;
		
		//curveType[0] = NULL;
		//curveType[1] = NULL;
		//curveType[2] = NULL;
		//curveType[3] = NULL;
		
		[self generateMeshVertices];
	}
	return self;
}

- (id) initWithCurveType4: (CurveType* []) _curveTypes {
	if ((self = [super init]) != NULL) {
		// use a curve type for 4 sides
		/*curveType[0] = [_curveTypes objectAtIndex:0];
		curveType[1] = [_curveTypes objectAtIndex:1];
		curveType[2] = [_curveTypes objectAtIndex:2];
		curveType[3] = [_curveTypes objectAtIndex:3];
		*/
		curveType[0] = _curveTypes[0];
		curveType[1] = _curveTypes[1];
		curveType[2] = _curveTypes[2];
		curveType[3] = _curveTypes[3];
		
		//curveType[3].scaleX = -1;
		//curveType[3].scaleY = -1;
		
		//curveType[0] = NULL;
		//curveType[1] = NULL;
		//curveType[2] = NULL;
		//curveType[3] = NULL;
		
		[self generateMeshVertices];
	}
	return self;
}

- (void) dealloc {
	free(points);
	[super dealloc];
}

/********************************************************************************
 * Ear clipping algorithm to triangulate from a set of 3D points
 * Points in clock wise order.
 * Determine convex: two share vectors of a vertex has a negative cross product.
 ********************************************************************************/
- (void) createMesh {
	nbTriangles = 0;
	index = (unsigned short*) malloc (sizeof(unsigned short) * 3 * nbPoints);			// a bit more indice than required
	int* isRemoved = (int*) malloc (sizeof(int) * nbPoints);	// mark which point is already clipped
	memset(isRemoved, 0, sizeof(int) * nbPoints);
	
	int countdown = nbPoints;
	int j = 1;
	while(countdown > 2) {
		int i, k;
		// find i - backward
		int cur = j;
		do {
			cur = (cur + nbPoints - 1) % nbPoints;
		} while (isRemoved[cur] || cur >= j);
		i = cur;
		
		// find k - forward
		cur = j;
		do {
			cur = (cur + 1) % nbPoints;
		} while (isRemoved[cur] || cur <= j);
		k = cur;
		
		// check ear
		struct JPoint a = points[i];
		struct JPoint b = points[j];
		struct JPoint c = points[k];
		struct JTriangle t = {a, b, c};
		
		int isEar = 1;
		for (int h = 0; h < nbPoints; ++h) {
			if (h != i && h != j && h != k && isRemoved[h] == 0) {
				struct JPoint p = points[h];
				if (testHitTriangle(t, p)) { // triangle t is not an ear
					isEar = 0;
					break;
				}
			}
		}
		if (isEar) { // clip if is ear (need to make a further convex/reflex vertex test to ensure that this is an ear)
			// make a clock wise indice
			int idx = nbTriangles;
			int v1 = i;
			int v2 = j;
			int v3 = k;
			
			// orient to z+ axis
			//struct JPoint ab = {b.x - a.x, b.y - a.y, 0};
			//struct JPoint ac = {c.x - a.x, c.y - a.y, 0};
			//struct JPoint normal = {0, 0, ab.x * ac.y - ab.y * ac.x};
			struct JPoint ba = {a.x - b.x, a.y - b.y, 0};
			struct JPoint bc = {c.x - b.x, c.y - b.y, 0};
			struct JPoint normal = {0, 0, ba.x * bc.y - ba.y * bc.x};
			
			if (normal.z >= 0) { // front face, angle from ba to bc in counter clock wise < 180 -> convex vertex, no swap
				index[3 * idx + 0] = v1;
				index[3 * idx + 1] = v2;
				index[3 * idx + 2] = v3;
				nbTriangles++;
				
				// remove j
				isRemoved[j] = 1;
				countdown--;
				
				// start from the beginning (from 1 as j is the middle point)
				j = 1;
			} else { // back face, swap the order of b and c so the front face is now in z+ direction. The angle from ba to bc in counter clock wise > 180, reflex vertex. Thus this triangle is invalid. Discard.
				int tmp = v2;
				v2 = v3;
				v3 = tmp;
			}
			
			
		} 
		// next j
			do {
				j = (j + 1) % nbPoints;
		
			} while (isRemoved[j]);
		
	}
	
	free(isRemoved);
}

-(bool) isSimilarTo: (PieceMesh*) aMesh {
	bool left = false, right = false, top = false, bottom = false;
	if (curveType[CELL_LEFT] == NULL) {
		if (aMesh.curveType[CELL_LEFT] == NULL)
			left = true;
		else
			left = false;
	} else
		left = [curveType[CELL_LEFT] isSimilarTo: aMesh.curveType[CELL_LEFT]];
	if (left == false) return false;
	
	if (curveType[CELL_RIGHT] == NULL) {
		if (aMesh.curveType[CELL_RIGHT] == NULL)
			right = true;
		else
			right = false;
	} else
		right = [curveType[CELL_RIGHT] isSimilarTo: aMesh.curveType[CELL_RIGHT]];
	if (right == false) return false;
	
	if (curveType[CELL_TOP] == NULL) {
		if (aMesh.curveType[CELL_TOP] == NULL)
			top = true;
		else
			top = false;
	} else
		top = [curveType[CELL_TOP] isSimilarTo: aMesh.curveType[CELL_TOP]];
	if (top == false) return false;
	
	if (curveType[CELL_BOTTOM] == NULL) {
		if (aMesh.curveType[CELL_BOTTOM] == NULL)
			bottom = true;
		else
			bottom = false;
	} else
		bottom = [curveType[CELL_BOTTOM] isSimilarTo: aMesh.curveType[CELL_BOTTOM]];
	if (bottom == false) return false;
	
	//return left && right && top && bottom;
	return true;
	
	/*
	return 
	[curveType[CELL_LEFT]	isCompatibleWith:	aMesh.curveType[CELL_RIGHT]] &&
	[curveType[CELL_RIGHT]	isCompatibleWith:	aMesh.curveType[CELL_LEFT]] &&
	[curveType[CELL_TOP]	isCompatibleWith:	aMesh.curveType[CELL_BOTTOM]] &&
	[curveType[CELL_BOTTOM] isCompatibleWith:	aMesh.curveType[CELL_TOP]];
	*/
}

@end
