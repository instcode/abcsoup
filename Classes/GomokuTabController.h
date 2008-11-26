//
//  GomokuTabController.h
//  JouzuGomoku
//
//  Created by Tuan Luu on 11/12/08.
//  Copyright 2008 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GomokuModel.h"

@interface GomokuTabController : UITabBarController {
	GomokuModel* model;
}

- (IBAction)respondToButtonNewClick:(id)sender;
- (IBAction)respondToButtonUndoClick:(id)sender;
@end
