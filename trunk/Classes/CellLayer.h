//
//  CellLayer.h
//  JouzuGomoku
//
//  Created by Son Hua on 10/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RenderDelegate.h"

// A layer wrapper

@interface CellLayer : NSObject {	
	CGLayerRef layer;
	CGContextRef ctxParent;
}
  // init layer object, set the delegate, render to the layer, and wait there
- (id)initWithContext:(CGContextRef)context withDelegate:(id<RenderDelegate>)delegate cell:(int)nCellSize;
  // expose the internal layer to a particular location
- (void)renderAtPoint:(CGPoint)point;
@end
