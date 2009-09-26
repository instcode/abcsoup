//
//  AboutTableController.h
//
//  Created by Son Hua on 01/08/09.
//  Copyright 2009 Aptus Ventures. All rights reserved.
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
