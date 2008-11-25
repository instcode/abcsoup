//
//  GomokuBoardScrollView.h
//  JouzuGomoku
//
//  Created by Son Hua on 10/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GomokuBoardView.h"

@interface GomokuBoardScrollView : UIScrollView <UIScrollViewDelegate> {
	GomokuBoardView* boardView;
	UIActivityIndicatorView* indicatorView;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* indicatorView;
- (void) showIndicatorView;
- (void) hideIndicatorView;

@end
