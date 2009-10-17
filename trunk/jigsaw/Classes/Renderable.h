//
//  Renderable.h
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "Float3.h"

//@interface Renderable : NSObject {
@protocol Renderable
	- (void) update: (int) delta;
	- (void) render;
@end

/*
	float3 position;	// position in 3D
	float3 angle;		// rotate angle about x, y, z axis
	 */

/*
@property (nonatomic, assign) float3 position;
@property (nonatomic, assign) float3 angle;
*/
