//
//  GomokuBoardView.m
//  JouzuGomoku
//
//  Created by Son Hua on 10/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

// History ======================= //
// [2008-10-27] Render board
// [2008-11-23] Add history management
// [2008-11-24] Add focusOnCursor feature
// =============================== //

#import "GomokuBoardView.h"
#import "Gomoku.h"
#import "Constant.h"
#import "CellLayer.h"

#include <math.h> # add -lm

@implementation GomokuBoardView

- (float)cellSizeFromScale:(float)scale {
	CGRect screenBound = [[UIScreen mainScreen] applicationFrame];
	return fmin(screenBound.size.width, screenBound.size.height) * scale / VIEW_BOARD_SIZE;	
}
- (CGSize)getFullBoardSize {
	return CGSizeMake(cellSize*boardSize+1, cellSize*boardSize+1);
}
- (CGPoint)getScrollOffset {
	CGSize fullSize = [self getFullBoardSize];
	//CGRect screenBound = [[UIScreen mainScreen] applicationFrame];
	CGRect parentBound = [[self superview] bounds];
	
	return CGPointMake(abs(fullSize.width - parentBound.size.width) / 2, abs(fullSize.height - parentBound.size.height) / 2);
	//return CGPointMake((fullSize.width) / 2, (fullSize.height) / 2);
}

- (CGPoint)getCurrentScrollOffset:(CGPoint)expectCursor {
	int X = VIEW_BOARD_SIZE / 2;
	int Y = VIEW_BOARD_SIZE / 2;
	int deltaX = expectCursor.x - X;
	int deltaY = expectCursor.y - Y;
	
	// avoid out of bound in scrollview (avoid seeing white space and boucning back)
	if (deltaX < 0) deltaX = 0;
	if (deltaY < 0) deltaY = 0;
	if (deltaX >= boardSize - VIEW_BOARD_SIZE) deltaX = boardSize - VIEW_BOARD_SIZE - 1;
	if (deltaY >= boardSize - VIEW_BOARD_SIZE) deltaY = boardSize - VIEW_BOARD_SIZE - 1;
	
	return CGPointMake(cellSize*deltaX, cellSize*deltaY);
}

int manFocus = 0;
int comFocus = 0;
- (void)focusOnCursor {
	CGPoint delta = [superview contentOffset];
	// new cursor position in view window coordinate
	float X = cursor.x - delta.x / cellSize;
	float Y = cursor.y - delta.y / cellSize;
	
	int maxX = VIEW_BOARD_SIZE;
	CGRect superBounds = [superview bounds];
	int maxY = superBounds.size.height / cellSize - 1; // chua` hao :D
	
	CGPoint newOffset = [self getCurrentScrollOffset:cursor];
	// if out of screen
	if (X < EPSILON_SIZE || X >= maxX - EPSILON_SIZE || Y < 0 || Y >= maxY - EPSILON_SIZE) {
	// move content offset if needed
	//CGRect newRect = CGRectMake(newOffset.x, newOffset.y, 20, 20);
		/*
		if ([gomokuModel side] == MAN) // COM has just moved
			comFocus = 1;
		else
			manFocus = 1;
		if (comFocus && manFocus)
		*/
		 [superview setContentOffset:newOffset animated:YES];	
	}
	//CGPoint c = superview.contentOffset;
	//}
	//[superview scrollRectToVisible:newRect];
}

-(void)hideCursor {
	cursor = CGPointMake(-1, -1);	
}

// This view is loaded from Nib file. Therefore, initWithFrame is not called automatically. Use awakeFromNib instead.
//- (id)initWithFrame:(CGRect)frame {
- (void)awakeFromNib {
	// set redraw mode for scrolling
	[self setContentMode:UIViewContentModeRedraw]; // redraw every frame/bound changes
	
	// init gomokuModel
	gomokuModel = [Gomoku getGomokuModel];
	[gomokuModel attachGomoku:self]; // register for observing model changes	
	
		
	// -- board size, cell size settings --	
	boardSize = [gomokuModel boardSize];
	//cellSize = (int)(fmin(screenBound.size.width, screenBound.size.height) / boardSize);
	cellSize = [self cellSizeFromScale:1];
	CGSize fullSize = [self getFullBoardSize];
	// put this view at (0, 0) of the parent scrollview
	[self setFrame:CGRectMake(0, 0, fullSize.width, fullSize.height)]; // affect center!
	//! set bound is not correct because we need to set the position of boardview as regards to its superview (scrollview).
	//! set bound is for internal only.
	
	// set scrollview's content size
	superview = [self superview];
	
	//CGPoint offset = [self getScrollOffset]; // must be placed before setFrame so that offset is calculated on the old bounds so that the board is centered.
	CGPoint offset = [self getCurrentScrollOffset:CGPointMake(boardSize/2, boardSize/2)]; // expect cursor at the center of current board size
	[superview setFrame:[self frame]];
	[superview setContentSize:fullSize];
	[superview setContentOffset:offset];
	
	//[self setBounds:[[UIScreen mainScreen] applicationFrame]];
	
	// -- prepare delegates for render layers --
	// for cell
	renderCellDelegate = [[RenderCell alloc] init];		
	[renderCellDelegate setCellSize:cellSize];
	
	// for black layer
	renderBlackDelegate = [[RenderPiece alloc] init] ;		
	[renderBlackDelegate setCellSize:cellSize];	
	[renderBlackDelegate setPiece:0];
	
	// for white layer
	renderWhiteDelegate = [[RenderPiece alloc] init] ;		
	[renderWhiteDelegate setCellSize:cellSize];	
	[renderWhiteDelegate setPiece:1];
	
	// for cursor layer
	renderCursorDelegate = [[RenderCursor alloc] init] ;		
	[renderCursorDelegate setCellSize:cellSize];		
	
	// no cursor at start
	//[self hideCursor];
	// cursor at center
	cursor = CGPointMake(boardSize/2, boardSize/2);
	
	// ask for layer first time rendering
	[self notifyFirstTimePainting];	
		
	//return self;
}

/* we can implement this and move the first time painting code out by adding more controllers */
/*
- (void)viewLoaded {
	
}
*/

- (void) visitAndRenderCell:(int)_x:(int)_y:(int)val {
	float x = _x * cellSize;
	float y = _y * cellSize;
	
	switch (val) {
		case MAN: // 1: second player
			[whiteLayer renderAtPoint:CGPointMake(x, y)];
			break;
		case COM: // 0: first player
			[blackLayer renderAtPoint:CGPointMake(x, y)];
			break;
		default:
			break;
	}
}

- (void)drawRect:(CGRect)rect {
	//[super drawRect:rect];
	//if ([ gomokuModel isComputerThinking ]) {
		// No need to redraw because painting during computer's thinking
		// will display the entire board incorrectly
		//return;
	//}
	// why not use isFirstTime flag here. The boardSize == 0's semantic is not explicitly clear that this is the first time of rendering, i.e., in case I want somewhere in the program that boardSize=0, that this line fails. And now I want to move the get board size statement out of this block to off-load the drawRect function, what can I do? I have to add the isFirstTime flag again!!!
	//if (boardSize == 0) { 
	if ([self isFirstTimePainting]) {
		// the first time, get context and create layers (the delegates are prepared in init function.
		CGContextRef ctxCurrent = UIGraphicsGetCurrentContext();		
		
		rectLayer	= [[CellLayer alloc] initWithContext:ctxCurrent withDelegate:renderCellDelegate];
		blackLayer	= [[CellLayer alloc] initWithContext:ctxCurrent withDelegate:renderBlackDelegate];
		whiteLayer	= [[CellLayer alloc] initWithContext:ctxCurrent withDelegate:renderWhiteDelegate];
		cursorLayer = [[CellLayer alloc] initWithContext:ctxCurrent withDelegate:renderCursorDelegate];
	
		// no first time painting any more
		[self cancelFirstTimePainting];
	}	
   	
	// --------------- Board Rendering -------------------- //
	//[self setTransform:CGAffineTransformIdentity]; // disable scale from scroll view
	//CGAffineTransform curMat = self.transform;
	//curMat.a = 1; curMat.b = 0; curMat.c = 0; curMat.d = 1; 
	//[self setTransform:curMat];
	
	int i, j; 
	float x, y;
	
	for (i = 0, y = 0; i < boardSize; i++, y += cellSize) { // row
		for (j = 0, x = 0; j < boardSize; j++, x += cellSize) { // col
				[rectLayer renderAtPoint:CGPointMake(x, y)];
		}
	}
	
	// render cursor
	[cursorLayer renderAtPoint:CGPointMake(cursor.x*cellSize, cursor.y*cellSize)];
	
	// visit history for rendering of pieces
	[gomokuModel historyVisit:self withSelector:@selector(visitAndRenderCell:::)];
	
	//[ self notifyPaintingFinished ];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// only single-touch at the moment (anyObject)
	UITouch *touch = [touches anyObject];
	
	// get touch point
	CGPoint touchPoint = [touch locationInView:self];
	
	// map to grid
	int r = touchPoint.y / cellSize;
	int c = touchPoint.x / cellSize;

	// put cursor
	cursor = CGPointMake(c, r);	
		
	// redraw
	[self setNeedsDisplay];
}
/*
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	// only single-touch at the moment (anyObject)
	UITouch *touch = [touches anyObject];
	
	// get touch point
	CGPoint touchPoint = [touch locationInView:self];
	
	// map to grid
	int r = touchPoint.y / cellSize;
	int c = touchPoint.x / cellSize;
	
	// put cursor
	cursorX = c;
	cursorY = r;
	
	// redraw
	[self setNeedsDisplay];
}
*/

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// isGameOver?
	if ([gomokuModel isGameOver]) {
		[gomokuModel restart];
		return;
	}
	// Prohibit user's input while computer's thinking
	if ([ gomokuModel side ] == COM) {
		return;
	}
	// only single-touch at the moment (anyObject)
	UITouch *touch = [touches anyObject];
	
	// get touch point
	CGPoint touchPoint = [touch locationInView:self];
	
	// map to grid
	int r = touchPoint.y / cellSize;
	int c = touchPoint.x / cellSize;
	
	// human move
	if ([gomokuModel getBoardValue: r column: c] == EMPTY) {
		[gomokuModel humanMove:r column:c];
		//[self focusOnCursor]; // focus
	}
	
	// computer move
	[ self notifyPaintingFinished ]; // move and focus
	
	// remove cursor
	//cursorX = cursorY = -1;
}




- (void)startThinking {
	// show indicator
	[superview showIndicatorView];
	
	int move = [gomokuModel computerMove];
	
	// set board cursor
	cursor = CGPointMake(move % boardSize, move / boardSize);
	
	// focus on current piece
	//[ NSThread detachNewThreadSelector: @selector(focusOnCursor) toTarget: self withObject: nil ];
	[self focusOnCursor];
	[self setNeedsDisplay];
	
	// hide indicator
	[superview hideIndicatorView];
}

- (bool)isFirstTimePainting {
	return firstTimePainting;
}
- (void)notifyFirstTimePainting { // will need to notify again if theme changes
	firstTimePainting = 1;
}
- (void)cancelFirstTimePainting {
	firstTimePainting = 0;
}

- (void)notifyPaintingFinished {	
	/*
	 Note: Long running code must be placed in another thread for not blocking rendering thread.
	 */
	if ([ gomokuModel side ] == COM && ![ gomokuModel isComputerThinking ]) {
		//[ NSThread detachNewThreadSelector: @selector(startThinking) toTarget: self withObject: nil ];
		[self startThinking];
	}
	/*
	else  
		if ([ gomokuModel side ] == MAN) {
			[self focusOnCursor]; // focus on previous computer move
		}*/
}

// ----- observer ----- //
- (void)onGomokuNotify:(id<GomokuObservable>)observable {
	// ask for a full redraw. Note that the redraw is queued and it is unsure when it is actually redrawn and displayed on the screen.
	[self setNeedsDisplay];
}

- (void)onZoomScaleChanged:(float)scale {
	return;
	
	
	// calculate new cell size
	cellSize = (int)[self cellSizeFromScale:scale];
	// set new bound
	[self setBounds:CGRectMake(0, 0, boardSize*cellSize+1, boardSize*cellSize+1)];
	
	// reinitialize all render cell	
	[renderCellDelegate setCellSize:cellSize];
	[renderBlackDelegate setCellSize:cellSize];
	[renderWhiteDelegate setCellSize:cellSize];
	
	// release old layers, then notify first time painting 
	[rectLayer release];
	[blackLayer release];
	[whiteLayer release];
	
	[self notifyFirstTimePainting]; // re-create layer with new cell size
	
	
	// ask for redraw
	[self setNeedsDisplay];	
}

- (void)dealloc {
	// a little house keeping
	[renderCellDelegate  release];
	[renderBlackDelegate release];
	[renderWhiteDelegate release];
	[rectLayer  release];
	[blackLayer release];
	[whiteLayer release];
    [super dealloc];
}


@end
