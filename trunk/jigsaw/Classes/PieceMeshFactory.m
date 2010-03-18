//
//  CurveFactory.m
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "PieceMeshFactory.h"

@implementation PieceMeshFactory

PieceMeshFactory* pieceMeshFactory = NULL;

+ (PieceMeshFactory*) getPieceMeshFactory {
	if (pieceMeshFactory == NULL) {
		pieceMeshFactory = [[PieceMeshFactory alloc] init];
	}
	return pieceMeshFactory;
}

//-----------------------------------------------------------------------
// constructor
//-----------------------------------------------------------------------
- (id) init {
	if ((self = [super init]) != NULL) {
		[self loadAllCurves];
		[self generateCurveTypes];
	}
	return self;
}

- (void) loadAllCurves {
	// create curves array
	nbCurves = 4;
	curves = [NSMutableArray arrayWithCapacity:nbCurves];
	
	// create curve objects
	for (int i = 0; i < nbCurves; ++i) {
		NSString* file = [[NSString stringWithFormat:@"curve%02d.crv", i+1] autorelease];
		Curve* curve = [[Curve alloc] initWithFile:file];
	
		// add to array
		[curves addObject:curve];
	}
}

- (void) generateCurveTypes {
	// create curveTypes array
	nbCurveTypes = nbCurves * 4 - 3; // flat curve type has only 1 type (scale is the same).
	curveTypes = [NSMutableArray arrayWithCapacity:nbCurveTypes];
	
	int style = CURVE_TYPE_DEFAULT; // default style
	
	// add flat curve type
	Curve* curve = (Curve*)[curves objectAtIndex: 0];
	CurveType* curveType = [[CurveType alloc] initWithCurve :curve :style];
	curveType.scaleX = 1;
	curveType.scaleY = 1;
	[curveTypes addObject:curveType];
	
	// create one curve type as a sample
	for (int x = 0; x <= 1; ++x) { // 4 type of scales
		for (int y = 0; y <= 1; ++y) {
			for (int randIdx = 1; randIdx < nbCurves; ++randIdx) {
				Curve* curve = (Curve*)[curves objectAtIndex:randIdx];
				CurveType* curveType = [[CurveType alloc] initWithCurve :curve :style];
				//curveType.scaleX = 2 * (random() % 2 - 0.5); // random direction -1 or 1.
				//curveType.scaleY = 2 * (random() % 2 - 0.5);
				curveType.scaleX = 2 * (x - 0.5);
				curveType.scaleY = 2 * (y - 0.5);
				[curveTypes addObject:curveType];
			}
		}
	}
}

- (CurveType*) getRandomCurveType {
	// generate a random curve type
	int r = random() % (nbCurveTypes - 1) + 1; // avoid the first curve type which is flat.
	
	CurveType* curveType = [curveTypes objectAtIndex: r];
	return curveType;
}

- (CurveType*) getFlatCurveType {
	return [curveTypes objectAtIndex: 0];
}

/*
- (PieceMesh*) createPieceMesh {
	// get a random curve type
	int randIdx = 0;
	CurveType* curveType = (CurveType*)[curveTypes objectAtIndex:randIdx];
	PieceMesh* pieceMesh = [[PieceMesh alloc] initWithCurveType: curveType];
	return pieceMesh;
}*/
@end
