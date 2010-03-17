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
	nbCurves = 10;
	curves = [NSMutableArray arrayWithCapacity:nbCurves];
	
	// create curve objects
	Curve* curve = [[Curve alloc] initWithFile:@"curve02.crv"];
	
	// add to array
	[curves addObject:curve];
}

- (void) generateCurveTypes {
	// create curveTypes array
	nbCurveTypes = 10;
	curveTypes = [NSMutableArray arrayWithCapacity:nbCurveTypes];
	
	// create one curve type as a sample
	int randIdx = 0;
	
	int style = CURVE_TYPE_DEFAULT; // default style
	//int style = CURVE_TYPE_FLIP_VERTICAL;
	//int style = CURVE_TYPE_FLIP_HORIZONTAL;
	//int style = CURVE_TYPE_FLIP_HORIZONTAL | CURVE_TYPE_FLIP_VERTICAL;
	
	Curve* curve = (Curve*)[curves objectAtIndex:randIdx];
	CurveType* curveType = [[CurveType alloc] initWithCurve :curve :style];
	
	[curveTypes addObject:curveType];
}

- (CurveType*) getRandomCurveType {
	// TODO: generate a random curve type here
	CurveType* curveType = [curveTypes objectAtIndex:0];
	return curveType;
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
