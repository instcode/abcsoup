//
//  Jigsaw.h
//  Jigsaw
//
//  Created by Son Hua on 17/10/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Board.h"
#include "RenzoTimer.h"

using namespace Renzo;
/*
 @desciption
 Jigsaw is the global interface for iPhone GUI to interact with the Jigsaw game core. This class is designed as a singleton
 */
@interface Jigsaw : NSObject {
	NSMutableArray* boards;
	
	Board* activeBoard;
	Timer* timer;
}

/**
 @description
 Get singleton instance of Jigsaw.
 */
+ (Jigsaw*) instance;

/**
 Add a new puzzle board. Jigsaw manages all created puzzle boards in an array.
 */
- (void) addBoard: (Board*) b;

/**
 Set active board. Board b is added to board array if it is not added.
 */
- (void) setActiveBoard: (Board*) b;

/**
 Get active board.
 */
- (Board*) getActiveBoard;

- (Timer*) getTimer;
@end
