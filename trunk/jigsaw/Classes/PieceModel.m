//
//  PieceModel.m
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "PieceModel.h"


@implementation PieceModel

@synthesize uid, x, y;

- (id) initWithUid: (BoardModel*) _boardModel: (int) _uid {
	if ((self = [super init]) != NULL) {
		uid = _uid;
		boardModel = _boardModel;
		
		// compute 2D grid position
		x = uid % boardModel.width;
		y = uid / boardModel.width;
	}
	return self;
}

- (BOOL) isNeighborOf: (PieceModel*) model {
	int dx = abs(x - model.x);
	int dy = abs(y - model.y);
	if (dx + dy == 1) { // 4-neighbor
		return TRUE;
	} else {
		return FALSE;
	}
}

@end
