//
//  OptionTableController.h
//  JouzuGomoku
//
//  Created by Tuan Luu on 12/2/08.
//  Copyright 2008 NUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GomokuModel.h"

@interface OptionTableController : UITableViewController {
	NSArray* keys;
	NSArray* objects;
	NSDictionary* dictAbout;
	
	GomokuModel* gomokuModel;
}

@property (nonatomic, retain) NSArray* keys;
@property (nonatomic, retain) NSArray* objects;

@end
