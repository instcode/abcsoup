//
//  GomokuBoardView.h
//  JouzuGomoku
//
//  Created by Son Hua on 10/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GomokuModel.h"
#import "CellLayer.h"
#import "RenderCell.h"
#import "RenderPiece.h"
#import "RenderCursor.h"
#import "RenderHintComputer.h"
#import "RenderHintHuman.h"
#import "GomokuObserver.h"

// [2008-10-31] Derive from UIScrollView instead of UIView and implement UIScrollViewDelegate

@interface GomokuBoardView : UIView <GomokuObserver> {
	GomokuModel* gomokuModel;
	CellLayer* rectLayer;	// empty rect
	CellLayer* blackLayer;	// rect with black piece
	CellLayer* whiteLayer;	// rect with white piece
	CellLayer* cursorLayer; // rect with special highlight color
	CellLayer* hintComputerLayer;	// rect with special color for computer hint
	CellLayer* hintHumanLayer;		// rect with special color for human hint
	RenderCell*		renderCellDelegate;
	RenderPiece*	renderBlackDelegate;
	RenderPiece*	renderWhiteDelegate;
	RenderCursor*	renderCursorDelegate;
	RenderHintComputer*		renderHintComputerDelegate;
	RenderHintHuman*		renderHintHumanDelegate;
	
	int boardSize;
	float cellSize;
	bool firstTimePainting;
	
	CGPoint cursor; // highlight cursor
	CGPoint computerCursor; //highlight computer cursor
	
	UIScrollView* superview;
	
	bool isHumanMoved;
	bool isHumanRendered; // a flag to capture human move state to decide whether the board should be painted and the computer should make a move

	NSTimer* timer;
}

// visitor and renderer
- (void) visitAndRenderCell:(int)_x:(int)_y:(int)val;
- (void) visitAndRenderHint:(int)_x:(int)_y:(int)type;

// observer
- (void)onGomokuNotify:(id<GomokuObservable>)observable;	// on paint
- (void)onNotifyNewGame:(id<GomokuObservable>)observable;	// on new game
- (void)onZoomScaleChanged:(float)scale;

- (float)cellSizeFromScale:(float)scale; // compute cellSize from an input scale
- (CGSize)getFullBoardSize;	// return the full size = cellSize*boardSize in points
- (CGPoint)getScrollOffset; // get center position of the full board view
- (CGPoint)getCurrentScrollOffset:(CGPoint)expectCursor; // get content offset based on current cursor position in the boardView and the scrollView.
- (void)focusOnCursor;
- (void)hideCursor;

- (void)checkGameOver; // display a message when gameover

- (bool)isFirstTimePainting;
- (void)notifyFirstTimePainting;
- (void)cancelFirstTimePainting;

- (void)askForComputerMove;
- (void)startThinking;

- (void)scheduleRender;
//- (void)viewLoaded;


@end
