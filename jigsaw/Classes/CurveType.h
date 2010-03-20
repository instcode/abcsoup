//
//  CurveType.h
//  Jigsaw
//
//  Created by Son Hua on 19/08/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "Curve.h"
#include "Point.h"

//-----------------------------------------
#define CURVE_TYPE_DEFAULT			0
#define CURVE_TYPE_FLIP_HORIZONTAL	1
#define CURVE_TYPE_FLIP_VERTICAL	2
//-----------------------------------------

@interface CurveType : NSObject {
@private
	int curveTypeID;
	Curve* curve;		// the curve object that contains the original curve points
	int style;			// an integer representing the combination of avaible curve styles (e.g., flip horizontal = 1, flip vertical = 2, flip both = 1 + 2 = 3)
	float scaleX, scaleY;
	
	/*
	int nbPoints;
	struct JPoint* points;
	int width, height;
	 */
}

@property (nonatomic, readonly) int curveTypeID;
@property (nonatomic, readonly) Curve* curve;
@property (nonatomic, readonly) int style;
@property (nonatomic, assign) float scaleX, scaleY;
/*
@property (nonatomic, readonly) struct JPoint* points;
@property (nonatomic, readonly) int nbPoints;
@property (nonatomic, readonly) int width, height;
*/
 /**
 Constructor
 */
- (id) initWithCurve: (Curve*) _curve: (int) _style: (int)_id;
/**
 Clone a new curve type with the same curve but reset all scale values to 1
 */
//- (CurveType*) clone;

/**
 Clone a new curve type with the same curve but flip scale X and Y
 */
//- (CurveType*) cloneFlip;

/**
 Compatibility check when two curves (pieces) are placed side by side
 */
- (bool) isCompatibleWith: (CurveType*) curve;

/**
 Similarity check of two curves
 */
- (bool) isSimilarTo: (CurveType*) curve;

@end
