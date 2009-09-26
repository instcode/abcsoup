//
//  CurveType.m
//  Jigsaw
//
//  Created by Son Hua on 19/08/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "CurveType.h"

@implementation CurveType

/*
@synthesize nbPoints, points;
@synthesize width, height;
*/
@synthesize curve;
@synthesize scaleX, scaleY;

- (id) initWithCurve: (Curve*) _curve: (int) _style {
	if ((self = [super init]) != NULL) {
		curve = _curve;
		style = _style;
		//scaleX = 1;
		//scaleY = 1;
		/*
		// import curve points
		nbPoints = curve.nbPoints;
		points = (struct JPoint*) malloc (sizeof(struct JPoint) * nbPoints);
		memcpy(points, curve.points, sizeof(struct JPoint) * curve.nbPoints);
		width = curve.width;
		height = curve.height;
		
		if (style & CURVE_TYPE_FLIP_HORIZONTAL) {
			// flip over x = 0 and move in by width
			struct JPoint* arr = points;
			for (int i = 0; i < curve.nbPoints / 2; ++i) {
				// also reverse the array order to keep the point in correct order (clockwise)
				float v1 = -arr[i].x + curve.width;
				float v2 = -arr[curve.nbPoints - 1 - i].x + curve.width;
				arr[i].x = v2;
				arr[curve.nbPoints - 1 - i].x = v1;
				
				//arr[i].x = -arr[curve.nbPoints - 1 - i].x + curve.width;
			}
			
		}
		
		if (style & CURVE_TYPE_FLIP_VERTICAL) {
			// flip over y = 0
			struct JPoint* arr = points;
			for (int i = 0; i < curve.nbPoints; ++i) {
				arr[i].y = -arr[i].y;
			}
		}*/
	}
	return self;
}

- (void) dealloc {
	//free(points);
	[super dealloc];
}

- (CurveType*) clone {
	CurveType* newCurveType = [[CurveType alloc] initWithCurve:curve :0];
	newCurveType.scaleX = 1;
	newCurveType.scaleY = 1;
	return newCurveType;
}

- (CurveType*) cloneFlip {
	CurveType* newCurveType = [[CurveType alloc] initWithCurve:curve :0];
	newCurveType.scaleX = -scaleX;
	newCurveType.scaleY = -scaleY;
	return newCurveType;
}


@end
