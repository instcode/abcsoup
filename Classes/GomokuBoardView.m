//
//  GomokuBoardView.m
//  JouzuGomoku
//
//  Created by Son Hua on 10/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GomokuBoardView.h"


@implementation GomokuBoardView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	NSString* strHelloWorld = @"Hello World";
	CGPoint location = CGPointMake(100, 200);
	UIFont* font = [UIFont systemFontOfSize:24];
	[[UIColor blackColor] set]; // set pen color
	[strHelloWorld drawAtPoint:location withFont:font];
}


- (void)dealloc {
    [super dealloc];
}


@end
