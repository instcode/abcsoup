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
#import "GomokuObserver.h"

// [2008-10-31] Derive from UIScrollView instead of UIView and implement UIScrollViewDelegate

@interface GomokuBoardView : UIView <GomokuObserver> {
	GomokuModel* gomokuModel;
	CellLayer* rectLayer;	// empty rect
	CellLayer* blackLayer;	// rect with black piece
	CellLayer* whiteLayer;	// rect with white piece
	CellLayer* cursorLayer; // rect with special highlight color
	RenderCell*		renderCellDelegate;
	RenderPiece*	renderBlackDelegate;
	RenderPiece*	renderWhiteDelegate;
	RenderCursor*	renderCursorDelegate;
	
	int boardSize;
	float cellSize;
	bool firstTimePainting;
	
	CGPoint cursor; // highlight cursor
	
	UIScrollView* superview;
}

// visitor and renderer
- (void) visitAndRenderCell:(int)_x:(int)_y:(int)val;

// observer
- (void)onGomokuNotify:(id<GomokuObservable>)observable;
- (void)onZoomScaleChanged:(float)scale;

- (float)cellSizeFromScale:(float)scale; // compute cellSize from an input scale
- (CGSize)getFullBoardSize;	// return the full size = cellSize*boardSize in points
- (CGPoint)getScrollOffset; // get center position of the full board view
- (CGPoint)getCurrentScrollOffset:(CGPoint)expectCursor; // get content offset based on current cursor position in the boardView and the scrollView.
- (void)focusOnCursor;
- (void)hideCursor;

- (bool)isFirstTimePainting;
- (void)notifyFirstTimePainting;
- (void)cancelFirstTimePainting;
- (void)notifyPaintingFinished;
- (void)startThinking;
//- (void)viewLoaded;
@end
