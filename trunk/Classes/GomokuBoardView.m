//
//  GomokuBoardView.m
//  JouzuGomoku
//
//  Created by Son Hua on 10/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

// History ======================= //
// [2008-10-27] Render board
// =============================== //

#import "GomokuBoardView.h"
#import "Gomoku.h"
#import "CellLayer.h"
#import "RenderCell.h"
#import "RenderPiece.h"
#include <math.h> # add -lm

@implementation GomokuBoardView


// This view is loaded from Nib file. Therefore, initWithFrame is not called automatically. Use awakeFromNib instead.
//- (id)initWithFrame:(CGRect)frame {
- (void)awakeFromNib {
    //if (self = [super initWithFrame:frame]) {
        // Initialization code
	
	gomokuModel = [Gomoku getGomokuModel];
	[gomokuModel attachGomoku:self]; // register for observing model changes
	
	isFirstTime = 1;
	
		    //}
    //return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	if (isFirstTime) {
		CGContextRef ctxCurrent = UIGraphicsGetCurrentContext();
		CGRect screenBound = [[UIScreen mainScreen] applicationFrame];
		
		boardSize = [gomokuModel boardSize];
		cellSize = (int)(fmin(screenBound.size.width, screenBound.size.height) / boardSize);
		
		// create render layer, render to layer and wait
		RenderCell* renderCellDelegate = [[[RenderCell alloc] init] autorelease];		
		[renderCellDelegate setCellSize:cellSize];		
		rectLayer = [[CellLayer alloc] initWithContext:ctxCurrent withDelegate:renderCellDelegate cell:cellSize];
		
		// create a black layer
		RenderPiece* renderBlackDelegate = [[[RenderPiece alloc] init] autorelease];		
		[renderBlackDelegate setCellSize:cellSize];	
		[renderBlackDelegate setPiece:0];
		blackLayer = [[CellLayer alloc] initWithContext:ctxCurrent withDelegate:renderBlackDelegate cell:cellSize];
		
		// create a white layer
		RenderPiece* renderWhiteDelegate = [[[RenderPiece alloc] init] autorelease];		
		[renderWhiteDelegate setCellSize:cellSize];	
		[renderWhiteDelegate setPiece:1];
		whiteLayer = [[CellLayer alloc] initWithContext:ctxCurrent withDelegate:renderWhiteDelegate cell:cellSize];
		
		
		// flip the first time flag
		isFirstTime = 0;
	}

	
	
	////NSString* strBoardSize = [NSString stringWithFormat:@"%d", boardSize];
	//[strBoardSize drawAtPoint:location withFont:font];
	
	// --------------- Board Rendering -------------------- //
	// get cell layer
	// get piece layer
	// ask to draw
	int i, j, x, y;
	isPainting = 1;
	for (i = 0, y = 0; i < boardSize; i++, y += cellSize) { // row
		for (j = 0, x = 0; j < boardSize; j++, x += cellSize) { // col
			// from bottom to top in Quartz 2D coordinate, but draw in view, it is automatically converted back to top-left. So that is top-left as normal.
			//[whiteLayer renderAtPoint:CGPointMake(y, x)];continue;
			//[blackLayer renderAtPoint:CGPointMake(y, x)];continue;
			switch ([gomokuModel getBoardValue:i column:j]) {
			case EMPTY:
				[rectLayer renderAtPoint:CGPointMake(x, y)];
				break;
			case MAN:
				[whiteLayer renderAtPoint:CGPointMake(x, y)];
				break;
			case COM:
				[blackLayer renderAtPoint:CGPointMake(x, y)];
				break;
			default:
				//[whiteLayer renderAtPoint:CGPointMake(x, y)];	
				break;
			}
		}
	}
	isPainting = 0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	// isGameOver?
	if ([gomokuModel isGameOver]) {
		[gomokuModel restart];
		return;
	}
	
	// only single-touch at the moment (anyObject)
	UITouch *touch = [touches anyObject];
	
	// get touch point
	CGPoint touchPoint = [touch locationInView:self];

	// map to grid
	int r = touchPoint.y / cellSize;
	int c = touchPoint.x / cellSize;
	// set value to model
	//[gomokuModel setBoardValue:MAN row:r column:c];
	// human move
	if ([gomokuModel getBoardValue: r column: c] == EMPTY) {
		[gomokuModel humanMove:r column:c];
		//[self setNeedsDisplay];
		
		// computer move
		[ NSThread detachNewThreadSelector: @selector(startThinking) toTarget: self withObject: nil ];
	}
}

- (void)startThinking {
	while (isPainting) {
		[NSThread sleepForTimeInterval:5];		
	}
	
	[gomokuModel computerMove];
	//[self setNeedsDisplay];
}

// ----- observer ----- //
- (void)onGomokuNotify:(id<GomokuObservable>)observable {
	// ask for a full redraw
	[self setNeedsDisplay];
	// redraw immediately
	
}

- (void)dealloc {
    [super dealloc];
}


@end
