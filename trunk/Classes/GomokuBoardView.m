//
//  GomokuBoardView.m
//  JouzuGomoku
//
//  Created by Son Hua on 10/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GomokuBoardView.h"
#import "Gomoku.h"

@implementation GomokuBoardView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		// is not called :-? Why?
		gomokuModel = [Gomoku getGomokuModel];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	NSString* strHelloWorld = @"Hello World";
	CGPoint location = CGPointMake(100, 200);
	UIFont* font = [UIFont systemFontOfSize:24];
	[[UIColor blackColor] set]; // set pen color
	//[strHelloWorld drawAtPoint:location withFont:font];
	
	// Draw number of cells
	gomokuModel = [Gomoku getGomokuModel];

	int boardSize = [gomokuModel boardSize];
	
	NSString* strBoardSize = [NSString stringWithFormat:@"%d", boardSize];
	[strBoardSize drawAtPoint:location withFont:font];
}


- (void)dealloc {
    [super dealloc];
}


@end
