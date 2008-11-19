//
//  RenderCursor.m
//  JouzuGomoku
//
//  Created by Son Hua on 11/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RenderCursor.h"


@implementation RenderCursor

float cursorFillColor[] = {0.12, 0.72, 0.72, 1.0};

// override
- (void)render:(CGContextRef)context {
	CGContextSaveGState(context);
	// draw a rect
	
	 CGRect fillRect = CGRectMake(0, 0, cellSize, cellSize);		
	 CGColorRef fillColorRef = CGColorCreate(CGColorSpaceCreateDeviceRGB(), cursorFillColor);
	 CGContextBeginPath(context);
	 CGContextAddRect(context, fillRect);	
	 CGContextSetFillColorWithColor(context, fillColorRef);
	 CGContextFillPath(context);
	 
	
	CGRect rect = CGRectMake(0, 0, cellSize+1, cellSize+1);
	CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1.0);
	CGContextBeginPath(context);
	CGContextAddRect(context, rect);
	CGContextStrokePath(context); // draw current path
		
	CGContextRestoreGState(context);
	
}

@end
