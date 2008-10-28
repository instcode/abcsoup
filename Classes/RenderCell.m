//
//  RenderCell.m
//  JouzuGomoku
//
//  Created by Son Hua on 10/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RenderCell.h"


@implementation RenderCell
@synthesize cellSize;

- (void)render:(CGContextRef)context {
	CGContextSaveGState(context);
	// draw a rect
	CGRect rect = CGRectMake(0, 0, cellSize, cellSize);
	CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1.0);
	CGContextBeginPath(context);
	CGContextAddRect(context, rect);
	CGContextStrokePath(context); // draw current path
	
	/* test */
	/*
	NSString* strHelloWorld = @"Hello World";
	CGPoint location = CGPointMake(0, 0);
	UIFont* font = [UIFont systemFontOfSize:24];
	[[UIColor blackColor] set]; // set pen color
	[strHelloWorld drawAtPoint:location withFont:font];
	*/
	
	CGContextRestoreGState(context);
}

- (void)render:(CGContextRef)context: withAffine:(CGAffineTransform)affine {
	
}
@end
