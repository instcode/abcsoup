//
//  BoardView.h
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import "PieceView.h"
#import "BoardModel.h"
#import "Renderable.h"
#import "CurveType.h"

#define CELL_LEFT 3
#define CELL_RIGHT 1
#define CELL_TOP 0
#define CELL_BOTTOM 2

struct CellCurveTypes {
	CurveType* c[4];	// 4 curve types for each cell
};

@interface BoardView : Renderable {
@private
	PieceView** pieceViews; // piece view grid
	BoardModel* boardModel;
	
	bool genTexCoords;		// one time texture coordinate generation
	GLuint texPhoto;
}

/**
 Create piece views that fit into a grid
 */
- (void) createPieceViews;

@end
