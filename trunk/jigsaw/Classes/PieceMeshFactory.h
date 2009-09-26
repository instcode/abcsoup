//
//  CurveFactory.h
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "PieceMesh.h"

@interface PieceMeshFactory : NSObject {
	NSMutableArray* curves;
	int nbCurves;
	
	NSMutableArray* curveTypes;
	int nbCurveTypes;
	
	NSMutableArray* pieceMeshes;
	int nbPieceMeshes;
}

/**
 Singleton factory
 */
+ (PieceMeshFactory*) getPieceMeshFactory;

/**
 Load all curves from the library
 */
- (void) loadAllCurves;

/**
 Randomly generate curve types for piece mesh
 */
- (void) generateCurveTypes;

/**
 Ear clipping algorithm to triangulate curves
 */
//- (PieceMesh*) createPieceMesh;

/**
 Get a random curve type
 */
- (CurveType*) getRandomCurveType;
@end
