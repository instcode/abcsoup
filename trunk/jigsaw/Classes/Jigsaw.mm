//
//  Jigsaw.m
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "Jigsaw.h"

Jigsaw* jigsaw = NULL;

@implementation Jigsaw

+ (Jigsaw*) instance {
	if (jigsaw == NULL) {
		jigsaw = [[Jigsaw alloc] init];
	}
	return jigsaw;
}

- (id) init {
	if ((self = [super init]) != NULL) {
		boards = [NSMutableArray arrayWithCapacity: 1]; // support for 1 instance at the beginning
		timer = new Timer;
	}
	return self;
}

- (void) dealloc {
	[boards release];
	delete timer;
	[super dealloc];
}

- (void) addBoard: (Board*) b {
	if ([boards containsObject: b] == false) {
		[boards addObject: b];
	}
}

- (void) setActiveBoard: (Board*) b {
	[self addBoard: b];	// add to list of boards if needed
	activeBoard = b;
}

- (Board*) getActiveBoard {
	return activeBoard;
}

- (Timer*) getTimer {
	return timer;
}

@end
