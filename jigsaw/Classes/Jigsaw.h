//
//  Jigsaw.h
//  Jigsaw
//
//  Created by Son Hua on 17/10/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Renderable.h"

#include "RenzoTimer.h"
using namespace Renzo;

@class Board; // forward declaration
@class Blank;
@class FadeIn;
@class FadeOut;
@class Splash;

/*
 @desciption
 Jigsaw is the global interface for iPhone GUI to interact with the Jigsaw game core. This class is designed as a singleton
 */
@interface Jigsaw : Renderable {
	NSMutableArray* scenes;
	FadeIn*		fadeIn;
	FadeOut*	fadeOut;
	Board*		boardScene;
	
	Timer* timer;
	
	CGRect screenRect;
	
	enum JigsawRenderState {
		rsSceneDefault,
		rsSceneTransition
	} renderState;
	
	int curSceneIndex, nextSceneIndex;
	Renderable* curScene, *nextScene;
	
	bool firstTimeFadeIn;
}

@property (nonatomic, readonly) CGRect screenRect;

/**
 @description
 Get singleton instance of Jigsaw.
 */
+ (Jigsaw*) instance;

/**
 Scene management
 */
- (void) addScene: (Renderable*) renderable;
- (void) beginNextScene;
- (void) endNextScene;
- (void) changeRenderState: (JigsawRenderState) rs;
- (Timer*) getTimer;

- (void) save;
@end
