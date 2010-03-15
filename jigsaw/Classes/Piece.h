//
//  Piece.h
//  Jigsaw
//
//  Created by Son Hua on 17/10/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Renderable.h"
#import "PieceMesh.h"

struct TexCoord {
	float s, t;
};

@interface Piece : NSObject<Renderable> {
	int uid;	// id of the piece
	int x, y;
	
	PieceMesh* mesh;	// the referenced piece mesh
	float* points;		// internal 3D points (TODO: necessary? Why don't we use points from PieceMesh and scale directly?) 
	struct TexCoord* texcoords;	
	
	unsigned short* lineIndex;		// index to draw boundary lines of a piece
}

@property (nonatomic, readonly) int uid;
@property (nonatomic, readonly) PieceMesh* mesh;

/**
 Create a new piece view linked with a mesh
 */
- (id) initWithMesh: (int) uid: (PieceMesh*) mesh;

/**
 Generate texture coordinates based on the initial scale, position of the piece on board
 */
- (void) genTexCoords: (float[]) m: (float) textureScale;

/**
 Transfer all geometry to GPU before rendering.
 */
- (void) transferGeometry;

/**
 Render selected decoration for piece
 */
- (void) renderSelected;

/**
 Similarity check
 */
- (bool) isSimilarTo: (Piece*) aPiece;
@end
