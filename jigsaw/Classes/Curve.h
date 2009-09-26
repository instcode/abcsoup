//
//  Curve.h
//  Jigsaw
//
//  Created by Son Hua on 8/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#include "Point.h"

//-----------------------------------------
#define CURVE_TYPE_DEFAULT			0
#define CURVE_TYPE_FLIP_HORIZONTAL	1
#define CURVE_TYPE_FLIP_VERTICAL	2
//-----------------------------------------

/******************************************************************************************
 * Curve class is the generic representation for all curve properties parsed from .crv file
 ******************************************************************************************/
@interface Curve : NSObject {

@private
	NSString* file;	// .crv file containing curve information
	
	int width, height;
	int nbPoints;
	struct JPoint* points;
}

/******************************************
 * Get points
 ******************************************/
@property (nonatomic, readonly) struct JPoint* points;
@property (nonatomic, readonly) int nbPoints;
@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;


/******************************************
 * Create a curve object with a file input
 ******************************************/
- (id) initWithFile:(NSString*) file;

/******************************************
 * Parse the .crv file for curve details
 ******************************************/
- (void) parseCurve;

@end
