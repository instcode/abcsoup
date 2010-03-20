//
//  Renderable.h
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import "Float3.h"
#import "Point.h"

//@protocol Renderable
@interface Renderable : NSObject 
{
}
	
- (void) load;				// load resources
- (void) update: (int) delta;
- (void) render;
- (bool) isDone;			// scene completes its job. Next scene will comes in.
- (void) reset;				// turn the scene back to beginning state.

- (void) onTouchMoved: (struct JPoint) p;
- (void) onTouchBegan: (struct JPoint) p;
- (void) onTouchEnded: (struct JPoint) p;
- (void) onShowBegan;		// called after transition
- (void) onShowEnded;
@end

/*
	float3 position;	// position in 3D
	float3 angle;		// rotate angle about x, y, z axis
	 */

/*
@property (nonatomic, assign) float3 position;
@property (nonatomic, assign) float3 angle;
*/
