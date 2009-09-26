//
//  Manager.m
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "BoardManager.h"


@implementation BoardManager

//-------------------------------------------------------------------
@synthesize boardModel;
@synthesize boardView;
//-------------------------------------------------------------------
BoardManager* boardManager = NULL;

//-------------------------------------------------------------------
+ (BoardManager*) getBoardManager {
	if (boardManager == NULL) {
		boardManager = [[BoardManager alloc] init];
		
		// more initialization goes here
		boardManager.boardModel = [[BoardModel alloc] initWithSize:5 :5]; 
		boardManager.boardView = [[BoardView alloc] init];
	}
	return boardManager;
}

@end
