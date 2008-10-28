//
//  GomokuBoardView.h
//  JouzuGomoku
//
//  Created by Son Hua on 10/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GomokuModel.h"
#import "CellLayer.h"
#import "GomokuObserver.h"

@interface GomokuBoardView : UIView <GomokuObserver> {
	GomokuModel* gomokuModel;
	CellLayer* rectLayer;	// empty rect
	CellLayer* blackLayer;	// rect with black piece
	CellLayer* whiteLayer;	// rect with white piece
	
	int boardSize;
	int cellSize;
	int isFirstTime;
	int isPainting;
}

// observer
- (void)onGomokuNotify:(id<GomokuObservable>)observable;
- (void)startThinking;
@end
