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
		pieceMeshFactory = [[[PieceMeshFactory alloc] init] retain];
	}
	return pieceMeshFactory;
}

- (void) dealloc {
	//if (pieceMeshFactory)
		//[pieceMeshFactory release];
	[curves release];
	[curveTypes release];
	
	[super dealloc];
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
	curves = [[NSMutableArray arrayWithCapacity:nbCurves] retain];
	
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
	nbCurveTypes = nbCurves * 4; // flat curve type has only 1 type (scale is the same).
	curveTypes = [[NSMutableArray arrayWithCapacity:nbCurveTypes] retain];
	
	int style = CURVE_TYPE_DEFAULT; // default style
	
	// treat flat curve types as other curve types. When random avoid the first three flat curve types.
	
	// create one curve type as a sample
	
	for (int randIdx = 0; randIdx < nbCurves; ++randIdx) {
		for (int x = 0; x <= 1; ++x) { // 4 type of scales
			for (int y = 0; y <= 1; ++y) {
				Curve* curve = (Curve*)[curves objectAtIndex:randIdx];
				CurveType* curveType = [[CurveType alloc] initWithCurve :curve :style :randIdx * 4 + x * 2 + y];
				curveType.scaleX = 2 * (x - 0.5);
				curveType.scaleY = 2 * (y - 0.5);
				
				[curveTypes addObject:curveType];
				
				
			}
		}
	}
}

- (CurveType*) getRandomCurveType {
	// generate a random curve type
	int r = random() % (nbCurveTypes - 3) + 3; // avoid the first three curve type which is flat. The fourth curve type, which is flat, is used as as the result of random, as we don't want so many flat curve types.
	
	CurveType* curveType = [curveTypes objectAtIndex: r];
	return curveType;
}

- (CurveType*) getCurveTypeAtIndex: (int) idx {
	return [curveTypes objectAtIndex: idx];
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
