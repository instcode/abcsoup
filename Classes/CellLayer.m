//
//  CellLayer.m
//  JouzuGomoku
//
//  Created by Son Hua on 10/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CellLayer.h"


@implementation CellLayer

- (id)initWithContext:(CGContextRef)context withDelegate:(id<RenderDelegate>)delegate {
	// id<RenderDelegate> is a pointer!
	self = [super init];
	if (self != nil) {
		ctxParent = context;		
		
		float nCellSize = [delegate getCellSize];
		CGSize cellSize = CGSizeMake(nCellSize+1, nCellSize+1); // max layer size that has not been cropped

		// create layer
		layer = CGLayerCreateWithContext(ctxParent, cellSize, NULL);
		
		// get context
		CGContextRef ctxLayer = CGLayerGetContext(layer);
		// render to layer
		[delegate render:ctxLayer];
		// now stay still and wait there. When anyone ask to expose the layer, just do it! :)
	}
	return self;
}

- (void)renderAtPoint:(CGPoint)point {
	// expose the layer
	CGContextDrawLayerAtPoint(ctxParent, point, layer);
}

- (void)dealloc {
	[super dealloc];
}

@end
