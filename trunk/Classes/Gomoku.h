/*
 *  Gomoku.h
 *  JouzuGomoku
 *
 *  Created by Son Hua on 10/26/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

// Singleton to keep all global variables in a class.

#import "GomokuModel.h"

@interface Gomoku : NSObject
{
}

+ (GomokuModel*)getGomokuModel;

@end
