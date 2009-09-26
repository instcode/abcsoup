//
//  PieceModel.h
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardModel.h"

@interface PieceModel : NSObject {
	int uid;	// id of the piece
	BoardModel* boardModel;
	int x, y;
}

@property (nonatomic, readonly) int uid;
@property (nonatomic, readonly) int x;
@property (nonatomic, readonly) int y;

- (id) initWithUid: (BoardModel*) _boardModel: (int) _uid;
/****************************************************
 * Check two piece models if they are sibling 
 ****************************************************/
- (BOOL) isNeighborOf: (PieceModel*) model;
@end
