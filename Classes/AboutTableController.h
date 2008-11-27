//
//  AboutTableController.h
//  JouzuGomoku
//
//  Created by Son Hua on 11/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutTableController : UITableViewController {
	NSArray* keys;
	NSArray* objects;
	NSDictionary* dictAbout;
	
}
@property (nonatomic, retain) NSArray* keys;
@property (nonatomic, retain) NSArray* objects;
@end
