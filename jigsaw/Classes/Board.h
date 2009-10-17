//
//  Board.h
//  Jigsaw
//
//  Created by Son Hua on 17/10/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import "Piece.h"
#import "CurveType.h"

#define CELL_LEFT 3
#define CELL_RIGHT 1
#define CELL_TOP 0
#define CELL_BOTTOM 2

struct CellCurveTypes {
	CurveType* c[4];	// 4 curve types for each cell
};

@interface Board : NSObject<Renderable> {
	int width;		// how many cells are there in the board?
	int height;
	
	Piece** pieces;
	bool genTexCoords;		// one time texture coordinate generation
	GLuint texPhoto;
}

@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;

/**
 Create a new board data with specified size
 */
- (id) initWithSize: (int) width: (int) height;

/**
 Create piece meshes that fit into a grid
 */
- (void) createPiecesGeometry;

/**
 Generate texture coordinates
 */
- (void) genTexCoords;

/**
 Load texture objects
 */
- (void) loadResources;
@end
