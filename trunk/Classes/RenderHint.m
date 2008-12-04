//
//  RenderHint.m
//  JouzuGomoku
//
//  Created by Son Hua on 12/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RenderHint.h"


@implementation RenderHint
float hintFillColor[] = {0.8745, 0.7843, 0.3804, 1.0};

// override
- (void)render:(CGContextRef)context {
	CGContextSaveGState(context);
	// draw a rect
	
	CGRect fillRect = CGRectMake(0, 0, cellSize, cellSize);		
	CGColorRef fillColorRef = CGColorCreate(CGColorSpaceCreateDeviceRGB(), hintFillColor);
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
