//
//  RenderPiece.m
//  JouzuGomoku
//
//  Created by Son Hua on 10/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RenderPiece.h"

float blackColor[] = {0.0, 0.0, 0.0, 1.0};
float whiteColor[] = {1, 1, 1, 1};

@implementation RenderPiece

- (void)setPiece:(int)_piece {
	piece = _piece;
	if (piece == 0) {
		fillColor = blackColor;		
	} else {
		fillColor = whiteColor;
	}
}

- (int)piece {
	return piece;
}

- (void)render:(CGContextRef)context {
	[super render:context];
	
	float shadowColor[] = {0.3, 0.3, 0.3, 1.0};
	CGColorRef shadowColorRef = CGColorCreate(CGColorSpaceCreateDeviceRGB(), shadowColor);
	CGColorRef fillColorRef = CGColorCreate(CGColorSpaceCreateDeviceRGB(), fillColor);
	CGSize offset = CGSizeMake(1, 1);
	float blur = 3;
	float rectOffset = 5;
	CGRect rect = CGRectMake(rectOffset, rectOffset, cellSize - 2*rectOffset, cellSize - 2*rectOffset); 
	
	// draw a black piece
	CGContextSaveGState(context);
	CGContextBeginPath(context);
	CGContextAddEllipseInRect(context, rect);
	CGContextSetShadowWithColor(context, offset, blur, shadowColorRef);
	CGContextSetFillColorWithColor(context, fillColorRef);
	CGContextFillPath(context);
	CGContextRestoreGState(context);
	
	//[super render:context]; // why put at bottom T_T? Note that some drawing code are buggy. If you pass the color directly without using ColorRef but float[4], you will notice strange outputs T_T. 
	
}

- (void)render:(CGContextRef)context: withAffine:(CGAffineTransform)affine {
	[super render:context withAffine:affine];
	
}
@end
