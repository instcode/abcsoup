//
//  JouzuGomokuAppDelegate.m
//  JouzuGomoku
//
//  Created by Son Hua on 10/23/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "JouzuGomokuAppDelegate.h"
#import "JouzuGomokuViewController.h"

@implementation JouzuGomokuAppDelegate

@synthesize window;
///@synthesize viewController;
@synthesize tabController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    //[window addSubview:viewController.view];
	[window addSubview:tabController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    //[viewController release];
    [window release];
    [super dealloc];
}


@end
