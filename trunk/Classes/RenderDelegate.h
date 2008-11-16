/*
 *  RenderDelegate.h
 *  JouzuGomoku
 *
 *  Created by Son Hua on 10/27/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

@protocol RenderDelegate<NSObject>

- (float)getCellSize;
- (void)render:(CGContextRef)context;
- (void)render:(CGContextRef)context: withAffine:(CGAffineTransform)affine;

@end