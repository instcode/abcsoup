//
//  CurveType.h
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#include "Point.h"
#include "CurveType.h"

@interface PieceMesh : NSObject {
@private
	CurveType* curveType[4];
	//Edge* edge[4];
	
	int nbPoints;
	struct JPoint* points;
	
	// cannot place texture coordinates here because of the reuse of the piece mesh in different places.
	//struct TexCoord* texcoords;
	
	unsigned short* index;
	int nbTriangles;
	
	unsigned short* lineIndex;
	int nbLines;
}

@property (nonatomic, readonly) int nbPoints;
@property (nonatomic, readonly) struct JPoint* points;
@property (nonatomic, readonly) unsigned short* index;
@property (nonatomic, readonly) int nbTriangles;

/** 
 Use only 1 curve type for 4 sides 
 */
- (id) initWithCurveType: (CurveType*) _curveType;

/**
 Use 4 curve types for 4 sides
 */
- (id) initWithCurveType4: (CurveType* []) _curveTypes;

/**
 Generate mesh vertices based on input curve types
 */
- (void) generateMeshVertices;

/**
 Create mesh from the curve input points and current style using ear clipping algorithm
 */
- (void) createMesh;
@end
