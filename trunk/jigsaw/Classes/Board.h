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
#import "Constant.h"
#import "Texture2D.h"

#define LOCATION_ON_BOARD 0
#define LOCATION_ON_TRAY_NOT_VISIBLE 1
#define LOCATION_ON_TRAY_VISIBLE 2

#define CELL_STAT_EMPTY -1

#define SELECTED_COLOR_UPPER_RED		1.0f
#define SELECTED_COLOR_LOWER_RED		168 / 255.0f
#define SELECTED_COLOR_UPPER_GREEN		1.0f
#define SELECTED_COLOR_LOWER_GREEN		255 / 255.0f
#define SELECTED_COLOR_UPPER_BLUE		1.0f
#define SELECTED_COLOR_LOWER_BLUE		0 / 255.0f
#define SELECTED_COLOR_CHANGE_FRAMES	15


#define QUEUE_SIZE 128

struct CellCurveTypes {
	CurveType* c[4];	// 4 curve types for each cell
};

enum RenderState {
	rsNull,
	rsWaitForPlayer,
	rsGameOver,
	rsLoading,
	
	rsTransitionTrayUp,
	rsTransitionTrayDown,
	rsTransitionQuestionFadeIn,
	
	nbRenderStates
};

// current state ends after a period of time and switch to a new state
enum TransitionValue {
	tvEnd,
	tvFadeIn,
	tvAllCorrect,	// changes to rsGameOver
	tvLoad,			// load new photo
	nbTransitionValues
};

@class Jigsaw;
@interface Board : Renderable {
	Jigsaw* jigsaw;			// game manager
	int width;				// how many cells are there in the board?
	int height;
	
	Piece** pieces;
	int nbPieces;
	bool genTexCoords;		// one time texture coordinate generation
	GLuint texPhoto;
	GLuint texButtons;
	
	float top;				// offset from top of screen to render the board
	struct JPoint center;	// board center, from (0, 0) top left of screen 
	
	//
	// piece render information
	//
	float	screenSize;
	CGRect	screenRect;
	
	float pieceWidth;		// piece size after fit to screen
	float pieceHeight;
	float maxPieceWidth;	// bound of piece size when curves are added
	float maxPieceHeight;
	
	float scaleX;			// piece scale for render
	float scaleY;
	float x0, y0;			// top left coordinates of the top left piece
	float x1, y1;			// bottom right coordinates of the bottom right piece
	int selectedIndex;		// selected piece index
	struct JPoint selectedColorDelta;
	struct JPoint selectedColor;
	struct JPoint* correctPosition;	// correct position of every piece
	struct JPoint* currentPosition; // current position of every piece
	
	int questionIndex;
	struct JPoint questionPosition; // question mark position	
	
	float fadeInAlpha, fadeInAlphaStart, fadeInAlphaInc, fadeInAlphaEnd;
	struct JPoint fadeInScale, fadeInScaleStart, fadeInScaleEnd, fadeInScaleInc;		// fade in effect scale
	
	// tray information
	float trayTop, trayBottom;			// the vertical line separating the board (top) and the tray (bottom) which is used to store unused pieces
	
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
	int* oldPieceLocation;  // (!!!) Note: a piece which is on board may not stay in its correct position.
	
	int* cellStat;			// cell status (empty, occupied)
	int* oldCellStat;
	
	struct JPoint* oldPosition;	// context of pieces to revert when snap fails.
	int* oldTrayPieces;
	int oldNbPiecesInTray;
	
	int* missing;					// a random swap index array to mark missing pieces. Size of this array is nbPieces, not nbMissingPieces. 
	int missingStart, missingEnd;	// missing indices
	int nbMissingPieces;	// 0 will random the number of missing pieces
	// nbMissingPieces is also the number of pieces stayed in tray at startup time
	// nbMissingPieces corresponds to a consecutive section on missing integer array (above).
	
	// grid of curve types
	struct CellCurveTypes* grid;
	
	// event queue
	struct EventJPoint* qTouch;
	int head, tail, count;
	
	// render state
	enum RenderState renderState;
	int automata[nbRenderStates][nbTransitionValues];
	
	// start up board information
	
	// display button's information
	struct JPoint buttonBackPos;
	struct JPoint buttonNextPos;
	struct JPoint buttonNewPos;
	struct JPoint barPos;
	
	// text display
	Texture2D* title;
	NSString* curFileName;
	NSString* curCaption;
	NSMutableDictionary*	dictFileCaption;		// map between file name and photo caption
	NSEnumerator*			enumFile;				// enumerator over file name (key) in dictionary
	
	// done playing this board; ready to switch to new board
	bool isDone;
	bool isFromFile;								// differentiate between loaded data and random generated data at start
}

@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;

/**
 Create a new board data with specified size
 */
- (id) init;

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
//- (void) loadResources;

/**
 See which piece is hit 
 */
- (Piece*) testHitPiece:	(struct JPoint) p;
- (bool) testHitTrayUp:		(struct JPoint) p;
- (bool) testHitTrayDown:	(struct JPoint) p;
- (bool) testHitNew:		(struct JPoint) p;
/**
 On touch event
 */
- (void) onTouchMoved: (struct JPoint) p;
- (void) onTouchBegan: (struct JPoint) p;
- (void) onTouchEnded: (struct JPoint) p;
- (void) queueTouchEvent: (struct EventJPoint) e;

/**
 Generate state transition table
 */
- (void) createAutomata;
/**
 State management: switch from current state to a new state according to the input transition value.
 */
- (void) switchState: (enum TransitionValue) transitionValue;

/**
 Check game complete
 */
- (bool) isComplete;

/**
 Render function
 */
- (void) renderBoard;
- (void) renderTitle;
- (void) renderTray;
- (void) renderTransition;

/**
 Load a new photo with a specified grid size
 */
- (void) loadNextPhoto: (int)_width :(int)_height;
/**
 Load a new photo with a random grid size
 */
- (void) loadNextPhoto;
- (void) load: (FILE*) f;
- (void) save: (FILE*) f;
@end
