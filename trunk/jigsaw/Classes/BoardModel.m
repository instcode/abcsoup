//
//  BoardModel.m
//  Jigsaw
//
//  Created by Son Hua on 5/1/09.
//  Copyright 2009 AptusVentures. All rights reserved.
//

#import "BoardModel.h"
#import "PieceModel.h"

@implementation BoardModel

@synthesize width, height;
@synthesize pieceModels;

- (id) initWithSize: (int) _width : (int) _height {
	if ((self = [super init]) != NULL) {
		width = _width;
		height = _height;
		
		int total = width * height;
		//pieceModels = (PieceModel*) malloc(sizeof(PieceModel) * total);
		pieceModels = [NSMutableArray arrayWithCapacity: total]; 
		for (int i = 0; i < total; ++i) {
			PieceModel* p = [[PieceModel alloc] initWithUid: self: i];
			[pieceModels addObject:p];
		}
	}
	return self;
}

- (void) dealloc {
	free(pieceModels);
	[super dealloc];
}
@end
