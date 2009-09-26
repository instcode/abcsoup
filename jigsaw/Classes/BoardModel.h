//
//  BoardModel.h
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PieceModel;	// forward declaration

@interface BoardModel : NSObject {
@private
	int width;		// how many cells are there in the board?
	int height;

	//PieceModel* pieceModels;
	NSMutableArray* pieceModels;
}

@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;
@property (nonatomic, readonly) NSMutableArray* pieceModels;

/*************************************************************
 * Create a new board data with specified size
 *************************************************************/
- (id) initWithSize: (int) width: (int) height;

@end
