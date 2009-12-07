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
#import "Point.h"
#import "EventJPoint.h"

#define CELL_LEFT 3
#define CELL_RIGHT 1
#define CELL_TOP 0
#define CELL_BOTTOM 2

#define LOCATION_ON_BOARD 0
#define LOCATION_ON_TRAY_NOT_VISIBLE 1
#define LOCATION_ON_TRAY_VISIBLE 2

struct CellCurveTypes {
	CurveType* c[4];	// 4 curve types for each cell
};

enum RenderState {
	WaitForPlayer,
	TransitionTrayUp,
	TransitionTrayDown,
	nbRenderStates
};

@interface Board : NSObject<Renderable> {
	int width;				// how many cells are there in the board?
	int height;
	
	Piece** pieces;
	int nbPieces;
	bool genTexCoords;		// one time texture coordinate generation
	GLuint texPhoto;
	
	float top;				// offset from top of screen to render the board
	struct JPoint center;	// board center, from (0, 0) top left of screen 
	
	//
	// piece render information
	//
	float screenSize;
	int minNumPieces;		// the number of pieces on a row/column (get the minimum)
	float pieceWidth;		// piece size after fit to screen
	float pieceHeight;
	//float pieceSize;		// piece size after scaled for rendering (sometimes we don't want the pieces to fill the whole square)
	float scaleX;			// piece scale for render
	float scaleY;
	float x0, y0;			// top left coordinates of the top left piece
	float x1, y1;			// bottom right coordinates of the bottom right piece
	int selectedIndex;		// selected piece index
	float selectedColorDelta;
	struct JPoint selectedColor;
	struct JPoint* correctPosition;	// correct position of every piece
	struct JPoint* currentPosition; // current position of every piece
	
	// tray information
	float trayTop, trayBottom;			// the vertical line separating the board (top) and the tray (bottom) which is used to store unused pieces
	float lineVerts[12];	// 4 points (x, y, z)
	
	int nbPiecesPerTrayLine;
	int nbTrayLines;
	int curTrayLine;
	int nonEmptyTrayLines;
	
	int nbMaxPiecesInTray;
	int nbPiecesInTray;
	
	int* trayPieces;		// indices of pieces stayed in tray
	float trayPieceWidth;
	float trayPieceHeight;
	struct JPoint* trayPieceCorrectPosition; // expected position per piece to stay in tray
	int* pieceLocation;		// state where a piece is currently located. E.g., on board, on tray, etc.
	
	struct JPoint* oldPosition;	// context of pieces to revert when snap fails.
	int* oldTrayPieces;
	int* oldPieceLocation;
	int oldNbPiecesInTray;
	
	
	// event queue
	struct EventJPoint* qTouch;
	int head, tail, count;
	
	// render state
	enum RenderState renderState;
	
	// start up board information
	int nbMissingPieces;	// 0 will random the number of missing pieces
							// nbMissingPieces is also the number of pieces stayed in tray at startup time
	
	
	
	
	
}

#define SELECTED_COLOR_DELTA 0.05f
#define SELECTED_COLOR_UPPER 0.7f
#define SELECTED_COLOR_LOWER 0.4f

#define QUEUE_SIZE 128

@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;

/**
 Create a new board data with specified size
 */
- (id) initWithSize: (int) width: (int) height;

/**
 Set board render offset from top of the screen
 */
- (void) setTopOffset: (float) top;

/**
 Create piece meshes that fit into a grid
 */
- (void) createPiecesGeometry;

/**
 Transfer all pieces geometry into GPU
 */
- (void) transferGeometry;

/**
 Generate texture coordinates
 */
- (void) genTexCoords;

/**
 Load texture objects
 */
- (void) loadResources;

/**
 See which piece is hit 
 */
- (Piece*) testHitPiece: (struct JPoint) p;
- (bool) testHitTrayUp: (struct JPoint) p;
- (bool) testHitTrayDown: (struct JPoint) p;

/**
 On touch event
 */
- (void) onTouchMoved: (struct JPoint) p;
- (void) onTouchBegan: (struct JPoint) p;
- (void) onTouchEnded: (struct JPoint) p;
- (void) queueTouchEvent: (struct EventJPoint) e;
@end
