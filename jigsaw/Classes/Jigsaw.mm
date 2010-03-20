//
//  Jigsaw.m
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "Jigsaw.h"
#import "Blank.h"
#import "Splash.h"
#import "Board.h"
#import "FadeIn.h"
#import "FadeOut.h"
#include "RenzoTimer.h"

Jigsaw* jigsaw = NULL;
NSString* fileJigsaw = @"Jigsaw.archive";

@implementation Jigsaw
@synthesize screenRect;

+ (Jigsaw*) instance {
	if (jigsaw == NULL) {
		jigsaw = [[Jigsaw alloc] init];
	}
	return jigsaw;
}

- (id) init {
	if ((self = [super init]) != NULL) {
		timer = new Timer;
	}
	return self;
}

- (void) load {
	// screen rect property
	screenRect = [[UIScreen mainScreen] bounds];
	
	scenes = [[NSMutableArray arrayWithCapacity: 16] retain]; // support for 1 instance at the beginning
	
	// start dummy blank scene
	Renderable* blankScene = [[Blank alloc] init];
	[blankScene load];
	[self addScene: blankScene];
	
	// splash scene
	Renderable* splashScene = [[Splash alloc] init];
	[splashScene load];
	[self addScene: splashScene];
	
	// board
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *archivePath = [documentsDirectory stringByAppendingPathComponent: fileJigsaw];
	FILE* f = fopen([archivePath cStringUsingEncoding:NSASCIIStringEncoding], "r");
	boardScene = [[Board alloc] init];	
	if (f) {
		[boardScene load: f];
		fclose(f);
	} else {
		[boardScene load];
	}
	[self addScene: boardScene];
	
	// fade in transition
	fadeIn = [[FadeIn alloc] init];
	[fadeIn load];
	fadeOut = [[FadeOut alloc] init];
	[fadeOut load];
	
	// render state
	[self changeRenderState: rsSceneDefault];
	curSceneIndex	= 0;
	curScene		= (Renderable*)[scenes objectAtIndex: 0];
	nextSceneIndex	= -1;	
	nextScene		= NULL;
}

- (void) save {
	// Get path to settings file.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *archivePath = [documentsDirectory stringByAppendingPathComponent: fileJigsaw];
	
	FILE* f = fopen([archivePath cStringUsingEncoding:NSASCIIStringEncoding], "w");
	[boardScene save:f];
	fclose(f);
}

- (void) dealloc {
	//[self save];
	
	[scenes release];
	[fadeIn release];
	[fadeOut release];
	delete timer;
	[super dealloc];
}

- (void) addScene: (Renderable*) renderable {
	[scenes addObject: renderable];
}

- (void) beginNextScene {
	nextSceneIndex	= min(curSceneIndex + 1, [scenes count] - 1);
	nextScene		= (Renderable*)[scenes objectAtIndex: nextSceneIndex];
	[fadeIn reset];
	[fadeOut reset];
}

- (void) endNextScene {
	curSceneIndex	= nextSceneIndex;
	curScene		= nextScene;
}

- (Timer*) getTimer {
	return timer;
}

- (void) changeRenderState: (JigsawRenderState) rs {
	renderState = rs;
}

- (void) update: (int) delta {
	// get time
	delta = timer->Update();
	
	// next scene transition
	switch (renderState) {
		case rsSceneTransition:
			if ([fadeOut isDone] == false) {
				[curScene update: delta];
				[fadeOut update: delta];
			} else {
				if ([fadeIn	isDone] == false) {
					[nextScene update: delta];
					[fadeIn update: delta];
					
					// first time fade in
					if (firstTimeFadeIn) {
						// first time fade in, notify next scene to update display
						[nextScene onShowBegan];
						firstTimeFadeIn = false;
					}
					
				} else {
					[self endNextScene];
					[self changeRenderState: rsSceneDefault];
					[curScene onShowEnded]; // notify current scene when it is shown
				}
			}
			
			break;
		case rsSceneDefault:
			// update current scene
			[curScene update: delta];
			if ([curScene isDone]) {
				[self beginNextScene];
				[self changeRenderState: rsSceneTransition];
				// catch an event when starting to fade in
				if (firstTimeFadeIn == false) {
					firstTimeFadeIn = true;
				}
			}
			break;
	}
}

- (void) render {
	switch (renderState) {
		case rsSceneTransition:
			if ([fadeOut isDone] == false) {
				[curScene render];
				[fadeOut render]; // darken
			} else {
				//if ([fadeIn	isDone] == false) {
					[nextScene render];
					[fadeIn render]; // brighten
				//}
			}
			break;
		case rsSceneDefault:
			[curScene render];
			break;
	}
}

- (void) onTouchMoved: (struct JPoint) p {
	switch (renderState) {
		case rsSceneDefault:
			[curScene onTouchMoved: p];
			break;
	}
}

- (void) onTouchBegan: (struct JPoint) p {
	switch (renderState) {
		case rsSceneDefault:
			[curScene onTouchBegan: p];
			break;
	}
}

- (void) onTouchEnded: (struct JPoint) p {
	switch (renderState) {
		case rsSceneDefault:
			[curScene onTouchEnded: p];
			break;
	}
}

@end
