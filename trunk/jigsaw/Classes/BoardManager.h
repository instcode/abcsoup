//
//  Manager.h
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "BoardModel.h"
#include "BoardView.h"

@interface BoardManager : NSObject {
@private
	BoardModel* boardModel;
	BoardView* boardView;
}

@property (nonatomic, retain) BoardModel* boardModel;
@property (nonatomic, retain) BoardView* boardView;

/****************************************************
 * Singleton object provides all board's info
 ****************************************************/
+ (BoardManager*) getBoardManager;

/****************************************************
 * TODO: Save/load board goes here
 ****************************************************/

@end
