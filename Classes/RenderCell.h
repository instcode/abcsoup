//
//  RenderCell.h
//  JouzuGomoku
//
//  Created by Son Hua on 10/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RenderDelegate.h"

@interface RenderCell : NSObject <RenderDelegate> { // implement render delegate protocol
	float cellSize;
}
@property (assign) float cellSize;

- (void)render:(CGContextRef)context;
- (void)render:(CGContextRef)context: withAffine:(CGAffineTransform)affine;
@end
