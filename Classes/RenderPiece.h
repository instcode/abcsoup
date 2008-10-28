//
//  RenderPiece.h
//  JouzuGomoku
//
//  Created by Son Hua on 10/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RenderDelegate.h"
#import "RenderCell.h"

@interface RenderPiece : RenderCell {
	int piece; //0: black 1: white
	float* fillColor;
	float* shadowColor;
}
@property (assign) int piece;

- (void)render:(CGContextRef)context;
- (void)render:(CGContextRef)context: withAffine:(CGAffineTransform)affine;
@end

