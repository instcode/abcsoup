/*
 *  Gomoku.m
 *  JouzuGomoku
 *
 *  Created by Son Hua on 10/26/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "Gomoku.h"

GomokuModel* gomokuModel = 0; // global variable that acts as a static (class) variable.

@implementation Gomoku
+ (GomokuModel*)getGomokuModel {
	if (gomokuModel == 0) {
		gomokuModel = [[GomokuModel alloc] init];
	}
	return gomokuModel;
}

@end
